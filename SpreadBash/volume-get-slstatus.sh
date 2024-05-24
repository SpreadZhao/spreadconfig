#! /bin/bash
VOL=$(amixer sget Master | tail -1 | awk '{print $5 }' | sed "s@\\(\\[\\|\\]\\)@@g")
VOLSTATUS=$(amixer sget Master | tail -1 | awk '{print $6 }' | sed "s@\\(\\[\\|\\]\\)@@g")
if [ "$VOLSTATUS" == "on" ]; then
    RES="󰕾 $VOL"
else
    RES="󰖁 $VOL"
fi
# echo "$RES"
# VOL="🔈$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')"
printf '%s\n' "$RES"
