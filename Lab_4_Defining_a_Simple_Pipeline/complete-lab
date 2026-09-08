Lab 4: Defining a Simple Pipeline
Objectives
By the end of this lab, you will be able to:

• Understand the structure and components of a Tekton pipeline YAML definition • Create a complete pipeline YAML file that incorporates build tasks • Execute pipelines manually using the Tekton CLI (tkn) command-line tool • Monitor pipeline execution through real-time logs and status checking • Troubleshoot common pipeline execution issues • Understand the relationship between tasks, pipelines, and pipeline runs in Tekton

Prerequisites
Before starting this lab, you should have:

• Basic understanding of YAML syntax and structure • Familiarity with Kubernetes concepts (pods, services, deployments) • Knowledge of container concepts and containerization • Basic command-line interface (CLI) experience • Completion of previous Tekton labs covering tasks and task runs • Understanding of CI/CD pipeline concepts

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with Tekton Pipelines operator installed • Tekton CLI (tkn) pre-installed and configured • kubectl command-line tool • Text editor (vim/nano) • All necessary permissions and access rights

Task 1: Create a Pipeline YAML that Includes the Build Task
Subtask 1.1: Understanding Pipeline Structure
Before creating the pipeline, let's understand the key components:

• Pipeline: A collection of tasks that run in a specific order • Tasks: Individual units of work within a pipeline • Parameters: Input values that can be passed to pipelines and tasks • Workspaces: Shared storage between tasks in a pipeline

Subtask 1.2: Create the Build Task Definition
First, we need to create a build task that our pipeline will use.

Create a new file for the build task:
vi build-task.yaml
Add the following build task definition:
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-app
  namespace: default
spec:
  description: "Build application using buildah"
  params:
    - name: image-name
      description: "Name of the image to build"
      type: string
      default: "my-app"
    - name: image-tag
      description: "Tag for the image"
      type: string
      default: "latest"
  workspaces:
    - name: source
      description: "Workspace containing source code"
  steps:
    - name: build-image
      image: quay.io/buildah/stable:v1.23.1
      workingDir: $(workspaces.source.path)
      script: |
        #!/usr/bin/env bash
        echo "Starting build process..."
        echo "Building image: $(params.image-name):$(params.image-tag)"
        
        # Create a simple Dockerfile if it doesn't exist
        if [ ! -f Dockerfile ]; then
          cat > Dockerfile << EOF
        FROM registry.access.redhat.com/ubi8/ubi:latest
        WORKDIR /app
        COPY . /app
        RUN echo "Application built successfully"
        CMD ["echo", "Hello from containerized app"]
        EOF
        fi
        
        # Build the container image
        buildah build -t $(params.image-name):$(params.image-tag) .
        echo "Build completed successfully"
      securityContext:
        privileged: true
Apply the build task to your cluster:
kubectl apply -f build-task.yaml
Verify the task was created:
tkn task list
Subtask 1.3: Create the Pipeline YAML Definition
Now, let's create the main pipeline that uses our build task.

Create a new file for the pipeline:
vi simple-pipeline.yaml
Add the following pipeline definition:
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: simple-build-pipeline
  namespace: default
spec:
  description: "A simple pipeline that builds an application"
  params:
    - name: app-name
      description: "Name of the application to build"
      type: string
      default: "sample-app"
    - name: app-version
      description: "Version tag for the application"
      type: string
      default: "v1.0.0"
    - name: git-url
      description: "Git repository URL"
      type: string
      default: "https://github.com/tektoncd/pipeline.git"
  workspaces:
    - name: shared-data
      description: "Shared workspace for pipeline tasks"
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: "main"
      workspaces:
        - name: output
          workspace: shared-data
    - name: build-application
      taskRef:
        name: build-app
      runAfter:
        - fetch-source
      params:
        - name: image-name
          value: $(params.app-name)
        - name: image-tag
          value: $(params.app-version)
      workspaces:
        - name: source
          workspace: shared-data
    - name: display-results
      taskRef:
        name: echo-hello
        kind: ClusterTask
      runAfter:
        - build-application
      params:
        - name: echo-message
          value: "Pipeline completed! Built $(params.app-name):$(params.app-version)"
Apply the pipeline to your cluster:
kubectl apply -f simple-pipeline.yaml
Verify the pipeline was created successfully:
tkn pipeline list
You should see output similar to:

NAME                   AGE
simple-build-pipeline  1m
Subtask 1.4: Create Supporting Resources
Create a PersistentVolumeClaim for the workspace:

Create a PVC file:
vi pipeline-pvc.yaml
Add the PVC definition:
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
Apply the PVC:
kubectl apply -f pipeline-pvc.yaml
Task 2: Trigger the Pipeline Manually Using tkn
Subtask 2.1: Understanding Pipeline Execution
Before triggering the pipeline, let's understand the execution process:

• PipelineRun: An instance of a pipeline execution • TaskRun: An instance of a task execution within a pipeline • Parameters: Values passed to the pipeline at runtime • Workspaces: Storage bindings for the pipeline execution

Subtask 2.2: Trigger Pipeline with Default Parameters
Start the pipeline with default parameters:
tkn pipeline start simple-build-pipeline \
  --workspace name=shared-data,claimName=pipeline-workspace-pvc \
  --showlog
