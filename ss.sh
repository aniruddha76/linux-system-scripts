#!/bin/bash

# === CONFIG ===
WEBHOOK_URL="https://discord.com/api/webhooks/1427639468101337209/ckDi9HD9IUCbK8ofYn-0awl7aPNCOBZRytnRupZL3DZXx3UaS_igR1KFyXNjI3Wl4BEf"  # Replace this
SAVE_DIR="$HOME/Pictures"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
FILEPATH="$SAVE_DIR/$FILENAME"

# === TAKE SCREENSHOT ===
grimblast --notify copysave screen "$FILEPATH"

# === CHECK IF FILE EXISTS ===
if [ ! -f "$FILEPATH" ]; then
  echo "Screenshot failed!"
  exit 1
fi

# === SEND TO DISCORD ===
curl -F "file=@$FILEPATH" \
     -F "payload_json={\"content\":\"📸 Screenshot taken on $(uname -n)\"}" \
     "$WEBHOOK_URL"

# === OPTIONAL: Notify user locally ===
notify-send "📤 Screenshot uploaded to Discord" "$FILENAME"

