#!/bin/bash
# GPU Monitor — логирует состояние GPU каждую секунду
# Использование: ./gpu-monitor.sh [интервал_секунд]
# По умолчанию: 1 секунда
# Лог: ~/gpu-monitor.log

INTERVAL="${1:-1}"
LOGFILE="$HOME/gpu-monitor.log"
HWMON="/sys/class/drm/card1/device/hwmon/hwmon4"
GPU="/sys/class/drm/card1/device"

echo "=== GPU Monitor started at $(date) ===" | tee "$LOGFILE"
echo "Interval: ${INTERVAL}s" | tee -a "$LOGFILE"
echo "Power limit: $(cat $HWMON/power1_cap 2>/dev/null)uW" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Header
printf "%-19s | %7s | %7s | %7s | %7s | %8s | %8s | %4s\n" \
    "Timestamp" "Edge°C" "Junc°C" "Mem°C" "PowerW" "GFX_MHz" "MEM_MHz" "Busy" | tee -a "$LOGFILE"
printf -- "%.0s-" {1..95} | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

while true; do
    TS=$(date '+%H:%M:%S.%3N')

    # Temperatures (millidegrees → degrees)
    EDGE=$(cat "$HWMON/temp1_input" 2>/dev/null || echo 0)
    JUNC=$(cat "$HWMON/temp2_input" 2>/dev/null || echo 0)
    MEM=$(cat "$HWMON/temp3_input" 2>/dev/null || echo 0)
    EDGE=$((EDGE / 1000))
    JUNC=$((JUNC / 1000))
    MEM=$((MEM / 1000))

    # Power (microwatts → watts)
    POWER=$(cat "$HWMON/power1_average" 2>/dev/null || cat "$HWMON/power1_input" 2>/dev/null || echo 0)
    POWER_W=$((POWER / 1000000))

    # Clocks
    GFX=$(cat "$GPU/pp_dpm_sclk" 2>/dev/null | grep '\*' | awk '{print $2}' | tr -d 'Mhz')
    MEMCLK=$(cat "$GPU/pp_dpm_mclk" 2>/dev/null | grep '\*' | awk '{print $2}' | tr -d 'Mhz')

    # GPU busy
    BUSY=$(cat "$GPU/gpu_busy_percent" 2>/dev/null || echo "?")

    printf "%-19s | %5d°C | %5d°C | %5d°C | %5dW | %6s | %6s | %3s%%\n" \
        "$TS" "$EDGE" "$JUNC" "$MEM" "$POWER_W" "${GFX:-?}" "${MEMCLK:-?}" "$BUSY" | tee -a "$LOGFILE"

    sleep "$INTERVAL"
done
