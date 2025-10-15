#!/bin/bash
# === CONFIG ===
WEBHOOK_URL="https://discord.com/api/webhooks/1427901803101556868/ymRWB-jseMHoouNJDkP77LNwqxiMiB-XDNesM5vqEbCygPRgW3omySVLmU5_YS_xIl36"
LOAD_THRESHOLD=8.0     # System load average threshold
CHECK_INTERVAL=20       # Seconds between checks
HOSTNAME=$(uname -n)

# === MONITOR LOOP ===
while true; do
  DATE_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  LOAD_AVG=$(awk '{print $1}' /proc/loadavg)

  # Trigger only when load average exceeds threshold
  if (( $(echo "$LOAD_AVG > $LOAD_THRESHOLD" | bc -l) )); then
    # === System Stats ===
    CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | tail -n 1 | awk '{print 100 - $8}')
    CPU_INT=${CPU_USAGE%.*}

    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_PERC=$((100 * MEM_USED / MEM_TOTAL))

    DISK_USED=$(df -h / | awk 'NR==2 {print $5}')
    UPTIME=$(uptime -p | sed 's/up //')

    # === Top 5 CPU Processes ===
    TOP_PROCESSES=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu --no-headers | grep -v "ps" | head -n 5)

    # === Build Discord Message ===
    MESSAGE=$(cat <<EOF
⚠️ **High System Load Detected!**

📅 **Date & Time:** $DATE_TIME
🖥️ **Host:** \`$HOSTNAME\`
⚙️ **Uptime:** $UPTIME

**System Health**
> 🔥 **CPU Usage:** ${CPU_INT}%  
> 🧠 **Memory Usage:** ${MEM_PERC}%    
> 📈 **Load Average:** ${LOAD_AVG} *(Threshold: ${LOAD_THRESHOLD})*

**Top 5 CPU Processes**
\`\`\`
  PID   COMMAND         %CPU %MEM
$TOP_PROCESSES
\`\`\`
EOF
)

  # === Send to Discord ===
  SAFE_MESSAGE=$(echo "$MESSAGE" | python3 -c 'import json,sys; print(json.dumps({"content": sys.stdin.read()}))')

  curl -s -H "Content-Type: application/json" \
       -X POST \
       -d "$SAFE_MESSAGE" \
       "$WEBHOOK_URL" >/dev/null
  fi
  sleep $CHECK_INTERVAL
done