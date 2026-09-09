Lab 11: Setting Up Pipeline Notifications
Objectives
By the end of this lab, you will be able to:

• Create and configure notification tasks using Slack webhooks in OpenShift Pipelines • Integrate notification tasks into existing CI/CD pipelines using Tekton • Configure pipeline triggers to send notifications upon completion • Verify and troubleshoot pipeline notification functionality • Understand best practices for pipeline monitoring and alerting

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift and Kubernetes concepts • Familiarity with Tekton Pipelines and Tasks • Knowledge of YAML syntax and structure • Access to a Slack workspace with webhook creation permissions • Completed previous labs on OpenShift Pipeline basics

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with Tekton Pipelines operator installed • Command-line tools (oc, tkn) pre-configured • Sample application code repository • Web-based OpenShift console access

Task 1: Create a Notification Task Using Slack Webhook
Subtask 1.1: Set Up Slack Webhook
First, we need to create a Slack webhook to receive notifications from our pipeline.

Access your Slack workspace and navigate to the Apps section

Search for "Incoming Webhooks" and add it to your workspace

Create a new webhook by selecting a channel where notifications will be posted

Copy the webhook URL - it should look like:

https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
Save this URL as you'll need it in the next steps

Subtask 1.2: Create OpenShift Secret for Webhook
Now we'll store the Slack webhook URL securely in OpenShift.

Open your terminal in the lab environment

Login to OpenShift (if not already logged in):

oc login --token=<your-token> --server=<your-server-url>
Create a new project for this lab:

oc new-project pipeline-notifications
Create a secret to store the Slack webhook URL:

oc create secret generic slack-webhook \
  --from-literal=url=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
Verify the secret was created:

oc get secrets slack-webhook
Subtask 1.3: Create the Notification Task
Create a Tekton Task that will send notifications to Slack.

Create a new file called slack-notification-task.yaml:

cat > slack-notification-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: slack-notification
  namespace: pipeline-notifications
spec:
  params:
    - name: message
      type: string
      description: The message to send to Slack
    - name: status
      type: string
      description: Pipeline status (success/failure)
      default: "success"
    - name: pipeline-name
      type: string
      description: Name of the pipeline
      default: "unknown"
  steps:
    - name: send-notification
      image: curlimages/curl:latest
      env:
        - name: SLACK_WEBHOOK_URL
          valueFrom:
            secretKeyRef:
              name: slack-webhook
              key: url
      script: |
        #!/bin/sh
        
        # Set color based on status
        if [ "$(params.status)" = "success" ]; then
          COLOR="good"
          EMOJI=":white_check_mark:"
        else
          COLOR="danger"
          EMOJI=":x:"
        fi
        
        # Create JSON payload
        PAYLOAD=$(cat <<JSON
        {
          "attachments": [
            {
              "color": "${COLOR}",
              "fields": [
                {
                  "title": "Pipeline Status",
                  "value": "${EMOJI} $(params.status)",
                  "short": true
                },
                {
                  "title": "Pipeline Name",
                  "value": "$(params.pipeline-name)",
                  "short": true
                },
                {
                  "title": "Message",
                  "value": "$(params.message)",
                  "short": false
                }
              ]
            }
          ]
        }
JSON
        )
        
        # Send notification to Slack
        curl -X POST -H 'Content-type: application/json' \
          --data "${PAYLOAD}" \
          "${SLACK_WEBHOOK_URL}"
        
        echo "Notification sent to Slack"
EOF
Apply the task to your OpenShift cluster:

oc apply -f slack-notification-task.yaml
Verify the task was created:

tkn task list
Task 2: Integrate the Notification Task into the Pipeline
Subtask 2.1: Create a Sample Application Pipeline
First, let's create a basic pipeline that we can add notifications to.

Create a pipeline definition file called sample-pipeline.yaml:

