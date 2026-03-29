#!/bin/bash
# Анализ лога GPU после краша
# Использование: ./gpu-analyze.sh

LOGFILE="$HOME/gpu-monitor.log"

if [ ! -f "$LOGFILE" ]; then
    echo "Лог не найден: $LOGFILE"
    exit 1
fi

echo "=== Последние 20 записей перед крашем ==="
tail -20 "$LOGFILE"

echo ""
echo "=== Максимальные значения за сессию ==="
# Skip header lines, parse data
awk -F'|' 'NR > 4 && NF >= 5 {
    gsub(/[^0-9]/, "", $2); gsub(/[^0-9]/, "", $3);
    gsub(/[^0-9]/, "", $4); gsub(/[^0-9]/, "", $5);
    if ($2+0 > max_edge) max_edge=$2+0;
    if ($3+0 > max_junc) max_junc=$3+0;
    if ($4+0 > max_mem) max_mem=$4+0;
    if ($5+0 > max_power) max_power=$5+0;
    count++;
}
END {
    print "  Записей: " count;
    print "  Макс Edge:     " max_edge "°C";
    print "  Макс Junction: " max_junc "°C";
    print "  Макс Memory:   " max_mem "°C";
    print "  Макс Power:    " max_power "W";
}' "$LOGFILE"

echo ""
echo "=== Моменты пиковой нагрузки (>260W) ==="
awk -F'|' 'NR > 4 && NF >= 5 {
    gsub(/[^0-9]/, "", $5);
    if ($5+0 > 260) print $0;
}' "$LOGFILE" | tail -10

echo ""
echo "=== Резкие скачки мощности (>30W за секунду) ==="
awk -F'|' 'NR > 4 && NF >= 5 {
    gsub(/[^0-9]/, "", $5);
    curr=$5+0;
    if (prev > 0 && (curr-prev > 30 || prev-curr > 30))
        printf "  %s → %sW (Δ%+dW)\n", $1, curr, curr-prev;
    prev=curr;
}' "$LOGFILE" | tail -10
