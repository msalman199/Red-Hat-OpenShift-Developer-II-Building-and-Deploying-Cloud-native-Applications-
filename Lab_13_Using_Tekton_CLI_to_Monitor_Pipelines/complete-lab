Lab 13: Using Tekton CLI to Monitor Pipelines
Objectives
By the end of this lab, you will be able to:

• Install and configure the Tekton CLI (tkn) for pipeline management • Use tkn commands to list, view, and monitor Tekton pipelines • Access and analyze pipeline execution logs and individual task logs • Cancel running pipelines and rerun failed pipeline executions • Troubleshoot pipeline issues using CLI monitoring tools • Understand the relationship between pipelines, pipelineruns, tasks, and taskruns

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with command-line interface operations • Knowledge of YAML file structure and syntax • Understanding of CI/CD pipeline concepts • Access to a Kubernetes cluster with Tekton Pipelines installed • Basic knowledge of container technologies

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • Kubernetes cluster with Tekton Pipelines pre-installed • Tekton CLI (tkn) ready to use • Sample pipeline definitions and resources • All necessary permissions configured

Task 1: Installing and Configuring Tekton CLI
Subtask 1.1: Verify Tekton CLI Installation
First, let's verify that the Tekton CLI is properly installed and configured in your environment.

Check tkn version and installation:
tkn version
Expected output should show both client and pipeline versions:

Client version: 0.32.0
Pipeline version: v0.50.0
Verify cluster connection:
kubectl cluster-info
Check Tekton Pipelines installation:
kubectl get pods -n tekton-pipelines
Subtask 1.2: Configure tkn CLI Context
Set the default namespace for tkn operations:
kubectl config set-context --current --namespace=default
Verify current context:
kubectl config current-context
Task 2: Running tkn Pipeline Commands to List and Monitor Pipelines
Subtask 2.1: Create Sample Pipeline Resources
Before we can monitor pipelines, let's create some sample resources to work with.

Create a sample task definition:
cat << 'EOF' > hello-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello-world-task
spec:
  params:
    - name: message
      type: string
      default: "Hello World"
  steps:
    - name: echo
      image: ubuntu
      command:
        - echo
      args:
        - "$(params.message)"
    - name: sleep
      image: ubuntu
      command:
        - sleep
      args:
        - "30"
EOF
Apply the task definition:
kubectl apply -f hello-task.yaml
Create a sample pipeline:
cat << 'EOF' > hello-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello-world-pipeline
spec:
  params:
    - name: greeting
      type: string
      default: "Hello from Pipeline"
  tasks:
    - name: hello-task-1
      taskRef:
        name: hello-world-task
      params:
        - name: message
          value: "$(params.greeting) - Task 1"
    - name: hello-task-2
      taskRef:
        name: hello-world-task
      params:
        - name: message
          value: "$(params.greeting) - Task 2"
      runAfter:
        - hello-task-1
EOF
Apply the pipeline definition:
kubectl apply -f hello-pipeline.yaml
Subtask 2.2: List Available Pipelines
List all pipelines in the current namespace:
tkn pipeline list
Expected output:

NAME                   AGE             LAST RUN   STARTED   DURATION   STATUS
hello-world-pipeline   1 minute ago    ---        ---       ---        ---
List pipelines with more detailed information:
tkn pipeline list -o wide
List pipelines across all namespaces:
tkn pipeline list --all-namespaces
Subtask 2.3: View Pipeline Details
Describe a specific pipeline:
tkn pipeline describe hello-world-pipeline
View pipeline definition in YAML format:
tkn pipeline describe hello-world-pipeline -o yaml
Subtask 2.4: Start and Monitor Pipeline Execution
Start a pipeline run:
tkn pipeline start hello-world-pipeline \
  --param greeting="Welcome to Tekton Monitoring" \
  --showlog
The --showlog flag will automatically display logs as the pipeline runs.

Start a pipeline run without showing logs immediately:
tkn pipeline start hello-world-pipeline \
  --param greeting="Second Pipeline Run" \
  --use-param-defaults
List all pipeline runs:
tkn pipelinerun list
Expected output:

