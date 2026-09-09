#!/bin/bash

# Keep only the last 10 pipeline runs
echo "Cleaning up old pipeline runs..."
echo "Current pipeline runs count: $(oc get pipelineruns --no-headers | wc -l)"

# Get pipeline runs older than 7 days and delete them
OLD_RUNS=$(oc get pipelineruns -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.metadata.creationTimestamp}{"\n"}{end}' | \
  awk -v date="$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" '$2 < date {print $1}')

if [ -n "$OLD_RUNS" ]; then
    echo "Deleting old pipeline runs:"
    echo "$OLD_RUNS"
    echo "$OLD_RUNS" | xargs -r oc delete pipelinerun
else
    echo "No old pipeline runs to delete"
fi

echo "Remaining pipeline runs count: $(oc get pipelineruns --no-headers | wc -l)"
