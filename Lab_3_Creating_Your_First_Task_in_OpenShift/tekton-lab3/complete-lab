Lab 3: Creating Your First Task in OpenShift
Objectives
By the end of this lab, you will be able to:

• Understand the fundamentals of Tekton Tasks and their role in OpenShift Pipelines • Create a YAML-based Tekton Task definition for building Docker container images • Apply Tekton Tasks to an OpenShift cluster using the command line interface • Verify successful task execution and troubleshoot common issues • Navigate the OpenShift web console to monitor task execution • Understand the relationship between Tasks, Steps, and container images in Tekton

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, containers, namespaces) • Familiarity with YAML syntax and structure • Basic knowledge of Docker and container images • Understanding of command-line interface operations • Completed previous OpenShift labs or equivalent experience with OpenShift basics

Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with OpenShift already installed and configured. Simply click Start Lab to access your environment. No need to build your own virtual machine or install OpenShift locally. Your lab environment includes:

• OpenShift cluster with Tekton Pipelines operator pre-installed • Command-line tools (oc, tkn) already configured • Access to both CLI and web console • Sample application code ready for use

Lab Environment Setup
Task 1: Verify Your OpenShift Environment
Subtask 1.1: Access Your Lab Environment
Click the Start Lab button to launch your cloud machine
Wait for the environment to fully initialize (approximately 2-3 minutes)
Open the terminal application from the desktop
Subtask 1.2: Verify OpenShift Connection
Check your OpenShift connection status:
oc whoami
Verify you can see the current project:
oc project
List available projects to confirm access:
oc get projects
Expected output should show your username and current project information.

Subtask 1.3: Verify Tekton Installation
Check if Tekton Pipelines operator is installed:
oc get pods -n openshift-pipelines
Verify Tekton CLI is available:
tkn version
You should see both client and pipeline versions displayed.

Main Lab Tasks
Task 2: Write a Tekton Task in YAML to Build a Docker Container Image
Subtask 2.1: Create Project Directory Structure
Create a new directory for your lab work:
mkdir ~/tekton-lab3
cd ~/tekton-lab3
Create a subdirectory for task definitions:
mkdir tasks
cd tasks
Subtask 2.2: Create the Tekton Task YAML File
Create a new file called build-image-task.yaml:
nano build-image-task.yaml
Copy and paste the following Tekton Task definition:
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-docker-image
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: "0.17.0"
    tekton.dev/categories: Image Build
    tekton.dev/tags: image-build, docker
    tekton.dev/displayName: "Build Docker Image"
    tekton.dev/platforms: "linux/amd64"
spec:
  description: >-
    This task builds a Docker container image using Buildah.
    It demonstrates the basic structure of a Tekton task for image building.
  
  params:
    - name: IMAGE
      description: Reference of the image to build
      type: string
      default: "image-registry.openshift-image-registry.svc:5000/$(context.taskRun.namespace)/sample-app:latest"
    
    - name: DOCKERFILE
      description: Path to the Dockerfile to build
      type: string
      default: "./Dockerfile"
    
    - name: CONTEXT
      description: The build context used by Buildah
      type: string
      default: "."
    
    - name: TLSVERIFY
      description: Verify the TLS on the registry endpoint
      type: string
      default: "false"

  workspaces:
    - name: source
      description: Workspace containing the source code to build
      mountPath: /workspace/source

  steps:
    - name: build-and-push
      image: registry.redhat.io/ubi8/buildah:latest
      workingDir: $(workspaces.source.path)
      script: |
        #!/usr/bin/env bash
        set -e
        
        echo "Starting image build process..."
        echo "Building image: $(params.IMAGE)"
        echo "Using Dockerfile: $(params.DOCKERFILE)"
        echo "Build context: $(params.CONTEXT)"
        
        # Build the container image
        buildah bud \
          --format=oci \
          --tls-verify=$(params.TLSVERIFY) \
          --no-cache \
          -f $(params.DOCKERFILE) \
          -t $(params.IMAGE) \
          $(params.CONTEXT)
        
        echo "Image built successfully!"
        
        # Push the image to registry
        echo "Pushing image to registry..."
        buildah push \
          --tls-verify=$(params.TLSVERIFY) \
          $(params.IMAGE) \
          docker://$(params.IMAGE)
        
        echo "Image pushed successfully!"
        echo "Build process completed."
      
      securityContext:
        privileged: true
      
      volumeMounts:
        - name: varlibcontainers
          mountPath: /var/lib/containers

  volumes:
    - name: varlibcontainers
      emptyDir: {}
