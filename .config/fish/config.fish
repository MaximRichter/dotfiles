source /usr/share/cachyos-fish-config/cachyos-config.fish

# hellwal
# source ~/.cache/hellwal/variablesfish.fish
# sh ~/.cache/hellwal/terminal.sh

# pywal16
if status is-interactive
    cat ~/.cache/wal/sequences &
end

# fastfetch
function fish_greeting
    set hex (grep "^color14=" ~/.cache/wal/colors.sh 2>/dev/null | cut -d"'" -f2 | string replace '#' '')
    if test -n "$hex"
        set r (printf "%d" 0x(string sub -s 1 -l 2 $hex))
        set g (printf "%d" 0x(string sub -s 3 -l 2 $hex))
        set b (printf "%d" 0x(string sub -s 5 -l 2 $hex))
        fastfetch --color "38;2;$r;$g;$b"
    else
        fastfetch --color blue
    end
end

# Yazi function 
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

set -Ux fzf_fd_opts --hidden --exclude=.git

set PATH "$PATH":"$HOME/.local/scripts/"
bind \cf "tmux-sessionizer"

# zoxide
zoxide init fish | source

# starship prompts
starship init fish | source

# function fish_prompt
#   echo (set_color --bold brgreen)'~'
#   echo (set_color brred)'❯ '
# end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
