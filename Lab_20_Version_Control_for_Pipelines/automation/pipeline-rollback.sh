#!/bin/bash
# Rolls the pipelines/ directory back to a previous Git tag
# Usage: ./pipeline-rollback.sh <target-tag>

set -euo pipefail

TARGET_TAG=${1:-}

if [ -z "$TARGET_TAG" ]; then
    echo "Usage: $0 <target-tag>"
    exit 1
fi

if ! git tag --list | grep -qx "$TARGET_TAG"; then
    echo "Error: tag $TARGET_TAG not found"
    echo "Available tags:"
    git tag --list --sort=-version:refname
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
ROLLBACK_BRANCH="rollback-to-${TARGET_TAG}"

echo "Current branch: $CURRENT_BRANCH"
echo "Creating rollback branch: $ROLLBACK_BRANCH"
git checkout -b "$ROLLBACK_BRANCH"

echo "Restoring pipelines/ from tag $TARGET_TAG"
git checkout "$TARGET_TAG" -- pipelines/

echo
echo "Files restored to state at $TARGET_TAG:"
git diff --name-only "$CURRENT_BRANCH" -- pipelines/

echo
echo "Next steps:"
echo "1. Review the changes with: git diff $CURRENT_BRANCH"
echo "2. Commit the rollback: git commit -am 'Rollback pipelines to $TARGET_TAG'"
echo "3. Merge back if approved: git checkout $CURRENT_BRANCH && git merge $ROLLBACK_BRANCH"
