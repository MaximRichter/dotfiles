source /usr/share/cachyos-fish-config/cachyos-config.fish

# hellwal
# source ~/.cache/hellwal/variablesfish.fish
# sh ~/.cache/hellwal/terminal.sh

# pywal16
cat ~/.cache/wal/sequences &

# fastfetch
function fish_greeting
  fastfetch --logo ~/wallpapers/banner-fastfetch_5.jpg --color blue
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

# function fish_prompt
#   echo (set_color --bold brgreen)'~'
#   echo (set_color brred)'❯ '
# end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
