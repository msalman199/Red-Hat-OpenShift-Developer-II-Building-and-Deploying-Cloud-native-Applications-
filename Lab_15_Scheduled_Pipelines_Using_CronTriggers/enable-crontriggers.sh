#!/bin/bash

echo "Re-enabling CronTriggers by removing suspend annotation..."

for trigger in $(oc get crontrigger -o name); do
    echo "Enabling $trigger"
    oc annotate $trigger triggers.tekton.dev/suspend- --overwrite
done

echo "All CronTriggers have been re-enabled"
oc get crontrigger -o custom-columns=NAME:.metadata.name,SUSPENDED:.metadata.annotations.triggers\.tekton\.dev/suspend
