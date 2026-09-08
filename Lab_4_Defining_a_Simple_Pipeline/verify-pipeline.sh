#!/bin/bash

PIPELINE_NAME="simple-build-pipeline"
echo "Verifying pipeline: $PIPELINE_NAME"

# Check if pipeline exists
if tkn pipeline describe $PIPELINE_NAME > /dev/null 2>&1; then
    echo "✓ Pipeline exists"
else
    echo "✗ Pipeline not found"
    exit 1
fi

# Get the latest pipeline run
LATEST_RUN=$(tkn pipelinerun list -o name | head -1 | cut -d'/' -f2)

if [ -n "$LATEST_RUN" ]; then
    echo "Latest pipeline run: $LATEST_RUN"
    
    # Check status
    STATUS=$(kubectl get pipelinerun $LATEST_RUN -o jsonpath='{.status.conditions[0].reason}')
    echo "Status: $STATUS"
    
    if [ "$STATUS" = "Succeeded" ]; then
        echo "✓ Pipeline completed successfully"
    elif [ "$STATUS" = "Running" ]; then
        echo "⏳ Pipeline is still running"
    else
        echo "✗ Pipeline failed or has issues"
    fi
else
    echo "No pipeline runs found"
fi

