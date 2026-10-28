#!/usr/bin/env bash
# Phase 1 (continued) - connect kubectl to the cluster and create the environment namespaces.
# Run this as the OS user that will run kubectl (for the pipeline: the 'jenkins' user).
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-my-cluster}"
REGION="${REGION:-us-east-1}"

aws eks update-kubeconfig --region "${REGION}" --name "${CLUSTER_NAME}"

for ns in dev test prod; do
  if kubectl get namespace "${ns}" >/dev/null 2>&1; then
    echo "namespace '${ns}' already exists"
  else
    kubectl create namespace "${ns}"
  fi
done

kubectl get nodes
kubectl get namespaces