Save the file by pressing Ctrl+X, then Y, then Enter
Subtask 2.3: Create Sample Application Files
Navigate back to the main lab directory:
cd ~/tekton-lab3
Create a simple sample application directory:
mkdir sample-app
cd sample-app
Create a simple Dockerfile:
nano Dockerfile
Add the following Dockerfile content:
FROM registry.access.redhat.com/ubi8/ubi:latest

# Install basic tools
RUN yum update -y && \
    yum install -y httpd && \
    yum clean all

# Create a simple HTML page
RUN echo '<html><body><h1>Hello from Tekton Task!</h1><p>This image was built using a Tekton Task in OpenShift.</p></body></html>' > /var/www/html/index.html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
Save the file (Ctrl+X, Y, Enter)

Create a simple README file:

nano README.md
Add the following content:
# Sample Application

This is a simple web application built for demonstrating Tekton Tasks in OpenShift.

## Features
- Basic HTML page
- Apache web server
- Built with Red Hat UBI base image
Save the file (Ctrl+X, Y, Enter)
Task 3: Apply the Task to OpenShift
Subtask 3.1: Create or Switch to Working Project
Create a new project for this lab:
oc new-project tekton-lab3-$(whoami)
Verify you're in the correct project:
oc project
Subtask 3.2: Apply the Tekton Task
Navigate to the tasks directory:
cd ~/tekton-lab3/tasks
Apply the task definition to OpenShift:
oc apply -f build-image-task.yaml
Verify the task was created successfully:
oc get tasks
Get detailed information about your task:
oc describe task build-docker-image
Subtask 3.3: Create Required Resources
Create a PersistentVolumeClaim for the workspace:
nano workspace-pvc.yaml
Add the following PVC definition:
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: source-workspace-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
Save and apply the PVC:
oc apply -f workspace-pvc.yaml
Verify the PVC was created:
oc get pvc
Subtask 3.4: Create a TaskRun to Execute the Task
First, copy your source code to the workspace. Create a job to populate the PVC:
nano populate-workspace-job.yaml
Add the following job definition:
apiVersion: batch/v1
kind: Job
metadata:
  name: populate-workspace
spec:
  template:
    spec:
      containers:
      - name: populate
        image: registry.access.redhat.com/ubi8/ubi:latest
        command: ["/bin/bash"]
        args:
          - -c
          - |
            echo "Populating workspace with sample application..."
            mkdir -p /workspace/source
            cd /workspace/source
            
            # Create Dockerfile
            cat > Dockerfile << 'EOF'
            FROM registry.access.redhat.com/ubi8/ubi:latest
            
            RUN yum update -y && \
                yum install -y httpd && \
                yum clean all
            
            RUN echo '<html><body><h1>Hello from Tekton Task!</h1><p>This image was built using a Tekton Task in OpenShift.</p></body></html>' > /var/www/html/index.html
            
            EXPOSE 80
            
            CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
            EOF
            
            # Create README
            cat > README.md << 'EOF'
            # Sample Application
            This is a simple web application built for demonstrating Tekton Tasks in OpenShift.
            EOF
            
            echo "Workspace populated successfully!"
            ls -la /workspace/source/
        volumeMounts:
        - name: workspace
          mountPath: /workspace
      volumes:
      - name: workspace
        persistentVolumeClaim:
          claimName: source-workspace-pvc
      restartPolicy: Never
  backoffLimit: 4
Apply the job:
oc apply -f populate-workspace-job.yaml
Wait for the job to complete:
oc wait --for=condition=complete job/populate-workspace --timeout=300s
Now create a TaskRun to execute your task:
nano taskrun-build-image.yaml
Add the following TaskRun definition:
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: build-image-run-$(date +%s)
  generateName: build-image-run-
spec:
  taskRef:
    name: build-docker-image
  params:
    - name: IMAGE
      value: "image-registry.openshift-image-registry.svc:5000/$(context.taskRun.namespace)/sample-app:latest"
    - name: DOCKERFILE
      value: "./Dockerfile"
    - name: CONTEXT
      value: "."
    - name: TLSVERIFY
      value: "false"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: source-workspace-pvc
