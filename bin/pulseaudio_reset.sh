#!/bin/bash

#set -x  # verbose
set -e  # stop on error

echo "Show status for pulseaudio unit"
echo "================================================================================"
systemctl --full --no-pager --user status pulseaudio
echo

echo "Show current logs:"
echo "================================================================================"
echo
journalctl --full --no-pager --boot --user-unit pulseaudio
echo "End of logs"
echo

echo "Stopping pulseaudio daemon"
echo "================================================================================"
systemctl --user stop pulseaudio.service
systemctl --user stop pulseaudio.socket
sleep 5
echo

now="$(date +"%Y-%m-%d_%H%M%S")"

echo "Copy existing pulse configs to bkp location"
echo "================================================================================"
mkdir -vp ~/tmp/bkp
rsync -av ~/.config/pulse ~/tmp/bkp/config_pulse_${now}
echo

echo "Move existing and potentially corrupt configs"
echo "================================================================================"
mkdir -vp ~/tmp
mv -v ~/.config/pulse ~/tmp/config_pulse_${now}
echo

echo "Starting pulseaudio again"
echo "================================================================================"
systemctl --user start pulseaudio
sleep 5
echo

echo "Show status for pulseaudio unit"
echo "================================================================================"
systemctl --full --no-pager --user status pulseaudio
echo

echo "Show current logs:"
echo "================================================================================"
echo
journalctl --full --no-pager --boot --user-unit pulseaudio
echo "End of logs"
echo "================================================================================"
echo
