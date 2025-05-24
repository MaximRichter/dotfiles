#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vpn_moscow='cd /etc/openvpn/ && sudo openvpn --config "Russia, Moscow Y2.ovpn"'
PS1='[\u@\h \W]\$ '
