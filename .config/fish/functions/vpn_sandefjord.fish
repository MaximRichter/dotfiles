function vpn_sandefjord --wraps='cd /etc/openvpn/ && sudo openvpn --config "Norway, Sandefjord S7.ovpn"' --description 'alias vpn_sandefjord=cd /etc/openvpn/ && sudo openvpn --config "Norway, Sandefjord S7.ovpn"'
    cd /etc/openvpn/ && sudo openvpn --config "Norway, Sandefjord S7.ovpn" $argv
end
