#!/bin/bash

echo "=== CronTrigger Troubleshooting Checklist ==="
echo "Timestamp: $(date)"
echo

echo "1. Checking CronTrigger Resources..."
CRONTRIGGER_COUNT=$(oc get crontrigger --no-headers | wc -l)
echo "   Found $CRONTRIGGER_COUNT CronTriggers"

if [ $CRONTRIGGER_COUNT -eq 0 ]; then
    echo "   ❌ No CronTriggers found!"
else
    echo "   ✅ CronTriggers exist"
    oc get crontrigger -o custom-columns=NAME:.metadata.name,SCHEDULE:.spec.schedule
fi
echo

echo "2. Checking Pipeline Resources..."
PIPELINE_COUNT=$(oc get pipeline --no-headers | wc -l)
echo "   Found $PIPELINE_COUNT Pipelines"

if [ $PIPELINE_COUNT -eq 0 ]; then
    echo "   ❌ No Pipelines found!"
else
    echo "   ✅ Pipelines exist"
fi
echo

echo "3. Checking Recent Pipeline Runs..."
RECENT_RUNS=$(oc get pipelineruns --no-headers --sort-by=.metadata.creationTimestamp | tail -5)
if [ -z "$RECENT_RUNS" ]; then
    echo "   ⚠️  No recent pipeline runs found"
else
    echo "   ✅ Recent pipeline runs found"
    echo "$RECENT_RUNS"
fi
echo

echo "4. Checking Tekton Triggers Controller..."
CONTROLLER_STATUS=$(oc get pods -n openshift-pipelines -l app=tekton-triggers-controller --no-headers)
if echo "$CONTROLLER_STATUS" | grep -q "Running"; then
    echo "   ✅ Tekton Triggers Controller is running"
else
    echo "   ❌ Tekton Triggers Controller issues detected"
    echo "$CONTROLLER_STATUS"
fi
echo

echo "5. Checking for Errors in Events..."
ERROR_EVENTS=$(oc get events --field-selector type=Warning --no-headers | head -5)
if [ -z "$ERROR_EVENTS" ]; then
    echo "   ✅ No recent warning events"
else
    echo "   ⚠️  Recent warning events found:"
    echo "$ERROR_EVENTS"
fi
echo

echo "=== Troubleshooting Complete ==="
