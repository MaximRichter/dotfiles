#!/usr/bin/env python3
import argparse
import os
import shutil
import socket
import sqlite3
import subprocess
import tempfile
import time
import urllib.request
from collections import defaultdict
from datetime import datetime
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
RUNTIME_DIR = Path.home() / ".local/share/actual-hledger-export"
SYNC_SERVER = RUNTIME_DIR / "node_modules/.bin/actual-server"
SYNC_API = RUNTIME_DIR / "node_modules/@actual-app/api/dist/index.js"
SYNC_HELPER = SCRIPT_DIR / "sync_actual_export.mjs"
SYNC_ID = "b88b7fb0-2a29-4973-b394-668ed1f2ca36"
TEMP_PASSWORD = "actual-hledger-export-only"
TEMP_PASSWORD_HASH = "$2b$12$3h2qdjUn.KsQ7jza9b/jT.nknOyD4hSj2UfBdPfRSInpkMaO6r3EG"


ACCOUNT_MAP = {
    "Анди - Совкомбанк": "Assets:Bank:Анди:Совкомбанк",
    "Анди - Тинькофф": "Assets:Bank:Анди:Тинькофф",
    "Настя - Тинькофф": "Assets:Bank:Настя:Тинькофф",
    "Сбережения": "Assets:Savings:Сбережения",
    "Анди - ВТБ": "Assets:Bank:Анди:ВТБ",
    "Рассрочка за зубы": "Liabilities:Installments:Рассрочка за зубы",
    "Сплит за пылесос": "Liabilities:Installments:Сплит за пылесос",
}

CATEGORY_MAP = {
    ("Income", "Зарплата - Настя - остаток"): "Income:Зарплата:Настя:Остаток",
    ("Income", "Зарплата - Настя - аванс"): "Income:Зарплата:Настя:Аванс",
    ("Income", "Зарплата - Анди - остаток"): "Income:Зарплата:Анди:Остаток",
    ("Income", "Зарплата - Анди - аванс"): "Income:Зарплата:Анди:Аванс",
    ("Income", "Вклады, проценты и прочее"): "Income:Вклады проценты и прочее",
    ("Income", "Starting Balances"): "Income:Starting Balances",
    ("Постоянные расходы", "Ипотека"): "Expenses:Постоянные расходы:Ипотека",
    ("Постоянные расходы", "Аренда"): "Expenses:Постоянные расходы:Аренда",
    ("Постоянные расходы", "Рассрочки / Кредиты"): "Expenses:Постоянные расходы:Рассрочки и кредиты",
    ("Постоянные расходы", "Коммунальные платежи"): "Expenses:Постоянные расходы:Коммунальные платежи",
    ("Постоянные расходы", "Связь"): "Expenses:Постоянные расходы:Связь",
    ("Постоянные расходы", "Интернет"): "Expenses:Постоянные расходы:Интернет",
    ("Постоянные расходы", "Транспорт"): "Expenses:Постоянные расходы:Транспорт",
    ("Постоянные расходы", "Спортзал"): "Expenses:Постоянные расходы:Спортзал",
    ("Постоянные расходы", "Подписки"): "Expenses:Постоянные расходы:Подписки",
    ("Переменные расходы", "Продукты и химия"): "Expenses:Переменные расходы:Продукты и химия",
    ("Переменные расходы", "Питомцы"): "Expenses:Переменные расходы:Питомцы",
    ("Переменные расходы", "Товары для дома"): "Expenses:Переменные расходы:Товары для дома",
    ("Переменные расходы", "Здоровье"): "Expenses:Переменные расходы:Здоровье",
    ("Переменные расходы", "Красота"): "Expenses:Переменные расходы:Красота",
    ("Переменные расходы", "Одежда"): "Expenses:Переменные расходы:Одежда",
    ("Переменные расходы", "Еда"): "Expenses:Переменные расходы:Еда",
    ("Переменные расходы", "Развлечения"): "Expenses:Переменные расходы:Развлечения",
    ("Переменные расходы", "Подарки"): "Expenses:Переменные расходы:Подарки",
    ("Переменные расходы", "Прочее"): "Expenses:Переменные расходы:Прочее",
    ("Сбережения", "Финансовая подушка"): "Budget:Сбережения:Финансовая подушка",
}


