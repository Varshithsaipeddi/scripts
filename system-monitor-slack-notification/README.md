
# System Monitoring Script with Slack Alerting

This Bash script monitors CPU and memory usage on a Linux system and sends alerts to a Slack webhook when predefined thresholds are exceeded. It provides detailed information such as the hostname, IP address, breached threshold, and the top 5 processes consuming CPU or memory.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Example Slack Alert](#example-slack-alert)
- [Logging](#logging)
- [Notes](#notes)

## Features

- Monitors CPU and memory usage in real-time.
- Sends alerts to a Slack webhook when thresholds are breached.
- Includes:
  - Hostname and IP address of the system.
  - Current usage percentage and threshold.
  - Top 5 CPU-consuming processes (for CPU alerts).
  - Top 5 memory-consuming processes (for memory alerts).
- Logs alerts to a file (`/var/log/system_monitor.log`).
- Configurable thresholds and check intervals.

## Requirements

- Linux system with Bash.
- Tools: `top`, `free`, `ps`, `curl` (commonly available on most Linux distributions).
- A Slack webhook URL for sending alerts.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/Varshithsaipeddi/scripts.git
   cd scripts/system-monitor-slack-notification
   ```

2. Make the script executable:

   ```bash
   chmod +x system_monitor.sh
   ```

3. Edit the script to configure:
   - `SLACK_WEBHOOK_URL`: Replace with your Slack webhook URL.
   - `CPU_THRESHOLD`: Set desired CPU usage threshold (default: 80%).
   - `MEM_THRESHOLD`: Set desired memory usage threshold (default: 80%).
   - `CHECK_INTERVAL`: Set the interval between checks in seconds (default: 60).

4. Ensure the log file directory exists:

   ```bash
   sudo touch /var/log/system_monitor.log
   sudo chmod 666 /var/log/system_monitor.log
   ```

## Usage

1. Run the script in the background:

   ```bash
   ./system_monitor.sh &
   ```

2. Or use a process manager like `systemd` for persistent execution.

3. To stop the script, find its PID and kill it:

   ```bash
   ps aux | grep system_monitor.sh
   kill <PID>
   ```

## Example Slack Alert

### High CPU Usage Alert

:warning: **High CPU Usage Alert**  
**Hostname**: server01  
**IP**: 192.168.1.100  
**CPU Usage**: 85%  
**Threshold**: 80%  

**Top 5 CPU Processes**:
- PID: 1234, PPID: 1, CMD: /usr/bin/java, CPU: 45.2%
- PID: 5678, PPID: 1234, CMD: /bin/python3, CPU: 20.1%
- ...

## Logging

Alerts are logged to `/var/log/system_monitor.log` with timestamps. Example:

```
2025-05-02 10:15:30 - High CPU Usage: 85% - Alert sent
2025-05-02 10:16:30 - High Memory Usage: 82% - Alert sent
```

## Notes

- Ensure the Slack webhook URL is kept secure and not exposed in public repositories.
- The script runs indefinitely; consider using a process manager for production use.
- Adjust thresholds and intervals based on your system's requirements.
- Test the script in a controlled environment before deploying to production.
