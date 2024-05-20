VOL="🔈 $(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')"
LOCALTIME=$(date "+%H:%M:%S %m/%d") 
OTHERTIME=$(TZ=Europe/London date +%Z\=%H:%M)
IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1) # can get confused if you use vmware
TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))C"

if [[ $(acpi -a | awk '{ print $3 }') = "on-line" ]]; then
    BATPRE="🔌"
else
    BATPRE="🔋"
fi
BAT="$BATPRE $(acpi -b | awk '{ print $NF }' | tr -d ',')"
xsetroot -name "$BAT | $VOL | $LOCALTIME"
