#! /bin/bash
STATUS=$(pamixer --get-volume-human)
VOL=$(pamixer --get-volume)
if [ "$STATUS" == "muted" ]; then
    RES="󰖁 $VOL%"
else
    RES="󰕾 $VOL%"
fi
echo "$RES"

