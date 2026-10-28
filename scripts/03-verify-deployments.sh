#!/usr/bin/env bash
# Phase 7 - verify the application in every environment after a pipeline run.
set -euo pipefail

for ns in dev test prod; do
  echo "=== namespace: ${ns} ==="
  kubectl get deployment spring-boot-app -n "${ns}"
  kubectl get pods -n "${ns}"
  kubectl rollout status deployment/spring-boot-app -n "${ns}" --timeout=60s
done
