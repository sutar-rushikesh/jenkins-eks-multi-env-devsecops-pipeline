#!/usr/bin/env bash
# Cleanup - removes the application and DELETES the EKS cluster (stops EKS/EC2 charges).
# Does not touch the Jenkins EC2 instance or DockerHub; see README "Cleanup".
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-my-cluster}"
REGION="${REGION:-us-east-1}"

read -r -p "Type the cluster name '${CLUSTER_NAME}' to confirm deletion: " answer
[[ "${answer}" == "${CLUSTER_NAME}" ]] || { echo "Aborted."; exit 1; }

for ns in dev test prod; do
  # Delete Services first so any cloud load balancers are released before the cluster goes away.
  kubectl delete service spring-boot-app -n "${ns}" --ignore-not-found
  kubectl delete deployment spring-boot-app -n "${ns}" --ignore-not-found
done

eksctl delete cluster --name "${CLUSTER_NAME}" --region "${REGION}" --wait
