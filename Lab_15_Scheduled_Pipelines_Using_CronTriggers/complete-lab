Lab 15: Scheduled Pipelines Using CronTriggers
Objectives
By the end of this lab, students will be able to:

• Understand the concept of CronTriggers in OpenShift Pipelines • Create and configure CronTriggers to schedule pipeline executions • Set up different scheduling patterns including daily, weekly, and hourly builds • Verify that CronTriggers are executing pipelines according to schedule • Monitor and troubleshoot scheduled pipeline runs • Implement best practices for automated pipeline scheduling

Prerequisites
Before starting this lab, students should have:

• Basic understanding of OpenShift Pipelines and Tekton • Familiarity with YAML syntax and Kubernetes resources • Knowledge of cron expression syntax • Experience with kubectl/oc command-line tools • Completed previous labs on basic pipeline creation and execution • Understanding of Git repositories and container registries

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift cluster access pre-configured. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with Tekton Pipelines operator installed • kubectl and oc CLI tools configured • Sample application repository access • Container registry access for image storage

Task 1: Understanding CronTriggers and Creating Basic Pipeline
Subtask 1.1: Verify Lab Environment
First, let's verify that your environment is properly configured and Tekton Pipelines is available.

Check cluster connection:
oc whoami
oc cluster-info
Verify Tekton Pipelines installation:
oc get pods -n openshift-pipelines
Create a dedicated project for this lab:
oc new-project scheduled-pipelines-lab
oc project scheduled-pipelines-lab
Subtask 1.2: Create a Sample Application Pipeline
Before we can schedule pipelines, we need a pipeline to schedule. Let's create a simple build pipeline.

Create a basic Task for our pipeline:
cat << 'EOF' > build-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-and-test
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      default: main
      description: Git revision to build
  workspaces:
    - name: source
      description: Workspace for source code
  steps:
    - name: clone-repository
      image: alpine/git:latest
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/sh
        echo "Cloning repository: $(params.git-url)"
        git clone $(params.git-url) .
        git checkout $(params.git-revision)
        echo "Repository cloned successfully"
        
    - name: build-application
      image: node:16-alpine
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/sh
        echo "Starting build process at $(date)"
        echo "Simulating application build..."
        sleep 10
        echo "Build completed successfully at $(date)"
        
    - name: run-tests
      image: node:16-alpine
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/sh
        echo "Running tests at $(date)"
        echo "Simulating test execution..."
        sleep 5
        echo "All tests passed at $(date)"
EOF

oc apply -f build-task.yaml
Create the Pipeline:
cat << 'EOF' > scheduled-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: scheduled-build-pipeline
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      default: main
      description: Git revision to build
  workspaces:
    - name: shared-workspace
      description: Shared workspace for pipeline
  tasks:
    - name: build-and-test
      taskRef:
        name: build-and-test
      params:
        - name: git-url
          value: $(params.git-url)
        - name: git-revision
          value: $(params.git-revision)
      workspaces:
        - name: source
          workspace: shared-workspace
EOF

oc apply -f scheduled-pipeline.yaml
Verify the pipeline was created:
oc get pipelines
oc get tasks
Task 2: Define CronTriggers for Different Schedules
Subtask 2.1: Create a Daily CronTrigger
Now let's create a CronTrigger that will run our pipeline daily at 2:00 AM.

Create the daily CronTrigger:
cat << 'EOF' > daily-cron-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: daily-build-trigger
spec:
  schedule: "0 2 * * *"  # Daily at 2:00 AM
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f daily-cron-trigger.yaml
Verify the CronTrigger was created:
oc get crontrigger
oc describe crontrigger daily-build-trigger
Subtask 2.2: Create a Weekly CronTrigger
Let's create a weekly trigger that runs every Monday at 6:00 AM for more comprehensive builds.

Create the weekly CronTrigger:
cat << 'EOF' > weekly-cron-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: weekly-build-trigger
spec:
  schedule: "0 6 * * 1"  # Weekly on Monday at 6:00 AM
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f weekly-cron-trigger.yaml
Subtask 2.3: Create an Hourly CronTrigger for Testing
For testing purposes, let's create an hourly trigger that runs every hour during business hours.