QUERY = """
select
    t.id,
    t.date,
    t.amount,
    t.notes,
    t.starting_balance_flag,
    t.transferred_id,
    t.sort_order,
    a.name as account_name,
    c.name as category_name,
    cg.name as category_group_name,
    c.is_income as is_income,
    p.name as payee_name
from transactions t
left join accounts a on a.id = t.acct
left join categories c on c.id = t.category
left join category_groups cg on cg.id = c.cat_group
left join payees p on p.id = t.description
where t.tombstone = 0
  and t.isParent = 0
order by t.date, t.sort_order, t.id
"""


def hledger_date(actual_date):
    return datetime.strptime(str(actual_date), "%Y%m%d").strftime("%Y-%m-%d")


def amount(cents):
    return cents / 100


def fmt_amount(value):
    return f"RUB {value:.2f}"


def clean_text(value):
    if not value:
        return ""
    return str(value).replace("\n", " ").strip()


def comment_line(label, value):
    value = clean_text(value)
    if not value:
        return None
    return f"    ; {label}: {value}"


def get_account(name):
    try:
        return ACCOUNT_MAP[name]
    except KeyError as exc:
        raise RuntimeError(f"Unknown Actual account: {name}") from exc


def get_category(row):
    if row["starting_balance_flag"]:
        return "Equity:Opening Balances"

    group_name = row["category_group_name"]
    category_name = row["category_name"]
    if group_name and category_name:
        key = (group_name, category_name)
        try:
            return CATEGORY_MAP[key]
        except KeyError as exc:
            raise RuntimeError(f"Unknown Actual category: {group_name} / {category_name}") from exc

    if row["amount"] >= 0:
        return "Income:Uncategorized"
    return "Expenses:Uncategorized"


def transaction_header(date, payee):
    payee = clean_text(payee) or "Unknown Payee"
    return f"{date} {payee}"


def render_standard(row):
    acct = get_account(row["account_name"])
    category = get_category(row)
    actual_amount = amount(row["amount"])
    payee = row["payee_name"]

    lines = [transaction_header(hledger_date(row["date"]), payee)]
    for line in (
        comment_line("actual-id", row["id"]),
        comment_line("notes", row["notes"]),
    ):
        if line:
            lines.append(line)

    lines.append(f"    {acct:<58}  {fmt_amount(actual_amount)}")
    lines.append(f"    {category:<58}  {fmt_amount(-actual_amount)}")
    return "\n".join(lines)


def render_transfer(left, right):
    rows = sorted([left, right], key=lambda r: r["amount"])
    outflow = rows[0]
    inflow = rows[1]
    date = hledger_date(min(left["date"], right["date"]))
    payee = f"Transfer: {outflow['account_name']} -> {inflow['account_name']}"

    lines = [transaction_header(date, payee)]
    lines.append(f"    ; actual-ids: {left['id']}, {right['id']}")
    notes = clean_text(left["notes"]) or clean_text(right["notes"])
    if notes:
        lines.append(f"    ; notes: {notes}")

    for row in sorted([left, right], key=lambda r: (r["amount"] > 0, r["account_name"])):
        lines.append(f"    {get_account(row['account_name']):<58}  {fmt_amount(amount(row['amount']))}")
    return "\n".join(lines)


