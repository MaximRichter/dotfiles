function vpn_moscow --wraps='cd /etc/openvpn/ && sudo openvpn --config "Russia, Moscow Y2.ovpn"' --description 'alias vpn_moscow=cd /etc/openvpn/ && sudo openvpn --config "Russia, Moscow Y2.ovpn"'
  cd /etc/openvpn/ && sudo openvpn --config "Russia, Moscow Y2.ovpn" $argv
        
end
