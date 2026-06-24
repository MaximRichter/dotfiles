#!/usr/bin/env bash
set -u

config_dir="${AMNEZIAWG_CONFIG_DIR:-$HOME/amnezia}"
mode="upload"
duration=60
warmup=5
interval=1
target_mbps=8
url=""
keep_connected=0
leave_disconnected=0
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/amneziawg-bitrate"
awg_quick="${AWG_QUICK:-$(command -v awg-quick || true)}"

usage() {
    cat <<'EOF'
Usage: amneziawg-bitrate-test.sh [options]

Tests every AmneziaWG config and ranks them by bitrate stability.

Options:
  --config-dir DIR       Directory with *.conf files (default: ~/amnezia)
  --mode upload|download Measured direction (default: upload)
  --duration SEC         Measurement time per config (default: 60)
  --warmup SEC           Wait after connect before measuring (default: 5)
  --interval SEC         Sampling interval (default: 1)
  --target-mbps Mbps     Bitrate threshold for drops (default: 8)
  --url URL              Probe URL. Defaults:
                          upload:   https://speed.cloudflare.com/__up
                          download: https://speed.cloudflare.com/__down?bytes=250000000
  --keep-connected       Leave the best config connected at the end
  --leave-disconnected   Do not restore the config that was active before test
  -h, --help             Show this help

Examples:
  amneziawg-bitrate-test.sh --target-mbps 12 --duration 120
  amneziawg-bitrate-test.sh --mode download --target-mbps 40

Notes:
  For YouTube streaming, upload mode is the useful one. It sends a constant
  stream at target-mbps and checks whether the VPN can keep up.
EOF
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

notify() {
    notify-send "VPN bitrate test" "$1" 2>/dev/null || true
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return
    fi

    if sudo -n true 2>/dev/null; then
        sudo "$@"
        return
    fi

    if command -v pkexec >/dev/null 2>&1; then
        pkexec "$@"
        return
    fi

    sudo "$@"
}

run_awg_quick() {
    run_as_root "$awg_quick" "$@"
}

restore_initial_on_interrupt() {
    printf '\nInterrupted, restoring previous VPN state...\n' >&2
    pkill -P "$$" 2>/dev/null || true
    if [ -n "${initial_active:-}" ] && [ "$leave_disconnected" -eq 0 ]; then
        down_active >/dev/null 2>&1 || true
        run_awg_quick up "$config_dir/$initial_active.conf" >/dev/null 2>&1 || true
    fi
    exit 130
}

active_interfaces() {
    find "$config_dir" -maxdepth 1 -type f -name "*.conf" -printf "%f\n" 2>/dev/null |
        sed 's|\.conf$||' |
        while IFS= read -r interface; do
            [ -e "/sys/class/net/$interface" ] && printf '%s\n' "$interface"
        done
}

down_active() {
    local failed=0 interface

    while IFS= read -r interface; do
        if ! run_awg_quick down "$config_dir/$interface.conf" >/dev/null 2>&1 &&
            ! run_awg_quick down "$interface" >/dev/null 2>&1; then
            failed=1
        fi
    done < <(active_interfaces)

    return "$failed"
}

metric_file() {
    local interface="$1"

    case "$mode" in
        upload) printf '/sys/class/net/%s/statistics/tx_bytes\n' "$interface" ;;
        download) printf '/sys/class/net/%s/statistics/rx_bytes\n' "$interface" ;;
        *) die "unknown mode: $mode" ;;
    esac
}

start_probe() {
    local out="$1"
    local bytes_per_sec total_bytes max_time

    case "$mode" in
        upload)
            bytes_per_sec="$(awk -v m="$target_mbps" 'BEGIN { printf "%d", (m * 1000000) / 8 }')"
            total_bytes="$(awk -v b="$bytes_per_sec" -v d="$duration" 'BEGIN { printf "%d", b * d }')"
            max_time=$((duration + duration / 3 + 15))
            (
                head -c "$total_bytes" /dev/zero |
                    pv -q -L "$bytes_per_sec" |
                    curl -fsS --http1.1 --max-time "$max_time" \
                        -X POST --data-binary @- "$url" \
                        -o /dev/null
            ) >"$out" 2>&1 &
            ;;
        download)
            curl -fsS --max-time "$duration" "$url" \
                -o /dev/null >"$out" 2>&1 &
            ;;
    esac
    PROBE_PID="$!"
}

