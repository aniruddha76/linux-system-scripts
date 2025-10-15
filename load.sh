#!/bin/bash
# === CONFIG ===
WEBHOOK_URL="https://discord.com/api/webhooks/1427901803101556868/ymRWB-jseMHoouNJDkP77LNwqxiMiB-XDNesM5vqEbCygPRgW3omySVLmU5_YS_xIl36"
THRESHOLD=50   # CPU usage threshold %
CHECK_INTERVAL=10  # seconds between checks

HOSTNAME=$(uname -n)

while true; do
  # Get average CPU usage (skip first line as it's often stale)
  CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | tail -n 1 | awk '{print 100 - $8}')
  CPU_INT=${CPU_USAGE%.*}

  if (( CPU_INT > THRESHOLD )); then
    # Get top 5 CPU-consuming processes
    TOP_PROCESSES=$(ps -eo pid,comm,%cpu --sort=-%cpu --no-headers | grep -v "ps" | head -n 5)

    # Build Discord-safe JSON message
    MESSAGE=$(cat <<EOF
⚠️ **High CPU Usage Alert** ⚠️

**Host:** $HOSTNAME
**CPU Usage:** ${CPU_INT}%
**Threshold:** ${THRESHOLD}%
**Top CPU Processes:**
\`\`\`
$TOP_PROCESSES
\`\`\`
EOF
)

    # Escape message for JSON (convert newlines → \n, escape quotes)
    SAFE_MESSAGE=$(echo "$MESSAGE" | python3 -c 'import json,sys; print(json.dumps({"content": sys.stdin.read()}))')

    # Send alert
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "$SAFE_MESSAGE" \
         "$WEBHOOK_URL"
  fi

  sleep $CHECK_INTERVAL
done