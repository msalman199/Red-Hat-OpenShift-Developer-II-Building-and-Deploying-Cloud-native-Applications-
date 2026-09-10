#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
NAMESPACE="multi-env-${ENVIRONMENT}"

echo "Running tests for environment: $ENVIRONMENT"

oc wait --for=condition=available "deployment/multi-env-app" \
  -n "$NAMESPACE" --timeout=120s

echo "Checking /health endpoint..."
oc exec -n "$NAMESPACE" "deployment/multi-env-app" -- \
  wget -qO- http://localhost:3000/health

echo ""
echo "All tests passed for environment: $ENVIRONMENT"
