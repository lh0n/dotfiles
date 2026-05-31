#!/bin/bash

event=$1

monitor_count=$(hyprctl monitors | grep -c '^Monitor')

case $event in
	open)
		hyprctl keyword monitor "eDP-1,highres,auto,auto"
		;;
	close)
		hyprctl keyword monitor "eDP-1,disable"
		if [ "$monitor_count" = 1 ]; then
			hyprlock
		fi
		;;
esac
