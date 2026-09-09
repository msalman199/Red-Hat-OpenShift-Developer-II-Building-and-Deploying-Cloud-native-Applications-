#!/bin/bash

echo "Disabling CronTriggers by adding suspend annotation..."

for trigger in $(oc get crontrigger -o name); do
    echo "Disabling $trigger"
    oc annotate $trigger triggers.tekton.dev/suspend="true" --overwrite
done

echo "All CronTriggers have been suspended"
oc get crontrigger -o custom-columns=NAME:.metadata.name,SUSPENDED:.metadata.annotations.triggers\.tekton\.dev/suspend
