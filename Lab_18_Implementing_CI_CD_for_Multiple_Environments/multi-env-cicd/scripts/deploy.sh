#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-1.0.0}
NAMESPACE="multi-env-${ENVIRONMENT}"

echo "Deploying to environment: $ENVIRONMENT (namespace: $NAMESPACE)"

oc create namespace "$NAMESPACE" --dry-run=client -o yaml | oc apply -f -

oc apply -f "config/${ENVIRONMENT}/app-config.yaml"

sed "s/${ENVIRONMENT}-1.0.0/${ENVIRONMENT}-${IMAGE_TAG}/g" \
  "manifests/${ENVIRONMENT}/deployment.yaml" > "/tmp/deployment-${ENVIRONMENT}.yaml"

oc apply -f "/tmp/deployment-${ENVIRONMENT}.yaml"
oc apply -f "manifests/${ENVIRONMENT}/service.yaml"

oc rollout status "deployment/multi-env-app" -n "$NAMESPACE" --timeout=180s

echo "Deployment to $ENVIRONMENT completed successfully."
