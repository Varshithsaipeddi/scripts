# 🕒 Cron Job Setup

To run the optimization script daily at 2 AM UTC, add the following to root's crontab:

```bash
0 2 * * * /path/to/optimize-nodes.sh >> /var/log/k8s-node-optimizer.log 2>&1
```

Make sure the script is executable:

```bash
chmod +x /path/to/optimize-nodes.sh
```
