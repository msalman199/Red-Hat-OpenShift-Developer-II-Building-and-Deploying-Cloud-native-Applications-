#!/bin/bash
FAILED_RUNS=$(tkn pipelinerun list -o jsonpath='{.items[?(@.status.conditions[0].reason=="Failed")].metadata.name}')

if [ ! -z "$FAILED_RUNS" ]; then
    echo "ALERT: Failed pipeline runs detected:"
    echo "$FAILED_RUNS"
    # Here you could add notification logic (email, Slack, etc.)
else
    echo "All pipeline runs are healthy"
fi
