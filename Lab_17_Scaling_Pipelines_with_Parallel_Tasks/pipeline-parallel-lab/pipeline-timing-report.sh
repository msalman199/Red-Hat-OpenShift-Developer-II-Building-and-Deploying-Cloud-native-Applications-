#!/bin/bash
# Usage: ./pipeline-timing-report.sh <pipelinerun-name> [namespace]

PIPELINERUN_NAME=$1
NAMESPACE=${2:-pipeline-parallel-lab}

if [ -z "$PIPELINERUN_NAME" ]; then
    echo "Usage: $0 <pipelinerun-name> [namespace]"
    exit 1
fi

echo "=== Timing Report for $PIPELINERUN_NAME ==="

STATUS=$(oc get pipelinerun "$PIPELINERUN_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[0].reason}')
START_TIME=$(oc get pipelinerun "$PIPELINERUN_NAME" -n "$NAMESPACE" -o jsonpath='{.status.startTime}')
COMPLETION_TIME=$(oc get pipelinerun "$PIPELINERUN_NAME" -n "$NAMESPACE" -o jsonpath='{.status.completionTime}')

echo "Overall status: $STATUS"
echo "Started:   $START_TIME"
echo "Completed: $COMPLETION_TIME"

if [ -n "$START_TIME" ] && [ -n "$COMPLETION_TIME" ]; then
    START_EPOCH=$(date -d "$START_TIME" +%s)
    END_EPOCH=$(date -d "$COMPLETION_TIME" +%s)
    echo "Total pipeline duration: $((END_EPOCH - START_EPOCH)) seconds"
fi

echo
echo "Per-task breakdown:"
echo "--------------------"

# List TaskRuns belonging to this PipelineRun via the tekton.dev/pipelineRun label
TASK_RUNS=$(oc get taskrun -n "$NAMESPACE" \
  -l "tekton.dev/pipelineRun=${PIPELINERUN_NAME}" \
  -o jsonpath='{.items[*].metadata.name}')

for tr in $TASK_RUNS; do
    TASK_NAME=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.tekton\.dev/pipelineTask}')
    TASK_STATUS=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.status.conditions[0].reason}')
    TASK_START=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.status.startTime}')
    TASK_END=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.status.completionTime}')

    echo "Task: $TASK_NAME"
    echo "  Status:    $TASK_STATUS"
    echo "  Started:   $TASK_START"
    echo "  Completed: $TASK_END"

    if [ -n "$TASK_START" ] && [ -n "$TASK_END" ]; then
        TS=$(date -d "$TASK_START" +%s)
        TE=$(date -d "$TASK_END" +%s)
        echo "  Duration:  $((TE - TS)) seconds"
    fi
    echo
done
