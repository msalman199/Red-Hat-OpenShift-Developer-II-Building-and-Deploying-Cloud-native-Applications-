#!/bin/bash

echo "=== OpenShift Pipeline Workspace Troubleshooting ==="

# Check PVC status
echo "=== PVC Status ==="
oc get pvc
echo ""

# Check storage class
echo "=== Storage Classes ==="
oc get storageclass
echo ""

# Check recent PipelineRuns
echo "=== Recent PipelineRuns ==="
oc get pipelinerun --sort-by=.metadata.creationTimestamp | tail -5
echo ""

# Check for failed TaskRuns
echo "=== Failed TaskRuns ==="
oc get taskrun --field-selector=status.conditions[0].status=False
echo ""

# Check pod logs for workspace issues
echo "=== Checking for Workspace Mount Issues ==="
for pod in $(oc get pods -l tekton.dev/task --no-headers | grep -E "(Error|Failed|Pending)" | awk '{print $1}'); do
  echo "Pod: $pod"
  oc describe pod $pod | grep -A 5 -B 5 -i "workspace\|volume\|mount"
  echo "---"
done

echo "=== Common Workspace Issues and Solutions ==="
cat << 'TROUBLESHOOT'

1. PVC Not Found:
   - Verify PVC exists: oc get pvc
   - Check PVC status: oc describe pvc <pvc-name>
   - Ensure correct PVC name in PipelineRun

2. Mount Permission Issues:
   - Check PVC access modes
   - Verify storage class supports required access mode
   - Check pod security context

3. Workspace Not Shared Between Tasks:
   - Verify workspace name consistency across tasks
   - Check workspace mount paths
   - Ensure tasks run in correct order with runAfter

4. ConfigMap/Secret Workspace Issues:
   - Verify ConfigMap/Secret exists
   - Check data keys in ConfigMap/Secret
   - Ensure proper RBAC permissions

5. Storage Full:
   - Check PVC size: oc describe pvc
   - Monitor disk usage in tasks
   - Consider increasing PVC size

TROUBLESHOOT