cat > sample-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: sample-app-pipeline
  namespace: pipeline-notifications
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
      default: "https://github.com/openshift/nodejs-ex.git"
    - name: git-revision
      type: string
      description: Git revision to build
      default: "main"
    - name: image-name
      type: string
      description: Name of the image to build
      default: "sample-app"
  workspaces:
    - name: shared-data
      description: Shared workspace for pipeline tasks
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      workspaces:
        - name: output
          workspace: shared-data
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
    
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-data
      params:
        - name: IMAGE
          value: "image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(params.image-name):latest"
        - name: DOCKERFILE
          value: "./Dockerfile"
  
  finally:
    - name: notify-success
      taskRef:
        name: slack-notification
      when:
        - input: $(tasks.status)
          operator: in
          values: ["Succeeded"]
      params:
        - name: message
          value: "Pipeline completed successfully! Image $(params.image-name) has been built and pushed."
        - name: status
          value: "success"
        - name: pipeline-name
          value: "$(context.pipeline.name)"
    
    - name: notify-failure
      taskRef:
        name: slack-notification
      when:
        - input: $(tasks.status)
          operator: in
          values: ["Failed"]
      params:
        - name: message
          value: "Pipeline failed! Please check the logs for more details."
        - name: status
          value: "failure"
        - name: pipeline-name
          value: "$(context.pipeline.name)"
EOF
Apply the pipeline to your cluster:

oc apply -f sample-pipeline.yaml
Verify the pipeline was created:

tkn pipeline list
Subtask 2.2: Create Required Resources
Before running the pipeline, we need to create some supporting resources.

Create a PersistentVolumeClaim for the workspace:

cat > pipeline-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: pipeline-notifications
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
Apply the PVC:

oc apply -f pipeline-pvc.yaml
Create a simple Dockerfile for the sample application:

cat > Dockerfile << 'EOF'
FROM registry.access.redhat.com/ubi8/nodejs-16:latest

USER 0

COPY . /opt/app-root/src/

RUN chown -R 1001:0 /opt/app-root/src/

USER 1001

WORKDIR /opt/app-root/src

RUN npm install

EXPOSE 8080

CMD ["npm", "start"]
EOF
Task 3: Verify Notifications When Pipeline Completes
Subtask 3.1: Run the Pipeline
Now let's execute the pipeline and verify that notifications are sent.

Start a pipeline run:

tkn pipeline start sample-app-pipeline \
  --workspace name=shared-data,claimName=pipeline-workspace-pvc \
  --param git-url=https://github.com/openshift/nodejs-ex.git \
  --param git-revision=main \
  --param image-name=sample-nodejs-app \
  --showlog
Monitor the pipeline execution:

tkn pipelinerun list
Get detailed status of the latest pipeline run:

tkn pipelinerun describe $(tkn pipelinerun list -o name | head -1)
Subtask 3.2: Verify Slack Notifications
Check your Slack channel where you configured the webhook

Look for notification messages that should appear when the pipeline completes

Verify the notification content includes:

Pipeline status (success or failure)
Pipeline name
Descriptive message
Appropriate color coding and emojis
Subtask 3.3: Test Failure Notifications
To test failure notifications, let's create a pipeline that will intentionally fail.

Create a failing task:

cat > failing-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: failing-task
  namespace: pipeline-notifications
spec:
  steps:
    - name: fail-step
      image: registry.access.redhat.com/ubi8/ubi-minimal:latest
      script: |
        #!/bin/bash
        echo "This task will fail intentionally"
        exit 1
EOF
Apply the failing task:

oc apply -f failing-task.yaml
Create a test pipeline that uses the failing task:

cat > test-failure-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: test-failure-pipeline
  namespace: pipeline-notifications
spec:
  tasks:
    - name: intentional-failure
      taskRef:
        name: failing-task
  
  finally:
    - name: notify-success
      taskRef:
        name: slack-notification
      when:
        - input: $(tasks.status)
          operator: in
          values: ["Succeeded"]
      params:
        - name: message
          value: "Test pipeline completed successfully!"
        - name: status
          value: "success"
        - name: pipeline-name
          value: "$(context.pipeline.name)"
    
    - name: notify-failure
      taskRef:
        name: slack-notification
      when:
        - input: $(tasks.status)
          operator: in
          values: ["Failed"]
      params:
        - name: message
          value: "Test pipeline failed as expected!"
        - name: status
          value: "failure"
        - name: pipeline-name
          value: "$(context.pipeline.name)"
EOF
Apply and run the test pipeline:

oc apply -f test-failure-pipeline.yaml
tkn pipeline start test-failure-pipeline --showlog
Verify failure notification appears in your Slack channel with red color and error emoji

Subtask 3.4: Advanced Notification Configuration
Let's enhance our notifications with more detailed information.

Create an enhanced notification task:

cat > enhanced-notification-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: enhanced-slack-notification
  namespace: pipeline-notifications