The --showlog flag will automatically display logs as the pipeline runs.

Subtask 2.3: Trigger Pipeline with Custom Parameters
Start the pipeline with custom parameters:
tkn pipeline start simple-build-pipeline \
  --param app-name=my-custom-app \
  --param app-version=v2.0.0 \
  --param git-url=https://github.com/tektoncd/pipeline.git \
  --workspace name=shared-data,claimName=pipeline-workspace-pvc \
  --showlog
Subtask 2.4: Trigger Pipeline Interactively
Start the pipeline in interactive mode:
tkn pipeline start simple-build-pipeline -i
Follow the prompts to:
Select or enter parameter values
Choose workspace bindings
Confirm the pipeline execution
Subtask 2.5: Create and Use a PipelineRun YAML
For more control, you can create a PipelineRun YAML file:

Create a PipelineRun file:
vi pipeline-run.yaml
Add the PipelineRun definition:
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: simple-build-pipeline-run-001
  namespace: default
spec:
  pipelineRef:
    name: simple-build-pipeline
  params:
    - name: app-name
      value: "yaml-triggered-app"
    - name: app-version
      value: "v3.0.0"
    - name: git-url
      value: "https://github.com/tektoncd/pipeline.git"
  workspaces:
    - name: shared-data
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
Apply the PipelineRun:
kubectl apply -f pipeline-run.yaml
Monitor the execution:
tkn pipelinerun logs simple-build-pipeline-run-001 -f
Task 3: Monitor the Pipeline Execution Through Logs and Status
Subtask 3.1: Real-time Log Monitoring
List all pipeline runs:
tkn pipelinerun list
Follow logs for a specific pipeline run:
tkn pipelinerun logs <pipelinerun-name> -f
View logs for a specific task within the pipeline:
tkn pipelinerun logs <pipelinerun-name> -t <task-name>
Subtask 3.2: Check Pipeline Status
Get detailed status of a pipeline run:
tkn pipelinerun describe <pipelinerun-name>
Check the status using kubectl:
kubectl get pipelinerun <pipelinerun-name> -o yaml
Monitor pipeline run status in real-time:
watch "tkn pipelinerun list"
Subtask 3.3: Advanced Monitoring Techniques
View pipeline run events:
kubectl get events --field-selector involvedObject.name=<pipelinerun-name>
Check individual task run status:
tkn taskrun list
Get detailed task run information:
tkn taskrun describe <taskrun-name>
Subtask 3.4: Troubleshooting Failed Pipelines
Check failed pipeline runs:
tkn pipelinerun list --limit 10
View detailed error information:
tkn pipelinerun describe <failed-pipelinerun-name>
Check pod logs for failed tasks:
kubectl logs <pod-name> -c step-<step-name>
Debug by examining the pipeline run YAML:
kubectl get pipelinerun <pipelinerun-name> -o yaml | grep -A 10 -B 10 "status"
Subtask 3.5: Pipeline Execution Verification
Create a simple verification script:
vi verify-pipeline.sh
Add the verification script:
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
Make the script executable and run it:
chmod +x verify-pipeline.sh
./verify-pipeline.sh
Common Troubleshooting Tips
Issue 1: Pipeline Fails to Start
Symptoms: Pipeline run is created but never starts executing

Solutions:

Check if the pipeline exists:
tkn pipeline list
Verify workspace PVC exists:
kubectl get pvc
Check for sufficient resources:
kubectl describe nodes
Issue 2: Task Fails During Execution
Symptoms: Pipeline starts but fails at a specific task

Solutions:

Check task logs:
tkn pipelinerun logs <pipelinerun-name> -t <failed-task-name>
Verify task definition:
tkn task describe <task-name>
Check pod events:
kubectl get events --sort-by='.lastTimestamp'
Issue 3: Workspace Issues
Symptoms: Tasks fail with workspace-related errors

Solutions:

Verify PVC status:
kubectl get pvc pipeline-workspace-pvc
Check workspace bindings in pipeline run:
kubectl get pipelinerun <name> -o yaml | grep -A 5 workspaces
Conclusion
In this lab, you have successfully:

• Created a comprehensive pipeline YAML that includes a build task with proper parameter handling and workspace configuration • Learned multiple methods to trigger pipelines using the tkn CLI tool, including interactive mode and YAML-based pipeline runs • Mastered pipeline monitoring techniques through real-time log streaming, status checking, and troubleshooting failed executions • Implemented best practices for pipeline organization, parameter management, and workspace utilization

Why This Matters: Understanding how to define and execute Tekton pipelines is fundamental to implementing CI/CD workflows in cloud-native environments. These skills enable you to automate build, test, and deployment processes, making your development workflow more efficient and reliable. The monitoring and troubleshooting techniques you've learned are essential for maintaining robust pipeline operations in production environments.

Next Steps: With this foundation, you're ready to explore more advanced pipeline concepts such as conditional execution, parallel tasks, pipeline triggers, and integration with external systems. These skills directly support the Red Hat OpenShift Developer II certification objectives and prepare you for real-world cloud-native application development scenarios.