Create the hourly CronTrigger:
cat << 'EOF' > hourly-cron-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: hourly-test-trigger
spec:
  schedule: "0 9-17 * * 1-5"  # Every hour from 9 AM to 5 PM, Monday to Friday
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f hourly-cron-trigger.yaml
Verify all CronTriggers are created:
oc get crontrigger
Task 3: Understanding Cron Expression Syntax
Subtask 3.1: Learn Cron Expression Format
Understanding cron expressions is crucial for scheduling pipelines effectively.

Cron Expression Format: minute hour day-of-month month day-of-week

Field Ranges:

Minute: 0-59
Hour: 0-23 (24-hour format)
Day of Month: 1-31
Month: 1-12
Day of Week: 0-7 (0 and 7 are Sunday)
Special Characters:

*: Any value
,: Value list separator
-: Range of values
/: Step values
Subtask 3.2: Create Custom Schedule Examples
Let's create some additional CronTriggers with different scheduling patterns.

Create a trigger for every 15 minutes (for testing):
cat << 'EOF' > frequent-test-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: frequent-test-trigger
spec:
  schedule: "*/15 * * * *"  # Every 15 minutes
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f frequent-test-trigger.yaml
Create a trigger for first day of every month:
cat << 'EOF' > monthly-cron-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: monthly-build-trigger
spec:
  schedule: "0 3 1 * *"  # First day of every month at 3:00 AM
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f monthly-cron-trigger.yaml
Task 4: Verify CronTrigger Execution and Monitoring
Subtask 4.1: Monitor CronTrigger Status
Let's verify that our CronTriggers are properly configured and monitor their execution.

Check all CronTriggers:
oc get crontrigger -o wide
Get detailed information about a specific CronTrigger:
oc describe crontrigger frequent-test-trigger
Check for any events related to CronTriggers:
oc get events --field-selector involvedObject.kind=CronTrigger
Subtask 4.2: Monitor Pipeline Runs
Since our frequent test trigger runs every 15 minutes, we should see pipeline runs being created automatically.

Wait for pipeline runs to be triggered (this may take up to 15 minutes):
# Check for pipeline runs every few minutes
watch -n 30 'oc get pipelineruns'
Once pipeline runs appear, examine them:
oc get pipelineruns
oc describe pipelinerun <pipelinerun-name>
Check the logs of a running pipeline:
# Replace <pipelinerun-name> with actual name
oc logs -f pipelinerun/<pipelinerun-name>
Subtask 4.3: Create a Monitoring Script
Let's create a script to continuously monitor our scheduled pipelines.

Create a monitoring script:
cat << 'EOF' > monitor-scheduled-pipelines.sh
#!/bin/bash

echo "=== Scheduled Pipelines Monitoring ==="
echo "Timestamp: $(date)"
echo

echo "=== CronTriggers Status ==="
oc get crontrigger -o custom-columns=NAME:.metadata.name,SCHEDULE:.spec.schedule,PIPELINE:.spec.pipelineRef.name
echo

echo "=== Recent Pipeline Runs ==="
oc get pipelineruns --sort-by=.metadata.creationTimestamp -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].reason,STARTED:.status.startTime,COMPLETED:.status.completionTime
echo

echo "=== Pipeline Run Summary ==="
TOTAL_RUNS=$(oc get pipelineruns --no-headers | wc -l)
SUCCESSFUL_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Succeeded")].metadata.name}' | wc -w)
FAILED_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Failed")].metadata.name}' | wc -w)
RUNNING_RUNS=$(oc get pipelineruns -o jsonpath='{.items[?(@.status.conditions[0].reason=="Running")].metadata.name}' | wc -w)

echo "Total Pipeline Runs: $TOTAL_RUNS"
echo "Successful: $SUCCESSFUL_RUNS"
echo "Failed: $FAILED_RUNS"
echo "Currently Running: $RUNNING_RUNS"
echo

echo "=== Recent Events ==="
oc get events --sort-by=.lastTimestamp | tail -10
EOF

chmod +x monitor-scheduled-pipelines.sh
Run the monitoring script:
./monitor-scheduled-pipelines.sh
Task 5: Advanced CronTrigger Configuration
Subtask 5.1: Create CronTrigger with Environment-Specific Parameters
Let's create a more advanced CronTrigger that uses different parameters based on the schedule.

Create a production deployment trigger:
cat << 'EOF' > production-deploy-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: production-deploy-trigger
spec:
  schedule: "0 22 * * 0"  # Every Sunday at 10:00 PM
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "release"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 2Gi
EOF

