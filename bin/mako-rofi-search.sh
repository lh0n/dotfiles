#!/usr/bin/env bash

# Inject local bin so Niri can find makoctl
export PATH="$HOME/.local/bin:$PATH"

# 1. Grab the raw JSON history
HISTORY_JSON=$(makoctl history -j)

# 2. Failsafe
if [ "$HISTORY_JSON" == "[]" ] || [ -z "$HISTORY_JSON" ]; then
    notify-send -u low -t 2000 "Clipboard" "Notification history is empty."
    exit 0
fi

# 3. Format JSON for Rofi with Pango Markup and a Null-Byte separator.
SELECTION=$(echo "$HISTORY_JSON" | jq -jr '
  (if type == "object" and has("data") then .data[0] elif type == "array" then . else [] end) |
  .[] |
  "\(.id) | <b>\(.app_name // "System") | \(.summary // "No Summary")</b>\n" +
  "<span size=\"small\" color=\"#aaaaaa\">  ↳ \(.body // "" | gsub("\n"; " ") | .[0:100])...</span>\u0000"
' | rofi -dmenu -i -markup-rows -sep '\x00' -eh 2 -p "📋 History" -w 800 -l 8)

# 4. Exit if escaped
if [ -z "$SELECTION" ]; then
    exit 0
fi

# 5. Extract the ID safely (only read the first line of the selection!)
TARGET_ID=$(echo "$SELECTION" | awk 'NR==1 {print $1}')

# 6. Pull the full text for copying
CONTENT=$(echo "$HISTORY_JSON" | jq -r --arg id "$TARGET_ID" '
  (if type == "object" and has("data") then .data[0] elif type == "array" then . else [] end) |
  map(select(.id == ($id | tonumber))) | .[0] |
  .summary as $s | .body as $b |
  if ($b | type == "string" and length > 0) then "\($s)\n\n\($b)" else $s end
')

# 7. Copy and Confirm
printf "%s" "$CONTENT" | wl-copy
notify-send -a "clipboard-helper" -u low -t 2000 "Copied to Clipboard!" "$CONTENT"
