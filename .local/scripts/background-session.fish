#!/usr/bin/env fish
# Fish script для создания tmux сессии "background" с предустановленными окнами

set -l SESSION_NAME "background"

# Проверка, существует ли уже сессия
set -l SESSION_EXISTS (tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -q "^$SESSION_NAME\$" && echo "yes" || echo "no")

if test "$SESSION_EXISTS" = "no"
    # Создаем новую сессию с первым окном VPN
    tmux new-session -d -s $SESSION_NAME -n "VPN"
    
    # Отправляем команду в окно VPN
    tmux send-keys -t "$SESSION_NAME:VPN" "cd /etc/openvpn/other\\ os/" Enter
    
    # Создаем окно Zapret
    tmux new-window -t "$SESSION_NAME" -n "Zapret"
    tmux send-keys -t "$SESSION_NAME:Zapret" "zapret" Enter
    
    # Создаем окно GTNH
    tmux new-window -t "$SESSION_NAME" -n "GTNH"
    tmux send-keys -t "$SESSION_NAME:GTNH" "cd ~/shed/games/minecraft/gtnh/" Enter

    # Создаем окно Spotify-player
    tmux new-window -t "$SESSION_NAME" -n "Spotify"
    tmux send-keys -t "$SESSION_NAME:Spotify" "spotify_player" Enter

end

# Подключаемся к сессии
tmux attach-session -t $SESSION_NAME