oc apply -f production-deploy-trigger.yaml
Subtask 5.2: Create CronTrigger with Resource Limits
Let's create a CronTrigger that includes resource specifications for better resource management.

Create a resource-aware CronTrigger:
cat << 'EOF' > resource-aware-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: resource-aware-trigger
spec:
  schedule: "0 1 * * 6"  # Every Saturday at 1:00 AM
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "main"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi
          storageClassName: fast-ssd
  podTemplate:
    nodeSelector:
      node-type: build-node
    tolerations:
      - key: "build-workload"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
EOF

oc apply -f resource-aware-trigger.yaml
Task 6: Troubleshooting and Best Practices
Subtask 6.1: Common Troubleshooting Steps
Let's learn how to troubleshoot common issues with CronTriggers.

Check CronTrigger controller logs:
oc logs -n openshift-pipelines -l app=tekton-triggers-controller
Verify CronTrigger webhook configuration:
oc get validatingwebhookconfigurations | grep triggers
oc get mutatingwebhookconfigurations | grep triggers
Check for resource quotas that might prevent pipeline execution:
oc describe quota
oc describe limitrange
Subtask 6.2: Create a Troubleshooting Checklist
Create a troubleshooting script:
cat << 'EOF' > troubleshoot-crontriggers.sh
#!/bin/bash

echo "=== CronTrigger Troubleshooting Checklist ==="
echo "Timestamp: $(date)"
echo

echo "1. Checking CronTrigger Resources..."
CRONTRIGGER_COUNT=$(oc get crontrigger --no-headers | wc -l)
echo "   Found $CRONTRIGGER_COUNT CronTriggers"

if [ $CRONTRIGGER_COUNT -eq 0 ]; then
    echo "   ❌ No CronTriggers found!"
else
    echo "   ✅ CronTriggers exist"
    oc get crontrigger -o custom-columns=NAME:.metadata.name,SCHEDULE:.spec.schedule
fi
echo

echo "2. Checking Pipeline Resources..."
PIPELINE_COUNT=$(oc get pipeline --no-headers | wc -l)
echo "   Found $PIPELINE_COUNT Pipelines"

if [ $PIPELINE_COUNT -eq 0 ]; then
    echo "   ❌ No Pipelines found!"
else
    echo "   ✅ Pipelines exist"
fi
echo

echo "3. Checking Recent Pipeline Runs..."
RECENT_RUNS=$(oc get pipelineruns --no-headers --sort-by=.metadata.creationTimestamp | tail -5)
if [ -z "$RECENT_RUNS" ]; then
    echo "   ⚠️  No recent pipeline runs found"
else
    echo "   ✅ Recent pipeline runs found"
    echo "$RECENT_RUNS"
fi
echo

echo "4. Checking Tekton Triggers Controller..."
CONTROLLER_STATUS=$(oc get pods -n openshift-pipelines -l app=tekton-triggers-controller --no-headers)
if echo "$CONTROLLER_STATUS" | grep -q "Running"; then
    echo "   ✅ Tekton Triggers Controller is running"
else
    echo "   ❌ Tekton Triggers Controller issues detected"
    echo "$CONTROLLER_STATUS"
fi
echo

echo "5. Checking for Errors in Events..."
ERROR_EVENTS=$(oc get events --field-selector type=Warning --no-headers | head -5)
if [ -z "$ERROR_EVENTS" ]; then
    echo "   ✅ No recent warning events"
else
    echo "   ⚠️  Recent warning events found:"
    echo "$ERROR_EVENTS"
fi
echo

echo "=== Troubleshooting Complete ==="
EOF

chmod +x troubleshoot-crontriggers.sh
Run the troubleshooting script:
./troubleshoot-crontriggers.sh
Subtask 6.3: Implement Best Practices
Create a CronTrigger with proper labeling and annotations:
cat << 'EOF' > best-practice-trigger.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: CronTrigger
metadata:
  name: best-practice-trigger
  labels:
    app: scheduled-builds
    environment: development
    team: platform
  annotations:
    description: "Daily development build trigger"
    owner: "platform-team@company.com"
    schedule-description: "Runs daily at 3 AM UTC"
spec:
  schedule: "0 3 * * *"  # Daily at 3:00 AM UTC
  pipelineRef:
    name: scheduled-build-pipeline
  params:
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
    - name: git-revision
      value: "develop"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF

