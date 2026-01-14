#!/usr/bin/bash

MEM_USAGE=$(free -m | awk 'NR==2{printf "%.1f\n", $3*100/$2 }')
echo "$MEM_USAGE"
