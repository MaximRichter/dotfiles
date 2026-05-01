# Dotfiles Improvement Backlog

## High priority

- Replace the `Super+Shift+Q` hard-kill bind with a gentler flow: `forcekillactive` or SIGTERM first, SIGKILL only as a fallback.
- Move machine-specific values into local config/env files: `/home/richter`, monitor names and layout, `enp14s0`, `/etc/openvpn/other os`, `/home/richter/shed`.
- Stop `wal-reload.sh` from editing tracked Waybar JSON files in place. Generate theme/accent data into cache or CSS/template files instead.
- Add timeouts and resilient fallbacks for Waybar network modules: `curl`, `ping`, IMAP, VPN, network interface stats.

## Medium priority

- Split heavy Hyprland autostart entries into user services or conditional launches: `qpwgraph`, ghostty daemon, `qbittorrent`, Emacs daemon.
- Fix contradictory qutebrowser settings, especially `c.content.webgl` being set to both `False` and `True`.
- Add qutebrowser fallback behavior when `~/.cache/wal/colors.json` does not exist yet.
- Make pywal symlinks/install steps more portable for `stow`, especially Mako and Rofi links into `~/.cache/wal`.

## Nice to have

- Add a small validation script for common checks: shell syntax, Lua syntax, Python compile, Waybar JSON.
- Consider documenting local-only assumptions in README instead of requiring manual username replacement.
- Review whether both Waybar configs should always start, or whether monitor detection should choose configs dynamically.
