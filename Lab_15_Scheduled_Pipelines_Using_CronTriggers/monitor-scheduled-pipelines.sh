#!/bin/bash

echo "=== Scheduled Pipelines Monitoring ==="
echo "Timestamp: $(date)"
echo

echo "=== CronTriggers Status ==="
oc get crontrigger -o custom-columns=NAME:.metadata.name,SCHEDULE:.spec.schedule,PIPELINE:.spec.pipelineRef.name
echo

echo "=== Recent Pipeline Runs ==="
oc get pipelineruns --sort-by=.metadata.creationTimestamp -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].reason,STARTED:.status.startTime,COMPLETED:.status.completionTime
echo

echo "=== Pipeline Run Summary ==="
TOTAL_RUNS=$(oc get pipelineruns --no-headers | wc -l)
SUCCESSFUL_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Succeeded")].metadata.name}' | wc -w)
FAILED_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Failed")].metadata.name}' | wc -w)
RUNNING_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Running")].metadata.name}' | wc -w)

echo "Total Pipeline Runs: $TOTAL_RUNS"
echo "Successful: $SUCCESSFUL_RUNS"
echo "Failed: $FAILED_RUNS"
echo "Currently Running: $RUNNING_RUNS"
echo

echo "=== Recent Events ==="
oc get events --sort-by=.lastTimestamp | tail -10
