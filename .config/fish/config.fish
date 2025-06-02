source /usr/share/cachyos-fish-config/cachyos-config.fish

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

# function fish_prompt
#   echo (set_color --bold brgreen)'~'
#   echo (set_color brred)'❯ '
# end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
