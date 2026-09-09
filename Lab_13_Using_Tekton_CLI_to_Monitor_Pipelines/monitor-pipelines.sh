#!/bin/bash
echo "=== Pipeline Status Dashboard ==="
echo "Date: $(date)"
echo ""
echo "=== Active Pipelines ==="
tkn pipeline list
echo ""
echo "=== Recent Pipeline Runs ==="
tkn pipelinerun list | head -10
echo ""
echo "=== Running Pipeline Runs ==="
tkn pipelinerun list | grep Running
echo ""
echo "=== Failed Pipeline Runs ==="
tkn pipelinerun list | grep Failed