oc apply -f best-practice-trigger.yaml
Task 7: Clean Up and Resource Management
Subtask 7.1: Manage Pipeline Run History
Scheduled pipelines can create many pipeline runs over time. Let's implement cleanup strategies.

Create a cleanup script for old pipeline runs:
cat << 'EOF' > cleanup-old-runs.sh
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
EOF

chmod +x cleanup-old-runs.sh
Run the cleanup script:
./cleanup-old-runs.sh
Subtask 7.2: Disable CronTriggers
Sometimes you need to temporarily disable scheduled pipelines without deleting them.

Create a script to disable all CronTriggers:
cat << 'EOF' > disable-crontriggers.sh
#!/bin/bash

echo "Disabling CronTriggers by adding suspend annotation..."

for trigger in $(oc get crontrigger -o name); do
    echo "Disabling $trigger"
    oc annotate $trigger triggers.tekton.dev/suspend="true" --overwrite
done

echo "All CronTriggers have been suspended"
oc get crontrigger -o custom-columns=NAME:.metadata.name,SUSPENDED:.metadata.annotations.triggers\.tekton\.dev/suspend
EOF

chmod +x disable-crontriggers.sh
Create a script to re-enable CronTriggers:
cat << 'EOF' > enable-crontriggers.sh
#!/bin/bash

echo "Re-enabling CronTriggers by removing suspend annotation..."

for trigger in $(oc get crontrigger -o name); do
    echo "Enabling $trigger"
    oc annotate $trigger triggers.tekton.dev/suspend- --overwrite
done

echo "All CronTriggers have been re-enabled"
oc get crontrigger -o custom-columns=NAME:.metadata.name,SUSPENDED:.metadata.annotations.triggers\.tekton\.dev/suspend
EOF

chmod +x enable-crontriggers.sh
Verification and Testing
Final Verification Steps
Verify all CronTriggers are created and configured:
echo "=== Final Verification ==="
echo "CronTriggers created:"
oc get crontrigger -o custom-columns=NAME:.metadata.name,SCHEDULE:.spec.schedule,PIPELINE:.spec.pipelineRef.name

echo -e "\nPipeline runs generated:"
oc get pipelineruns --sort-by=.metadata.creationTimestamp

echo -e "\nMonitoring script available:"
ls -la monitor-scheduled-pipelines.sh

echo -e "\nTroubleshooting script available:"
ls -la troubleshoot-crontriggers.sh
Test the monitoring and troubleshooting scripts:
./monitor-scheduled-pipelines.sh
./troubleshoot-crontriggers.sh
Common Issues and Solutions
Issue 1: CronTrigger Not Creating Pipeline Runs
Symptoms: CronTrigger exists but no pipeline runs are created

Solutions:

Check if the Tekton Triggers controller is running
Verify the cron expression syntax
Check for resource quotas or limits
Review controller logs for errors
Issue 2: Pipeline Runs Failing Immediately
Symptoms: Pipeline runs are created but fail immediately

Solutions:

Check if the referenced pipeline exists
Verify workspace and parameter configurations
Check for missing tasks or resources
Review pipeline run logs for specific errors
Issue 3: Incorrect Schedule Execution
Symptoms: Pipelines run at wrong times or frequencies

Solutions:

Verify cron expression syntax using online cron validators
Check timezone settings (CronTriggers use UTC by default)
Ensure the schedule format matches the expected pattern
Conclusion
In this lab, you have successfully:

• Created and configured CronTriggers to automatically schedule pipeline executions at different intervals (daily, weekly, hourly, and custom schedules)

• Learned cron expression syntax and how to create complex scheduling patterns for different use cases

• Implemented monitoring and troubleshooting strategies to ensure scheduled pipelines run reliably and efficiently

• Applied best practices for resource management, labeling, and cleanup of scheduled pipeline resources

• Built practical scripts for monitoring, troubleshooting, and managing scheduled pipelines in production environments

Why This Matters: Scheduled pipelines using CronTriggers are essential for implementing continuous integration and deployment practices. They enable automated builds, tests, and deployments without manual intervention, ensuring consistent and reliable software delivery. This automation is crucial for maintaining code quality, reducing manual errors, and enabling teams to focus on development rather than operational tasks.

The skills you've learned in this lab are directly applicable to real-world scenarios where you need to implement automated build and deployment pipelines that run on predictable schedules, supporting both development workflows and production deployment strategies.
