# 🚀 Kubernetes Worker Node Optimizer

This project automates the optimization of Kubernetes worker nodes by draining nodes that are underutilized, based on both CPU and memory usage, while skipping nodes that are running protected pods.

## 📦 Features

- Checks CPU and memory usage per worker node
- Drains nodes that fall below defined thresholds (default: CPU < 5%, MEM < 10%)
- Skips draining if any pod on the node has the label `do-not-drain=true`
- Designed to run automatically via a daily cron job

## ⚙️ Configuration

You can customize the following thresholds inside the `optimize-nodes.sh` script:

```bash
CPU_THRESHOLD=5.0
MEM_THRESHOLD=10.0
PROTECTED_LABEL="do-not-drain=true"
```

## 🏷️ Protecting Pods

To ensure that a node running a critical pod is never drained, label the pod like this:

```bash
kubectl label pod <pod-name> do-not-drain=true
```

The script will skip draining any node that runs at least one pod with this label.

## ⏰ Cron Job

See [`cronjob-setup.md`](cronjob-setup.md) for setup instructions. Example:

```bash
0 2 * * * /path/to/optimize-nodes.sh >> /var/log/k8s-node-optimizer.log 2>&1
```

## 🧪 Requirements

- `kubectl` with access to your cluster
- `metrics-server` must be deployed
- `jq` and `bc` installed on the system running the script
