#!/usr/bin/env bash

if ! hyprlock; then
  swaylock \
    --ignore-empty-password \
    --daemonize \
    --show-keyboard-layout \
    --color=222222 \
    --line-uses-inside \
    --inside-color=222222 \
    --layout-bg-color=00000000
  sleep 1
  #systemctl suspend
fi
