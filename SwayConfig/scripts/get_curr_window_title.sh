#!/bin/bash

TITLE=$(swaymsg -t get_tree | jq -r '
  .. | select(.type?) | select(.focused == true) |
  "\(.name) [\(.app_id // .window_properties.instance // .window_properties.class)]"
  ')
echo " $TITLE"
