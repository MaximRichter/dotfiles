#!/usr/bin/env bash

set -u

find_window() {
    local app_id="$1"
    local title_pattern="${2:-}"
    local windows_json

    windows_json="$(niri msg --json windows)" || return 1

    if [[ -n "$title_pattern" ]]; then
        jq -r --arg app_id "$app_id" --arg title "$title_pattern" \
            '.[] | select(.app_id == $app_id and (.title | test($title))) | .id' \
            <<<"$windows_json" | head -n 1
    else
        jq -r --arg app_id "$app_id" \
            '.[] | select(.app_id == $app_id) | .id' \
            <<<"$windows_json" | head -n 1
    fi
}

wait_for_window() {
    local app_id="$1"
    local title_pattern="$2"
    local id
    local attempt

    for ((attempt = 0; attempt < 300; attempt++)); do
        id="$(find_window "$app_id" "$title_pattern")"
        if [[ -n "$id" ]]; then
            printf '%s\n' "$id"
            return 0
        fi
        sleep 0.1
    done

    return 1
}

place_window_id() {
    local id="$1"
    local output="$2"
    local workspace="$3"
    local column="$4"
    local width="$5"

    [[ -n "$id" ]] || return 0

    niri msg action move-window-to-monitor --id "$id" "$output" >/dev/null
    niri msg action move-window-to-workspace --window-id "$id" --focus=false "$workspace" >/dev/null
    niri msg action focus-window --id "$id" >/dev/null
    niri msg action set-column-width "$width" >/dev/null
    niri msg action move-column-to-index "$column" >/dev/null
}

place_or_launch() {
    local app_id="$1"
    local title_pattern="$2"
    local output="$3"
    local workspace="$4"
    local column="$5"
    local width="$6"
    local id
    shift 6

    id="$(find_window "$app_id" "$title_pattern")"
    if [[ -z "$id" ]]; then
        "$@" >/dev/null 2>&1 &
        id="$(wait_for_window "$app_id" "$title_pattern")" || {
            notify-send "niri" "Не удалось дождаться окна: $app_id" -t 3000
            return 0
        }
    fi

    place_window_id "$id" "$output" "$workspace" "$column" "$width"
}

place_existing() {
    local app_id="$1"
    local title_pattern="$2"
    local output="$3"
    local workspace="$4"
    local column="$5"
    local width="$6"
    local id

    id="$(find_window "$app_id" "$title_pattern")"
    place_window_id "$id" "$output" "$workspace" "$column" "$width"
}

place_spotify_player() {
    local id

    # Keep using the existing terminal from the captured layout. Once it is
    # closed, create a dedicated, easily identifiable spotify_player window.
    id="$(find_window "spotify-player" "")"
    if [[ -z "$id" ]]; then
        id="$(find_window "foot" "^~ - fish$")"
    fi
    if [[ -z "$id" ]]; then
        foot --app-id=spotify-player -e spotify_player >/dev/null 2>&1 &
        id="$(wait_for_window "spotify-player" "")" || {
            notify-send "niri" "Не удалось запустить spotify_player" -t 3000
            return 0
        }
    fi

    place_window_id "$id" "DP-2" 1 2 "33.33%"
}

# DP-1, workspace 1: Steam (1/2), Lutris (1/4).
place_or_launch "steam" "" "DP-1" 1 1 "50%" steam
place_or_launch "net.lutris.Lutris" "" "DP-1" 1 2 "25%" lutris

# DP-1, workspace 2: Emacs (2/3).
place_or_launch "Emacs" "" "DP-1" 2 1 "66.67%" emacs

# DP-1, workspace 3: Zen (2/3), existing terminal (1/3).
place_or_launch "zen" "" "DP-1" 3 1 "66.67%" zen-browser
place_existing "foot" "richter" "DP-1" 3 2 "33.33%"

# DP-1, workspace 4: Anki (2/3).
place_or_launch "anki" "" "DP-1" 4 1 "66.67%" anki

# DP-2, workspace 1: Vesktop (2/3), spotify_player (1/3).
place_or_launch "vesktop" "" "DP-2" 1 1 "66.67%" vesktop
place_spotify_player

# DP-2, workspace 2: OBS and qpwgraph (1/2 each).
place_or_launch "com.obsproject.Studio" "" "DP-2" 2 1 "50%" obs
place_or_launch "org.rncbc.qpwgraph" "" "DP-2" 2 2 "50%" qpwgraph

# DP-2, workspace 3: AmneziaVPN (fixed 600 logical pixels).
place_or_launch "AmneziaVPN" "" "DP-2" 3 1 "600" AmneziaVPN

# Finish on the main workspaces of both monitors. Focus Discord first so DP-2
# keeps its Discord workspace active, then Steam so global focus ends on DP-1.
steam_id="$(find_window "steam" "")"
discord_id="$(find_window "vesktop" "")"
[[ -n "$discord_id" ]] && niri msg action focus-window --id "$discord_id" >/dev/null
[[ -n "$steam_id" ]] && niri msg action focus-window --id "$steam_id" >/dev/null

notify-send "niri" "Раскладка окон восстановлена" -t 1800
