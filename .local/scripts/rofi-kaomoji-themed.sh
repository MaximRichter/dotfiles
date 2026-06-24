#!/usr/bin/sh

moji_path="/usr/share/rofi-kaomoji/KAOMOJIS.md"
rofi_theme="$HOME/.config/rofi/launchers/type-4/style-9.rasi"
categories=$(grep '^# ' "$moji_path" | cut -c3-)

kb_select_random="Control+Return"
kb_delete_previous="Control+d"

rofi_menu() {
  rofi -dmenu -i -theme "$rofi_theme" "$@"
}

category_menu() {
  category=$(echo "$categories" |
    rofi_menu -theme-str '#entry { placeholder: "Choose kaomoji:"; }' \
      -mesg "$kb_select_random - select random; $kb_delete_previous - delete previous" \
      -kb-accept-custom "" \
      -kb-custom-1 "$kb_select_random" \
      -kb-remove-char-forward "" \
      -kb-custom-2 "$kb_delete_previous")

  rofi_exit=$?

  [ "$rofi_exit" -eq 1 ] && exit

  case "$rofi_exit" in
    10) kaomoji_menu "$category" t ;;
    11) delete_previous ;;
    0) kaomoji_menu "$category" ;;
    *) exit ;;
  esac
}

delete_previous() {
  line="$(grep --line-number --fixed-strings "$(wl-paste -n)" "$moji_path" |
    cut -d: -f 1)"

  [ -n "$line" ] && sed --follow-symlinks -i "${line}d" "$moji_path"
}

kaomoji_menu() {
  category="$1"
  random="$2"

  kaomojis=$(awk "/^# $1/ {flag=1; next} /^# [a-zA-Z]/ {flag=0} flag" "$moji_path")
  kaomojis="${kaomojis}
back"

  if [ -n "$random" ]; then
    echo "$kaomojis" | head -n -1 | shuf -n 1 | wl-copy -n
    exit 0
  fi

  selection=$(echo "$kaomojis" | rofi_menu -p "$category")

  if [ "$selection" = "back" ]; then
    category_menu
  else
    wl-copy -n "$selection"
  fi
}

category_menu