def load_rows(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    try:
        return [dict(row) for row in conn.execute(QUERY)]
    finally:
        conn.close()


def unused_local_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def wait_for_server(server_url, process):
    for _ in range(100):
        if process.poll() is not None:
            stdout, _ = process.communicate()
            raise RuntimeError(f"Temporary Actual server exited early:\n{stdout}")
        try:
            with urllib.request.urlopen(server_url, timeout=0.2):
                return
        except Exception:
            time.sleep(0.1)
    raise RuntimeError("Temporary Actual server did not start")


def synced_db(actual_data, tempdir):
    if not SYNC_SERVER.exists() or not SYNC_API.exists() or not SYNC_HELPER.exists():
        raise RuntimeError("Actual export runtime is missing next to this script")

    tempdir = Path(tempdir)
    server_data = tempdir / "server-data"
    api_data = tempdir / "api-data"
    shutil.copytree(actual_data, server_data)
    api_data.mkdir()

    account_db = server_data / "server-files/account.sqlite"
    with sqlite3.connect(account_db) as conn:
        conn.execute(
            "update auth set extra_data = ? where method = 'password'",
            (TEMP_PASSWORD_HASH,),
        )

    port = unused_local_port()
    server_url = f"http://127.0.0.1:{port}"
    config = server_data / "export-config.json"
    config.write_text(
        '{\n'
        f'  "dataDir": "{server_data}",\n'
        f'  "port": {port},\n'
        '  "hostname": "127.0.0.1"\n'
        '}\n',
        encoding="utf-8",
    )

    env = os.environ.copy()
    env["ACTUAL_DATA_DIR"] = str(server_data)
    server = subprocess.Popen(
        [str(SYNC_SERVER), "--config", str(config)],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env,
    )
    helper_error = None
    try:
        wait_for_server(server_url, server)
        try:
            subprocess.run(
                [
                    "node",
                    str(SYNC_HELPER),
                    str(SYNC_API),
                    server_url,
                    TEMP_PASSWORD,
                    SYNC_ID,
                    str(api_data),
                ],
                check=True,
            )
        except subprocess.CalledProcessError as exc:
            helper_error = exc
    finally:
        server.terminate()
        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()

    if helper_error:
        server_output = server.stdout.read()
        raise RuntimeError(f"Actual API sync failed:\n{server_output}") from helper_error

    databases = list(api_data.rglob("db.sqlite"))
    if len(databases) != 1:
        raise RuntimeError(f"Expected one synced db.sqlite, found {len(databases)}")
    return databases[0]


def render(rows):
    by_id = {row["id"]: row for row in rows}
    transfer_ids = {row["id"] for row in rows if row["transferred_id"]}
    visited = set()
    rendered = []
    warnings = []

    for row in rows:
        if row["id"] in visited:
            continue

        transfer_id = row["transferred_id"]
        if transfer_id:
            peer = by_id.get(transfer_id)
            if peer:
                visited.add(row["id"])
                visited.add(peer["id"])
                rendered.append(render_transfer(row, peer))
            else:
                visited.add(row["id"])
                warnings.append(f"Missing transfer peer for {row['id']} -> {transfer_id}")
                rendered.append(render_standard(row))
            continue

        if row["id"] in transfer_ids:
            continue

        visited.add(row["id"])
        rendered.append(render_standard(row))

    header = [
        "; Generated from Actual Budget.",
        "; Regenerate with: scripts/export_actual_to_hledger.py",
        "; Do not edit this file by hand if you plan to re-export.",
        "",
    ]
    if warnings:
        header.extend(f"; WARNING: {warning}" for warning in warnings)
        header.append("")
    return "\n\n".join(["\n".join(header), *rendered]) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Export Actual Budget transactions to hledger.")
    parser.add_argument(
        "--actual-data",
        default=Path.home() / ".local" / "share" / "actual-budget",
        help="Path to the Actual server data directory.",
    )
    parser.add_argument(
        "--output",
        default=Path.home() / "Documents" / "finance" / "hledger" / "actual-transactions.ledger",
        help="Output hledger journal file.",
    )
    args = parser.parse_args()

    with tempfile.TemporaryDirectory(prefix="actual-hledger-") as tempdir:
        db_path = synced_db(args.actual_data, tempdir)
        rows = load_rows(db_path)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render(rows), encoding="utf-8")
    print(f"Wrote {output} from {len(rows)} Actual rows")


if __name__ == "__main__":
    main()
