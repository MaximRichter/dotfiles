function vpn_offenbach --wraps='cd /etc/openvpn/ && sudo openvpn --config "Germany, Offenbach S1.ovpn"' --description 'alias vpn_offenbach=cd /etc/openvpn/ && sudo openvpn --config "Germany, Offenbach S1.ovpn"'
  cd /etc/openvpn/ && sudo openvpn --config "Germany, Offenbach S1.ovpn" $argv
        
end
