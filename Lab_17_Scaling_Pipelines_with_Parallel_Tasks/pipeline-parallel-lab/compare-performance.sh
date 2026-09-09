#!/bin/bash
# Usage: ./compare-performance.sh <sequential-run-name> <parallel-run-name> [namespace]

SEQ_RUN=$1
PAR_RUN=$2
NAMESPACE=${3:-pipeline-parallel-lab}

if [ -z "$SEQ_RUN" ] || [ -z "$PAR_RUN" ]; then
    echo "Usage: $0 <sequential-run-name> <parallel-run-name> [namespace]"
    exit 1
fi

get_duration() {
    local run=$1
    local start end
    start=$(oc get pipelinerun "$run" -n "$NAMESPACE" -o jsonpath='{.status.startTime}')
    end=$(oc get pipelinerun "$run" -n "$NAMESPACE" -o jsonpath='{.status.completionTime}')
    if [ -n "$start" ] && [ -n "$end" ]; then
        echo $(( $(date -d "$end" +%s) - $(date -d "$start" +%s) ))
    else
        echo "0"
    fi
}

SEQ_DURATION=$(get_duration "$SEQ_RUN")
PAR_DURATION=$(get_duration "$PAR_RUN")

echo "=== Performance Comparison ==="
echo "Sequential pipeline ($SEQ_RUN): ${SEQ_DURATION}s"
echo "Parallel pipeline   ($PAR_RUN): ${PAR_DURATION}s"

if [ "$SEQ_DURATION" -gt 0 ] && [ "$PAR_DURATION" -gt 0 ]; then
    SAVED=$((SEQ_DURATION - PAR_DURATION))
    PERCENT=$(( (SAVED * 100) / SEQ_DURATION ))
    echo "Time saved: ${SAVED}s (${PERCENT}% faster)"
fi
