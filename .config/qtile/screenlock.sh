#!/usr/bin/env bash

if ! type dunstctl &> /dev/null; then
  xset s activate
  exit 0
fi

dunstctl set-paused true

sleep 1

# for level in low normal critical; do
#   notify-send -u "${level}" "$(/usr/games/fortune -s)"
# done

xset s activate
dunstctl set-paused false