measure_interface() {
    local interface="$1"
    local samples_file="$2"
    local curl_log="$3"
    local meta_file="$4"
    local stat_file before after mbps probe_pid i max_seconds start_ts end_ts elapsed exit_status sample_count

    stat_file="$(metric_file "$interface")"
    [ -r "$stat_file" ] || die "cannot read interface stats: $stat_file"

    : >"$samples_file"
    : >"$meta_file"
    start_probe "$curl_log"
    probe_pid="$PROBE_PID"

    before="$(cat "$stat_file")"
    start_ts="$(date +%s)"
    max_seconds=$((duration + duration / 3 + 20))
    i=0
    while kill -0 "$probe_pid" 2>/dev/null && [ "$i" -lt "$max_seconds" ]; do
        sleep "$interval"
        after="$(cat "$stat_file")"
        mbps="$(awk -v b="$before" -v a="$after" -v s="$interval" 'BEGIN { printf "%.3f", ((a - b) * 8) / s / 1000000 }')"
        printf '%s\n' "$mbps" >>"$samples_file"
        before="$after"
        i=$((i + interval))
    done

    if kill -0 "$probe_pid" 2>/dev/null; then
        kill "$probe_pid" >/dev/null 2>&1 || true
        wait "$probe_pid" >/dev/null 2>&1 || true
        exit_status=124
    else
        wait "$probe_pid" >/dev/null 2>&1
        exit_status="$?"
    fi

    end_ts="$(date +%s)"
    elapsed=$((end_ts - start_ts))
    sample_count="$(wc -l <"$samples_file")"
    printf 'exit_status=%s\nelapsed=%s\nsamples=%s\n' "$exit_status" "$elapsed" "$sample_count" >"$meta_file"
}

summarize_samples() {
    local config="$1"
    local samples_file="$2"
    local meta_file="$3"
    local exit_status elapsed samples expected_samples min_samples status

    exit_status="$(awk -F= '$1 == "exit_status" { print $2 }' "$meta_file" 2>/dev/null)"
    elapsed="$(awk -F= '$1 == "elapsed" { print $2 }' "$meta_file" 2>/dev/null)"
    samples="$(awk -F= '$1 == "samples" { print $2 }' "$meta_file" 2>/dev/null)"
    exit_status="${exit_status:-999}"
    elapsed="${elapsed:-0}"
    samples="${samples:-0}"
    expected_samples=$((duration / interval))
    [ "$expected_samples" -lt 1 ] && expected_samples=1
    min_samples=$((expected_samples * 8 / 10))
    [ "$min_samples" -lt 1 ] && min_samples=1

    status="ok"
    if [ "$exit_status" -ne 0 ]; then
        status="probe_failed"
    elif [ "$samples" -lt "$min_samples" ]; then
        status="too_short"
    elif [ "$elapsed" -gt $((duration + duration / 10 + 3)) ]; then
        status="too_slow"
    fi

    awk -v cfg="$config" -v target="$target_mbps" -v status="$status" -v elapsed="$elapsed" '
        NF {
            samples[++n] = $1
            sum += $1
            if (n == 1 || $1 < min) min = $1
            if ($1 < target) drops++
        }
        END {
            if (n == 0) {
                printf "%s\t%s\t0\t0\t0\t0\t100.0\t%s\t999999\n", cfg, status, elapsed
                exit
            }

            for (i = 1; i <= n; i++) {
                for (j = i + 1; j <= n; j++) {
                    if (samples[j] < samples[i]) {
                        tmp = samples[i]
                        samples[i] = samples[j]
                        samples[j] = tmp
                    }
                }
            }

            avg = sum / n
            p05_idx = int(n * 0.05)
            if (p05_idx < 1) p05_idx = 1
            p95_idx = int(n * 0.95)
            if (p95_idx < 1) p95_idx = 1
            if (p95_idx > n) p95_idx = n

            for (i = 1; i <= n; i++) {
                diff = samples[i] - avg
                variance += diff * diff
            }
            stdev = sqrt(variance / n)
            drop_pct = drops * 100 / n

            # Lower score is better. For rate-limited upload, elapsed time is
            # the primary signal; per-second tx_bytes can be bursty because of
            # userspace/TCP buffering, so jitter is only a tie-breaker.
            score = elapsed + (stdev * 0.1)
            if (status != "ok") score += 500000
            if (status == "too_slow") score += 100000
            printf "%s\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%.1f\t%s\t%.3f\n", cfg, status, avg, min, samples[p05_idx], stdev, drop_pct, elapsed, score
        }
    ' "$samples_file"
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --config-dir) config_dir="$2"; shift 2 ;;
            --mode) mode="$2"; shift 2 ;;
            --duration) duration="$2"; shift 2 ;;
            --warmup) warmup="$2"; shift 2 ;;
            --interval) interval="$2"; shift 2 ;;
            --target-mbps) target_mbps="$2"; shift 2 ;;
            --url) url="$2"; shift 2 ;;
            --keep-connected) keep_connected=1; shift ;;
            --leave-disconnected) leave_disconnected=1; shift ;;
            -h|--help) usage; exit 0 ;;
            *) die "unknown argument: $1" ;;
        esac
    done
}

