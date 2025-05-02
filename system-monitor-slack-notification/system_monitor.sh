#!/bin/bash

# System Monitoring Script with Slack Alerting
# Monitors CPU and Memory usage, sends alerts to Slack webhook if thresholds are exceeded
# Includes hostname, IP, threshold details, and top 5 processes for CPU or memory

# Configuration
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" # Replace with your Slack webhook URL
CPU_THRESHOLD=80  # CPU usage percentage threshold
MEM_THRESHOLD=80  # Memory usage percentage threshold
CHECK_INTERVAL=60 # Interval between checks in seconds

# Log file for monitoring
LOG_FILE="/var/log/system_monitor.log"

# Function to get system details
get_system_details() {
    HOSTNAME=$(hostname)
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
}

# Function to get CPU usage
get_cpu_usage() {
    CPU_USAGE=$(top -bn1 | head -n 3 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
    echo $CPU_USAGE
}

# Function to get top 5 CPU-consuming processes
get_top_cpu_processes() {
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6 | tail -n 5
}

# Function to get memory usage
get_mem_usage() {
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))
    echo $MEM_USAGE
}

# Function to get top 5 memory-consuming processes
get_top_mem_processes() {
    ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6 | tail -n 5
}

# Function to send Slack alert
send_slack_alert() {
    local MESSAGE=$1
    local COLOR=$2
    local PAYLOAD=$(cat <<EOI
{
  "attachments": [
    {
      "color": "$COLOR",
      "text": "$MESSAGE"
    }
  ]
}
EOI
)
    curl -s -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL" > /dev/null
}

# Function to log messages
log_message() {
    local MESSAGE=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOG_FILE"
}

# Main monitoring loop
while true; do
    get_system_details

    # Check CPU usage
    CPU_USAGE=$(get_cpu_usage)
    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        TOP_PROCESSES=$(get_top_cpu_processes | awk '{printf "PID: %s, PPID: %s, CMD: %s, CPU: %s%%\n", $1, $2, $3, $4}')
        MESSAGE=":warning: *High CPU Usage Alert*\n*Hostname*: $HOSTNAME\n*IP*: $IP_ADDRESS\n*CPU Usage*: ${CPU_USAGE}%\n*Threshold*: ${CPU_THRESHOLD}%\n*Top 5 CPU Processes*:\n\`\`\`$TOP_PROCESSES\`\`\`"
        send_slack_alert "$MESSAGE" "#FF0000"
        log_message "High CPU Usage: ${CPU_USAGE}% - Alert sent"
    fi

    # Check Memory usage
    MEM_USAGE=$(get_mem_usage)
    if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
        TOP_PROCESSES=$(get_top_mem_processes | awk '{printf "PID: %s, PPID: %s, CMD: %s, MEM: %s%%\n", $1, $2, $3, $4}')
        MESSAGE=":warning: *High Memory Usage Alert*\n*Hostname*: $HOSTNAME\n*IP*: $IP_ADDRESS\n*Memory Usage*: ${MEM_USAGE}%\n*Threshold*: ${MEM_THRESHOLD}%\n*Top 5 Memory Processes*:\n\`\`\`$TOP_PROCESSES\`\`\`"
        send_slack_alert "$MESSAGE" "#FF0000"
        log_message "High Memory Usage: ${MEM_USAGE}% - Alert sent"
    fi

    # Wait for the next check
    sleep "$CHECK_INTERVAL"
done
