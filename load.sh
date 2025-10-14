#!/bin/bash

# === CONFIG ===
WEBHOOK_URL="https://discord.com/api/webhooks/1427626484645761228/3QpSjdVsUPn4uzQfNXcAxhvlYsiy0RTFVtbZwUfpdlc3BQMySbMssAtkn8Zwfl92c0q6"  # Replace with your webhook
THRESHOLD=1.0
HOSTNAME=$(uname -n)
LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
IS_HIGH=$(awk -v l="$LOAD_AVG" -v t="$THRESHOLD" 'BEGIN {print (l > t) ? 1 : 0}')

if [ "$IS_HIGH" -eq 1 ]; then
  MESSAGE="⚠️ High Load Alert on $HOSTNAME\nCurrent Load: $LOAD_AVG\nThreshold: $THRESHOLD"
  
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"$MESSAGE\"}" \
       "$WEBHOOK_URL"
fi