Apply the TaskRun:
oc apply -f taskrun-build-image.yaml
Task 4: Verify That the Task Executes Successfully
Subtask 4.1: Monitor TaskRun Execution
List all TaskRuns to see your running task:
oc get taskruns
Watch the TaskRun status in real-time:
oc get taskruns -w
Press Ctrl+C to stop watching after you see the status change to "Succeeded".

Get detailed information about the TaskRun:
TASKRUN_NAME=$(oc get taskruns -o jsonpath='{.items[0].metadata.name}')
oc describe taskrun $TASKRUN_NAME
Subtask 4.2: View Task Execution Logs
View the logs from the task execution:
oc logs -f taskrun/$TASKRUN_NAME
If you want to see logs from a specific step:
tkn taskrun logs $TASKRUN_NAME -s build-and-push
Subtask 4.3: Verify Image Creation
Check if the image was created in the internal registry:
oc get imagestreams
Get detailed information about the image:
oc describe imagestream sample-app
List the image tags:
oc get imagestreamtags
Subtask 4.4: Verify Using OpenShift Web Console
Get the web console URL:
oc whoami --show-console
Open the URL in your browser and log in with your credentials

Navigate to your project: Projects → tekton-lab3-[your-username]

Go to Pipelines → Tasks to see your created task

Click on TaskRuns to see the execution history

Click on your TaskRun name to see detailed execution information and logs

Subtask 4.5: Test the Built Image (Optional)
Create a simple deployment using your built image:
oc new-app sample-app:latest --name=sample-web-app
Expose the service:
oc expose service sample-web-app
Get the route URL:
oc get route sample-web-app
Test the application by visiting the URL in your browser or using curl:
ROUTE_URL=$(oc get route sample-web-app -o jsonpath='{.spec.host}')
curl http://$ROUTE_URL
Troubleshooting Common Issues
Issue 1: Task Creation Fails
Problem: Error applying the task YAML file

Solution:

Verify YAML syntax using an online YAML validator
Check that you're in the correct project
Ensure Tekton Pipelines operator is installed
Issue 2: TaskRun Fails with Permission Errors
Problem: TaskRun fails due to security context issues

Solution:

Verify that the task has privileged: true in securityContext
Check that your project has the necessary permissions for privileged containers
Issue 3: Image Push Fails
Problem: Cannot push image to registry

Solution:

Verify the internal registry is accessible
Check that the image name format is correct
Ensure TLSVERIFY is set to "false" for internal registry
Issue 4: Workspace Issues
Problem: Cannot access files in workspace

Solution:

Verify PVC was created successfully
Check that the populate-workspace job completed
Ensure workspace is properly mounted in the task
Key Concepts Review
Tekton Tasks
Tasks are reusable building blocks that define a series of steps
Each step runs in its own container
Tasks can accept parameters to make them flexible and reusable
Workspaces
Workspaces provide shared storage between steps
They can be backed by PVCs, ConfigMaps, or Secrets
Essential for sharing source code and build artifacts
TaskRuns
TaskRuns are instances of task execution
They provide specific parameter values and workspace bindings
Each TaskRun creates pods to execute the task steps
Conclusion
Congratulations! You have successfully completed Lab 3: Creating Your First Task in OpenShift. In this lab, you accomplished the following:

• Created a comprehensive Tekton Task that builds Docker container images using Buildah, demonstrating the fundamental structure of CI/CD automation in OpenShift • Applied the task to your OpenShift cluster using YAML definitions and the oc command-line tool, gaining hands-on experience with Kubernetes resource management • Verified successful task execution through multiple methods including CLI monitoring, log analysis, and web console inspection • Built and pushed a container image to OpenShift's internal registry, completing the full container build workflow • Learned troubleshooting techniques for common issues that arise when working with Tekton tasks

Why This Matters
This lab provides the foundation for building sophisticated CI/CD pipelines in OpenShift. The skills you've developed here are essential for:

DevOps Automation: Automating build processes reduces manual errors and increases deployment frequency
Container-Native Development: Understanding how to build images within Kubernetes environments is crucial for cloud-native applications
Enterprise Integration: These techniques scale to support complex enterprise development workflows
Red Hat Certification: The concepts covered align directly with Red Hat OpenShift Developer II certification objectives
Next Steps
With this foundation, you're ready to explore more advanced Tekton concepts such as:

Creating multi-step pipelines that chain tasks together
Implementing conditional execution and parallel task processing
Integrating with external systems like Git repositories and artifact registries
Building comprehensive CI/CD workflows for production applications
The task you created can be reused and modified for different applications, making it a valuable template for future development projects.
