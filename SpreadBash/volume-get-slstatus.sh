VOL="🔈$(amixer get Master | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')"
echo $VOL
