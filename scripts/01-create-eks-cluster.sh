#!/usr/bin/env bash
# Phase 1 - create the EKS cluster used by the pipeline.
# WARNING: creates billable AWS resources (EKS control plane + EC2 worker nodes).
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-my-cluster}"
REGION="${REGION:-us-east-1}"
NODE_TYPE="${NODE_TYPE:-t2.medium}"
NODES_MIN="${NODES_MIN:-1}"
NODES_MAX="${NODES_MAX:-2}"

echo "About to create EKS cluster '${CLUSTER_NAME}' in ${REGION} (${NODE_TYPE}, ${NODES_MIN}-${NODES_MAX} nodes)."
read -r -p "This creates billable AWS resources. Continue? [y/N] " answer
[[ "${answer}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

eksctl create cluster \
  --name "${CLUSTER_NAME}" \
  --region "${REGION}" \
  --node-type "${NODE_TYPE}" \
  --nodes-min "${NODES_MIN}" \
  --nodes-max "${NODES_MAX}"
