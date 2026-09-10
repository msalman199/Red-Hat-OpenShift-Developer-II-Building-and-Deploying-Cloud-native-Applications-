#!/bin/bash
# Validates every YAML file under pipelines/, tasks/, and environments/

set -uo pipefail

ERRORS=0

for FILE in $(find pipelines tasks environments -name "*.yaml" -type f); do
    echo -n "Validating $FILE ... "
    if python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$FILE" > /dev/null 2>&1; then
        echo "OK"
    else
        echo "INVALID"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo "Validation failed: $ERRORS file(s) with errors"
    exit 1
fi

echo "All pipeline YAML files are valid"
