#!/bin/bash

# Thresholds
CPU_THRESHOLD=5.0
MEM_THRESHOLD=10.0
PROTECTED_LABEL="do-not-drain=true"

echo "🔍 Scanning worker nodes for underutilization..."

nodes=$(kubectl get nodes --selector='node-role.kubernetes.io/worker' -o name)

for node in $nodes; do
  node_name=$(echo $node | cut -d'/' -f2)

  # Get CPU and Memory usage
  read cpu_usage mem_usage <<< $(kubectl top node "$node_name" --no-headers | awk '{print $3 " " $5}' | sed 's/%//g')

  echo "📊 Node $node_name - CPU: $cpu_usage%, MEM: $mem_usage%"

  if (( $(echo "$cpu_usage < $CPU_THRESHOLD" | bc -l) )) && (( $(echo "$mem_usage < $MEM_THRESHOLD" | bc -l) )); then
    echo "✅ Node $node_name is underutilized"

    # Check for protected pods on the node
    protected_pods=$(kubectl get pods --all-namespaces -o json --field-selector spec.nodeName=$node_name | jq -r '.items[] | select(.metadata.labels["do-not-drain"]=="true") | .metadata.name')

    if [[ -n "$protected_pods" ]]; then
      echo "🚫 Skipping drain: Found protected pod(s) on $node_name: $protected_pods"
    else
      echo "💤 Draining node $node_name..."
      kubectl drain "$node_name" --ignore-daemonsets --delete-emptydir-data --force
    fi
  else
    echo "💡 Node $node_name is utilized enough — skipping"
  fi
done
