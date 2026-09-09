#!/bin/bash
# Usage: ./detect-overlap.sh <pipelinerun-name> [namespace]

PIPELINERUN_NAME=$1
NAMESPACE=${2:-pipeline-parallel-lab}

if [ -z "$PIPELINERUN_NAME" ]; then
    echo "Usage: $0 <pipelinerun-name> [namespace]"
    exit 1
fi

TASK_RUNS=$(oc get taskrun -n "$NAMESPACE" \
  -l "tekton.dev/pipelineRun=${PIPELINERUN_NAME}" \
  -o jsonpath='{.items[*].metadata.name}')

declare -A starts
declare -A ends
names=()

for tr in $TASK_RUNS; do
    TASK_NAME=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.tekton\.dev/pipelineTask}')
    TASK_START=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.status.startTime}')
    TASK_END=$(oc get taskrun "$tr" -n "$NAMESPACE" -o jsonpath='{.status.completionTime}')

    if [ -n "$TASK_START" ] && [ -n "$TASK_END" ] && [ "$TASK_NAME" != "fetch-source" ]; then
        starts[$TASK_NAME]=$(date -d "$TASK_START" +%s)
        ends[$TASK_NAME]=$(date -d "$TASK_END" +%s)
        names+=("$TASK_NAME")
    fi
done

echo "=== Overlap Analysis for $PIPELINERUN_NAME ==="
found_overlap=false

for ((i=0; i<${#names[@]}; i++)); do
    for ((j=i+1; j<${#names[@]}; j++)); do
        t1=${names[$i]}
        t2=${names[$j]}
        if [ "${starts[$t1]}" -lt "${ends[$t2]}" ] && [ "${starts[$t2]}" -lt "${ends[$t1]}" ]; then
            echo "Overlap detected: $t1 and $t2 ran concurrently"
            found_overlap=true
        fi
    done
done

if [ "$found_overlap" = false ]; then
    echo "No overlapping task execution detected (tasks ran sequentially)"
fi