NAME                            STARTED          DURATION   STATUS
hello-world-pipeline-run-xyz    2 minutes ago    1m30s      Succeeded
hello-world-pipeline-run-abc    30 seconds ago   ---        Running
Monitor a specific pipeline run:
tkn pipelinerun describe hello-world-pipeline-run-abc
Task 3: Viewing Pipeline Execution Logs and Task Logs
Subtask 3.1: Access Pipeline Run Logs
View logs for the most recent pipeline run:
tkn pipelinerun logs --last
View logs for a specific pipeline run:
# Replace with actual pipelinerun name from your list
tkn pipelinerun logs hello-world-pipeline-run-abc
Follow logs in real-time for a running pipeline:
tkn pipelinerun logs hello-world-pipeline-run-abc --follow
View logs for a specific task within a pipeline run:
tkn pipelinerun logs hello-world-pipeline-run-abc --task hello-task-1
Subtask 3.2: Access Individual Task Logs
List all task runs:
tkn taskrun list
View logs for a specific task run:
# Replace with actual taskrun name from your list
tkn taskrun logs hello-world-pipeline-run-abc-hello-task-1
View logs for a specific step within a task run:
tkn taskrun logs hello-world-pipeline-run-abc-hello-task-1 --step echo
Subtask 3.3: Advanced Log Viewing Options
View logs with timestamps:
tkn pipelinerun logs --last --timestamps
View logs for all tasks in a pipeline run:
tkn pipelinerun logs hello-world-pipeline-run-abc --all
Export logs to a file:
tkn pipelinerun logs hello-world-pipeline-run-abc > pipeline-logs.txt
Task 4: Using tkn to Cancel or Rerun Failed Pipelines
Subtask 4.1: Create a Pipeline That Will Fail
Let's create a pipeline that will intentionally fail so we can practice canceling and rerunning it.

Create a failing task:
cat << 'EOF' > failing-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: failing-task
spec:
  steps:
    - name: success-step
      image: ubuntu
      command:
        - echo
      args:
        - "This step will succeed"
    - name: long-running-step
      image: ubuntu
      command:
        - sleep
      args:
        - "60"
    - name: failing-step
      image: ubuntu
      command:
        - sh
        - -c
      args:
        - "echo 'About to fail' && exit 1"
EOF
Apply the failing task:
kubectl apply -f failing-task.yaml
Create a pipeline with the failing task:
cat << 'EOF' > failing-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: failing-pipeline
spec:
  tasks:
    - name: failing-task
      taskRef:
        name: failing-task
EOF
Apply the failing pipeline:
kubectl apply -f failing-pipeline.yaml
Subtask 4.2: Start and Cancel a Pipeline Run
Start the failing pipeline:
tkn pipeline start failing-pipeline
Note the pipeline run name from the output.

Monitor the pipeline run status:
tkn pipelinerun list
Cancel the running pipeline before it fails:
# Replace with your actual pipelinerun name
tkn pipelinerun cancel failing-pipeline-run-xyz
Verify the cancellation:
tkn pipelinerun describe failing-pipeline-run-xyz
The status should show as "Cancelled".

Subtask 4.3: Handle Failed Pipeline Runs
Start the failing pipeline again and let it fail:
tkn pipeline start failing-pipeline --showlog
Wait for the pipeline to complete and fail.

List pipeline runs to see the failed status:
tkn pipelinerun list
You should see a pipeline run with "Failed" status.

View the failure details:
tkn pipelinerun describe failing-pipeline-run-abc
View logs of the failed pipeline:
tkn pipelinerun logs failing-pipeline-run-abc
Subtask 4.4: Rerun Failed Pipelines
Rerun a failed pipeline with the same parameters:
# This creates a new pipeline run based on the failed one
tkn pipeline start failing-pipeline
Create a corrected version of the failing task:
cat << 'EOF' > corrected-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: corrected-task
spec:
  steps:
    - name: success-step
      image: ubuntu
      command:
        - echo
      args:
        - "This step will succeed"
    - name: another-success-step
      image: ubuntu
      command:
        - echo
      args:
        - "This step will also succeed"
EOF
Apply the corrected task:
kubectl apply -f corrected-task.yaml
Create a corrected pipeline:
cat << 'EOF' > corrected-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: corrected-pipeline
spec:
  tasks:
    - name: corrected-task
      taskRef:
        name: corrected-task
EOF
Apply and run the corrected pipeline:
kubectl apply -f corrected-pipeline.yaml
tkn pipeline start corrected-pipeline --showlog
Subtask 4.5: Advanced Pipeline Management
Delete failed pipeline runs:
# Delete a specific pipeline run
tkn pipelinerun delete failing-pipeline-run-abc