spec:
  params:
    - name: message
      type: string
      description: The message to send to Slack
    - name: status
      type: string
      description: Pipeline status
    - name: pipeline-name
      type: string
      description: Name of the pipeline
    - name: pipeline-run-name
      type: string
      description: Name of the pipeline run
      default: "unknown"
    - name: namespace
      type: string
      description: Namespace where pipeline is running
      default: "default"
  steps:
    - name: send-enhanced-notification
      image: curlimages/curl:latest
      env:
        - name: SLACK_WEBHOOK_URL
          valueFrom:
            secretKeyRef:
              name: slack-webhook
              key: url
      script: |
        #!/bin/sh
        
        # Set color and emoji based on status
        if [ "$(params.status)" = "success" ]; then
          COLOR="good"
          EMOJI=":white_check_mark:"
        else
          COLOR="danger"
          EMOJI=":x:"
        fi
        
        # Get current timestamp
        TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
        
        # Create enhanced JSON payload
        PAYLOAD=$(cat <<JSON
        {
          "username": "OpenShift Pipeline Bot",
          "icon_emoji": ":robot_face:",
          "attachments": [
            {
              "color": "${COLOR}",
              "title": "Pipeline Notification",
              "fields": [
                {
                  "title": "Status",
                  "value": "${EMOJI} $(params.status)",
                  "short": true
                },
                {
                  "title": "Pipeline",
                  "value": "$(params.pipeline-name)",
                  "short": true
                },
                {
                  "title": "Pipeline Run",
                  "value": "$(params.pipeline-run-name)",
                  "short": true
                },
                {
                  "title": "Namespace",
                  "value": "$(params.namespace)",
                  "short": true
                },
                {
                  "title": "Message",
                  "value": "$(params.message)",
                  "short": false
                },
                {
                  "title": "Timestamp",
                  "value": "${TIMESTAMP}",
                  "short": false
                }
              ]
            }
          ]
        }
JSON
        )
        
        # Send notification
        curl -X POST -H 'Content-type: application/json' \
          --data "${PAYLOAD}" \
          "${SLACK_WEBHOOK_URL}"
        
        echo "Enhanced notification sent to Slack"
EOF
Apply the enhanced task:

oc apply -f enhanced-notification-task.yaml
Troubleshooting Tips
Common Issues and Solutions
Issue 1: Webhook URL not working

Solution: Verify the Slack webhook URL is correct and the webhook is active in your Slack workspace
Check: Ensure the secret was created properly with the correct key name
Issue 2: Notifications not appearing in Slack

Solution: Check the pipeline logs for the notification task
Command: tkn pipelinerun logs <pipelinerun-name> -t notify-success
Issue 3: Pipeline failing to start

Solution: Verify all required ClusterTasks are available
Command: tkn clustertask list | grep -E "(git-clone|buildah)"
Issue 4: Permission errors

Solution: Ensure the service account has proper permissions
Command: oc get serviceaccount pipeline -o yaml
Debugging Commands
Check task logs:

tkn taskrun logs <taskrun-name>
Describe pipeline run:

tkn pipelinerun describe <pipelinerun-name>
Check secret contents:

oc get secret slack-webhook -o yaml
View pipeline definition:

oc get pipeline sample-app-pipeline -o yaml
Conclusion
In this lab, you have successfully:

• Created a Slack webhook integration that allows your OpenShift pipelines to send notifications to your team's communication channel • Built a reusable notification task using Tekton that can be integrated into any pipeline • Implemented pipeline notifications for both success and failure scenarios using the finally section • Tested and verified that notifications work correctly for different pipeline outcomes • Enhanced notifications with detailed information including timestamps, pipeline run names, and status indicators

Why This Matters
Pipeline notifications are crucial for:

Team Awareness: Keep team members informed about deployment status without manually checking
Rapid Response: Enable quick reaction to failed deployments or builds
Audit Trail: Maintain a record of pipeline executions in your communication channels
DevOps Culture: Foster collaboration between development and operations teams
Next Steps
Consider extending this lab by:

Adding notifications to existing pipelines in your organization
Integrating with other communication platforms (Microsoft Teams, email)
Creating conditional notifications based on specific criteria
Adding more detailed information like commit messages or test results
Implementing notification escalation for critical failures
The notification system you've built provides a foundation for comprehensive pipeline monitoring and team communication in your CI/CD workflows.