parse_args "$@"

[ -n "$awg_quick" ] || die "awg-quick not found in PATH"
[ -d "$config_dir" ] || die "config dir not found: $config_dir"
command -v curl >/dev/null 2>&1 || die "curl not found"
command -v awk >/dev/null 2>&1 || die "awk not found"
if [ "$mode" = "upload" ]; then
    command -v pv >/dev/null 2>&1 || die "pv not found"
fi

case "$mode" in
    upload) url="${url:-https://speed.cloudflare.com/__up}" ;;
    download) url="${url:-https://speed.cloudflare.com/__down?bytes=250000000}" ;;
    *) die "mode must be upload or download" ;;
esac

mkdir -p "$log_dir" || die "cannot create log dir: $log_dir"
run_id="$(date '+%Y%m%d-%H%M%S')"
result_file="$log_dir/results-$run_id.tsv"
summary_file="$log_dir/summary-$run_id.tsv"

mapfile -t configs < <(find "$config_dir" -maxdepth 1 -type f -name "*.conf" -printf "%f\n" 2>/dev/null | sort)
[ "${#configs[@]}" -gt 0 ] || die "no *.conf files in $config_dir"

initial_active="$(active_interfaces | head -1)"
trap restore_initial_on_interrupt INT TERM HUP

printf 'config\tstatus\tavg_mbps\tmin_mbps\tp05_mbps\tstdev_mbps\tdrop_pct\telapsed_sec\tscore\n' >"$result_file"

printf 'Testing %d configs from %s (%s, target %.3f Mbps)\n' "${#configs[@]}" "$config_dir" "$mode" "$target_mbps"
notify "Starting ${#configs[@]} config tests"

for config_file in "${configs[@]}"; do
    config="${config_file%.conf}"
    config_path="$config_dir/$config_file"
    samples_file="$log_dir/samples-$run_id-$config.tsv"
    curl_log="$log_dir/curl-$run_id-$config.log"
    meta_file="$log_dir/meta-$run_id-$config.env"

    printf '\n==> %s\n' "$config"

    if ! down_active; then
        printf 'warning: failed to disconnect active configs before %s\n' "$config" >&2
    fi

    if ! run_awg_quick up "$config_path" >/dev/null 2>&1; then
        printf '%s\tconnect_failed\t0\t0\t0\t0\t100.0\t0\t999999\n' "$config" >>"$result_file"
        printf 'connect failed\n'
        continue
    fi

    sleep "$warmup"

    if [ ! -e "/sys/class/net/$config" ]; then
        printf '%s\tno_interface\t0\t0\t0\t0\t100.0\t0\t999999\n' "$config" >>"$result_file"
        printf 'interface did not appear: %s\n' "$config"
        run_awg_quick down "$config_path" >/dev/null 2>&1 || true
        continue
    fi

    measure_interface "$config" "$samples_file" "$curl_log" "$meta_file"
    summarize_samples "$config" "$samples_file" "$meta_file" | tee -a "$result_file"

    run_awg_quick down "$config_path" >/dev/null 2>&1 || true
done

{
    head -n 1 "$result_file"
    tail -n +2 "$result_file" | sort -t "$(printf '\t')" -k9,9n
} >"$summary_file"

printf '\nRanked results:\n'
column -t -s "$(printf '\t')" "$summary_file" 2>/dev/null || cat "$summary_file"

best="$(awk 'NR > 1 && $2 == "ok" { print $1; exit }' "$summary_file")"
if [ -n "$best" ] && [ "$keep_connected" -eq 1 ]; then
    down_active >/dev/null 2>&1 || true
    if run_awg_quick up "$config_dir/$best.conf" >/dev/null 2>&1; then
        printf '\nLeft connected: %s\n' "$best"
    else
        printf '\nBest config found, but reconnect failed: %s\n' "$best" >&2
    fi
elif [ -n "$initial_active" ] && [ "$leave_disconnected" -eq 0 ]; then
    down_active >/dev/null 2>&1 || true
    if run_awg_quick up "$config_dir/$initial_active.conf" >/dev/null 2>&1; then
        printf '\nRestored initially active config: %s\n' "$initial_active"
    else
        printf '\nInitial config found, but restore failed: %s\n' "$initial_active" >&2
    fi
else
    down_active >/dev/null 2>&1 || true
fi

printf '\nSaved:\n  %s\n  %s\n' "$result_file" "$summary_file"
