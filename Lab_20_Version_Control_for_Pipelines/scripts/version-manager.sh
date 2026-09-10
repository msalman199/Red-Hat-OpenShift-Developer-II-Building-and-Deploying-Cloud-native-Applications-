#!/bin/bash
# Pipeline Version Manager
# Usage: ./version-manager.sh [major|minor|patch] [pipeline-file]

set -euo pipefail

VERSION_TYPE=${1:-patch}
PIPELINE_FILE=${2:-}

if [ -z "$PIPELINE_FILE" ]; then
    echo "Usage: $0 [major|minor|patch] [pipeline-file]"
    exit 1
fi

if [ ! -f "$PIPELINE_FILE" ]; then
    echo "Pipeline file not found: $PIPELINE_FILE"
    exit 1
fi

CURRENT_VERSION=$(grep -o 'version: "[0-9]*\.[0-9]*\.[0-9]*"' "$PIPELINE_FILE" | head -1 | grep -o '[0-9]*\.[0-9]*\.[0-9]*')

if [ -z "$CURRENT_VERSION" ]; then
    echo "No version found in pipeline file. Assuming 1.0.0"
    CURRENT_VERSION="1.0.0"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1)); PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Invalid version type. Use: major, minor, or patch"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
sed -i "s/version: \"[0-9]*\.[0-9]*\.[0-9]*\"/version: \"$NEW_VERSION\"/" "$PIPELINE_FILE"

echo "Updated $PIPELINE_FILE from version $CURRENT_VERSION to $NEW_VERSION"
