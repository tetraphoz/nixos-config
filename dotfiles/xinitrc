ssh-agent &
dunst -b &
wmname LG3D  &
#syncthing --no-browser &
xset r rate 200 60 &
setxkbmap us altgr-intl &

#xrandr --setprovideroutputsource modesetting NVIDIA-0 #PRIME
#xrandr --setprovideroutputsource NVIDIA-G0 modesetting #Reverse PRIME

#xrandr --setprovideroffloadsink NVIDIA-0 modesetting # PRIME GPU Offload
xrandr --auto
xrandr --dpi 142

wal -R &
xsettingsd &
picom &
redshift -l 25.686613:-100.316116 &
if [ -x /usr/bin/gpg-agent ]; then
 eval "$(/usr/bin/gpg-agent --daemon)"
fi
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
#dbus-launch --exit-with-session stumpwm

gentoo-pipewire-launcher &
xidlehook --not-when-fullscreen --not-when-audio --timer "normal" 60 "slock" '' &
# MPD daemon start (if no other user instance exists)

/usr/libexec/polkit-gnome-authentication-agent-1 &
[ ! -s ~/.config/mpd/pid ] && mpd &

exec dbus-launch --exit-with-session xmonad
