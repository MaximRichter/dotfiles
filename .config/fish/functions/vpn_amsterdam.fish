function vpn_amsterdam --wraps='cd /etc/openvpn/ && sudo openvpn --config "Netherlands, Amsterdam S14.ovpn"' --description 'alias vpn_amsterdam=cd /etc/openvpn/ && sudo openvpn --config "Netherlands, Amsterdam S14.ovpn"'
  cd /etc/openvpn/ && sudo openvpn --config "Netherlands, Amsterdam S14.ovpn" $argv
        
end
