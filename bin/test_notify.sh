#!/usr/bin/env bash

# Clear the screen of existing notifications first
makoctl dismiss -a

echo "Sending Low Urgency..."
notify-send -a "clipboard-helper" -u low "Low Urgency" "This is a subtle update.\nIt usually has a darker border and fades quickly."

sleep 1.5

echo "Sending Normal Urgency..."
notify-send -a "clipboard-helper" -u normal "Normal Urgency" "This is your standard notification.\nUsed for emails, messages, and general info."

sleep 1.5

echo "Sending Critical Urgency..."
notify-send -a "clipboard-helper" -u critical "Critical Urgency!" "This is a high-priority alert.\nIt should use your custom red styling and stay on screen until dismissed."

sleep 1.5

# Bonus: Testing the grouping counter we set up earlier
echo "Testing App Grouping..."
notify-send -a "Google Chrome" "Jane Doe" "chat.google.com\n\nHey, are we still on for tomorrow?"
notify-send -a "Google Chrome" "John Smith" "chat.google.com\n\nDid you see the new commit?"

echo "All test notifications sent!"