# Delete all failed pipeline runs
tkn pipelinerun delete --all --ignore-running=false
Set up automatic cleanup of old pipeline runs:
# View current pipeline runs
tkn pipelinerun list

# Keep only the last 3 pipeline runs for a pipeline
tkn pipelinerun delete --keep 3 --pipeline hello-world-pipeline
Export pipeline run details for analysis:
tkn pipelinerun describe failing-pipeline-run-abc -o json > failed-run-analysis.json
Advanced Monitoring Techniques
Monitoring Multiple Pipelines
Watch pipeline runs in real-time:
watch -n 5 'tkn pipelinerun list'
Create a monitoring script:
cat << 'EOF' > monitor-pipelines.sh
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
EOF

chmod +x monitor-pipelines.sh
./monitor-pipelines.sh
Setting Up Alerts and Notifications
Create a script to check for failed pipelines:
cat << 'EOF' > check-failures.sh
#!/bin/bash
FAILED_RUNS=$(tkn pipelinerun list -o jsonpath='{.items[?(@.status.conditions[0].reason=="Failed")].metadata.name}')

if [ ! -z "$FAILED_RUNS" ]; then
    echo "ALERT: Failed pipeline runs detected:"
    echo "$FAILED_RUNS"
    # Here you could add notification logic (email, Slack, etc.)
else
    echo "All pipeline runs are healthy"
fi
EOF

chmod +x check-failures.sh
./check-failures.sh
Troubleshooting Common Issues
Issue 1: Pipeline Run Stuck in Pending State
Symptoms: Pipeline run shows "Pending" status for extended time

Diagnosis:

tkn pipelinerun describe <pipelinerun-name>
kubectl describe pipelinerun <pipelinerun-name>
Common Solutions:

Check resource quotas and limits
Verify task definitions exist
Check for scheduling issues
Issue 2: Task Logs Not Available
Symptoms: tkn taskrun logs returns empty or error

Diagnosis:

kubectl get pods -l tekton.dev/taskRun=<taskrun-name>
kubectl logs <pod-name>
Solutions:

Check if pods were cleaned up too quickly
Verify log retention policies
Check pod status and events
Issue 3: Permission Denied Errors
Symptoms: tkn commands fail with permission errors

Diagnosis:

kubectl auth can-i create pipelineruns
kubectl auth can-i get pipelines
Solutions:

Check RBAC permissions
Verify service account configuration
Contact cluster administrator
Lab Cleanup
Remove created resources:
kubectl delete pipeline hello-world-pipeline failing-pipeline corrected-pipeline
kubectl delete task hello-world-task failing-task corrected-task
kubectl delete pipelinerun --all
kubectl delete taskrun --all
Clean up files:
rm -f hello-task.yaml hello-pipeline.yaml failing-task.yaml failing-pipeline.yaml
rm -f corrected-task.yaml corrected-pipeline.yaml
rm -f pipeline-logs.txt failed-run-analysis.json
rm -f monitor-pipelines.sh check-failures.sh
Conclusion
In this comprehensive lab, you have successfully learned how to use the Tekton CLI to monitor and manage pipelines effectively. You accomplished the following key objectives:

Pipeline Management Skills Acquired: • Mastered tkn CLI commands for listing, describing, and monitoring pipelines • Learned to access and analyze both pipeline-level and task-level logs • Gained experience in canceling running pipelines and rerunning failed executions • Developed troubleshooting skills for common pipeline issues

Practical Experience Gained: • Created and managed multiple pipeline definitions with varying complexity • Implemented real-time monitoring techniques for pipeline execution • Practiced handling failure scenarios and recovery procedures • Set up automated monitoring and alerting mechanisms

Why This Matters: These skills are essential for DevOps engineers and developers working with cloud-native CI/CD pipelines. The ability to effectively monitor, troubleshoot, and manage Tekton pipelines is crucial for maintaining reliable software delivery processes in production environments. The techniques you've learned will help you quickly identify issues, minimize downtime, and ensure smooth operation of your CI/CD infrastructure.

The hands-on experience with both successful and failed pipeline scenarios has prepared you to handle real-world situations where quick diagnosis and resolution of pipeline issues are critical for maintaining development velocity and system reliability.
