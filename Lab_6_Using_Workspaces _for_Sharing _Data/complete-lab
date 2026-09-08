Lab 6: Using Workspaces for Sharing Data
Objectives
By the end of this lab, you will be able to:

• Understand the concept of workspaces in OpenShift Pipelines and their role in data sharing • Define and configure workspaces in pipeline YAML definitions • Modify pipeline tasks to utilize shared workspaces for storing and accessing build artifacts • Implement workspace sharing between multiple tasks in a pipeline • Test and validate workspace functionality to ensure proper data persistence and sharing • Troubleshoot common workspace-related issues in pipeline execution

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, volumes, persistent volumes) • Familiarity with OpenShift Pipelines and Tekton fundamentals • Experience with YAML syntax and structure • Knowledge of Git version control system • Understanding of container build processes and artifacts • Completion of previous OpenShift Pipeline labs or equivalent experience

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift and all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes: • OpenShift cluster with Pipelines operator installed • Command-line tools (oc, tkn, git) • Sample application code repository • Pre-configured user permissions

Task 1: Understanding Workspaces and Creating Basic Pipeline Structure
Subtask 1.1: Connect to Your Lab Environment
Click Start Lab to access your cloud machine
Open the terminal application
Verify your OpenShift connection:
oc whoami
oc project
Check if OpenShift Pipelines operator is installed:
oc get pods -n openshift-pipelines
Subtask 1.2: Create Project and Initial Setup
Create a new project for this lab:
oc new-project workspace-lab-$(whoami)
Create a working directory for your pipeline files:
mkdir ~/workspace-pipeline-lab
cd ~/workspace-pipeline-lab
Clone a sample application repository:
git clone https://github.com/openshift/nodejs-ex.git
cd nodejs-ex
Subtask 1.3: Understanding Workspace Concepts
Workspaces in OpenShift Pipelines serve as shared storage volumes that can be mounted across multiple tasks within a pipeline. They enable:

• Data Persistence: Store build artifacts, source code, and intermediate files • Task Communication: Share data between different pipeline tasks • Volume Management: Abstract storage implementation from pipeline logic

Key workspace types: • emptyDir: Temporary storage that exists for the pipeline run duration • persistentVolumeClaim: Persistent storage that survives pipeline runs • configMap/secret: Read-only configuration data

Task 2: Define a Workspace in Pipeline YAML
Subtask 2.1: Create Pipeline with Workspace Definition
Create a pipeline YAML file with workspace definition:
cat > pipeline-with-workspace.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-and-deploy-with-workspace
spec:
  description: Pipeline demonstrating workspace usage for sharing data
  params:
    - name: git-url
      type: string
      description: Git repository URL
      default: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      type: string
      description: Git revision to checkout
      default: main
    - name: image-name
      type: string
      description: Name of the image to build
      default: nodejs-app
  workspaces:
    - name: shared-data
      description: Workspace for sharing data between tasks
    - name: git-credentials
      description: Workspace for git credentials (optional)
      optional: true
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
        - name: deleteExisting
          value: "true"
      workspaces:
        - name: output
          workspace: shared-data
    - name: list-source
      taskRef:
        name: list-directory
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-data
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - list-source
      params:
        - name: IMAGE
          value: "image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(params.image-name):latest"
        - name: DOCKERFILE
          value: "./Dockerfile"
      workspaces:
        - name: source
          workspace: shared-data
EOF
Subtask 2.2: Create Custom Task for Directory Listing
Create a custom task to demonstrate workspace usage:
cat > list-directory-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: list-directory
spec:
  description: List contents of workspace directory
  workspaces:
    - name: source
      description: Source code workspace
      mountPath: /workspace/source
  steps:
    - name: list-contents
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        echo "=== Workspace Contents ==="
        ls -la /workspace/source/
        echo ""
        echo "=== File Count ==="
        find /workspace/source -type f | wc -l
        echo ""
        echo "=== Directory Structure ==="
        tree /workspace/source/ || find /workspace/source -type d
        echo ""
        echo "=== Package.json Contents (if exists) ==="
        if [ -f /workspace/source/package.json ]; then
          cat /workspace/source/package.json
        else
          echo "No package.json found"
        fi
EOF
Subtask 2.3: Create Dockerfile for the Application
Create a simple Dockerfile for the Node.js application:
cat > Dockerfile << 'EOF'
FROM registry.redhat.io/ubi8/nodejs-16:latest

# Set working directory
WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
EOF
Task 3: Modify Tasks to Use Shared Workspace for Storing Build Artifacts
Subtask 3.1: Apply Pipeline Resources
Apply the custom task to your cluster:
oc apply -f list-directory-task.yaml
Apply the pipeline definition:
oc apply -f pipeline-with-workspace.yaml
Verify the resources were created:
oc get tasks
oc get pipelines
Subtask 3.2: Create PersistentVolumeClaim for Workspace
Create a PVC to back the workspace:
cat > workspace-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
Apply the PVC:
oc apply -f workspace-pvc.yaml
Verify PVC creation:
oc get pvc
Subtask 3.3: Create Enhanced Task for Build Artifacts
Create a task that generates and stores build artifacts:
cat > create-artifacts-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: create-build-artifacts
spec:
  description: Create build artifacts and metadata
  params:
    - name: app-name
      type: string
      default: nodejs-app
  workspaces:
    - name: source
      description: Source code workspace
      mountPath: /workspace/source
  steps:
    - name: create-artifacts
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        set -e
        
        echo "=== Creating Build Artifacts ==="
        
        # Create artifacts directory
        mkdir -p /workspace/source/artifacts
        
        # Create build metadata
        cat > /workspace/source/artifacts/build-info.json << EOF
        {
          "buildTime": "$(date -Iseconds)",
          "appName": "$(params.app-name)",
          "buildNumber": "${RANDOM}",
          "gitCommit": "$(cat /workspace/source/.git/HEAD 2>/dev/null || echo 'unknown')",
          "builder": "tekton-pipeline"
        }
        EOF
        
        # Create a simple build report
        cat > /workspace/source/artifacts/build-report.txt << EOF
        Build Report
        ============
        Application: $(params.app-name)
        Build Time: $(date)
        Source Files: $(find /workspace/source -name "*.js" -o -name "*.json" | wc -l)
        Total Files: $(find /workspace/source -type f | wc -l)
        
        Source Structure:
        $(find /workspace/source -type f -name "*.js" -o -name "*.json" | head -10)
        EOF
        
        # Create version file
        echo "1.0.${RANDOM}" > /workspace/source/artifacts/version.txt
        
        echo "=== Artifacts Created ==="
        ls -la /workspace/source/artifacts/
        
        echo "=== Build Info ==="
        cat /workspace/source/artifacts/build-info.json
EOF
Apply the artifacts task:
oc apply -f create-artifacts-task.yaml
Subtask 3.4: Create Task to Consume Build Artifacts
Create a task that reads and processes the build artifacts:
cat > process-artifacts-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: process-build-artifacts
spec:
  description: Process and validate build artifacts
  workspaces:
    - name: source
      description: Source code workspace with artifacts
      mountPath: /workspace/source
  steps:
    - name: process-artifacts
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        set -e
        
        echo "=== Processing Build Artifacts ==="
        
        # Check if artifacts directory exists
        if [ ! -d "/workspace/source/artifacts" ]; then
          echo "ERROR: Artifacts directory not found!"
          exit 1
        fi
        
        echo "=== Available Artifacts ==="
        ls -la /workspace/source/artifacts/
        
        # Process build info
        if [ -f "/workspace/source/artifacts/build-info.json" ]; then
          echo "=== Build Information ==="
          cat /workspace/source/artifacts/build-info.json | python3 -m json.tool
        fi
        
        # Process build report
        if [ -f "/workspace/source/artifacts/build-report.txt" ]; then
          echo "=== Build Report ==="
          cat /workspace/source/artifacts/build-report.txt
        fi
        
        # Process version
        if [ -f "/workspace/source/artifacts/version.txt" ]; then
          VERSION=$(cat /workspace/source/artifacts/version.txt)
          echo "=== Application Version: $VERSION ==="
        fi
        
        # Create summary
        cat > /workspace/source/artifacts/processing-summary.txt << EOF
        Processing Summary
        ==================
        Processed at: $(date)
        Artifacts found: $(ls /workspace/source/artifacts/ | wc -l)
        Processing status: SUCCESS
        EOF
        
        echo "=== Processing Complete ==="
        cat /workspace/source/artifacts/processing-summary.txt
EOF
Apply the processing task:
oc apply -f process-artifacts-task.yaml
Task 4: Test Workspace Sharing Between Tasks
Subtask 4.1: Create Enhanced Pipeline with Artifact Tasks
Create an updated pipeline that includes artifact creation and processing:
cat > enhanced-pipeline-with-workspace.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: enhanced-build-pipeline
spec:
  description: Enhanced pipeline demonstrating comprehensive workspace usage
  params:
    - name: git-url
      type: string
      description: Git repository URL
      default: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      type: string
      description: Git revision to checkout
      default: main
    - name: app-name
      type: string
      description: Application name
      default: nodejs-workspace-app
  workspaces:
    - name: shared-data
      description: Workspace for sharing data between all tasks
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
        - name: deleteExisting
          value: "true"
      workspaces:
        - name: output
          workspace: shared-data
    
    - name: list-source
      taskRef:
        name: list-directory
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-data
    
    - name: create-artifacts
      taskRef:
        name: create-build-artifacts
      runAfter:
        - list-source
      params:
        - name: app-name
          value: $(params.app-name)
      workspaces:
        - name: source
          workspace: shared-data
    
    - name: process-artifacts
      taskRef:
        name: process-build-artifacts
      runAfter:
        - create-artifacts
      workspaces:
        - name: source
          workspace: shared-data
    
    - name: final-verification
      taskRef:
        name: verify-workspace-data
      runAfter:
        - process-artifacts
      workspaces:
        - name: source
          workspace: shared-data
EOF
Subtask 4.2: Create Final Verification Task
Create a task to verify all workspace data is accessible:
cat > verify-workspace-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: verify-workspace-data
spec:
  description: Verify all workspace data is accessible and complete
  workspaces:
    - name: source
      description: Source workspace to verify
      mountPath: /workspace/source
  steps:
    - name: verify-data
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        set -e
        
        echo "=== Final Workspace Verification ==="
        
        # Check workspace mount
        echo "Workspace mounted at: /workspace/source"
        df -h /workspace/source
        
        # Verify source code
        echo "=== Source Code Verification ==="
        if [ -f "/workspace/source/package.json" ]; then
          echo "✓ Source code present"
          echo "Package name: $(grep '"name"' /workspace/source/package.json | cut -d'"' -f4)"
        else
          echo "✗ Source code missing"
        fi
        
        # Verify artifacts
        echo "=== Artifacts Verification ==="
        if [ -d "/workspace/source/artifacts" ]; then
          echo "✓ Artifacts directory present"
          ARTIFACT_COUNT=$(ls /workspace/source/artifacts/ | wc -l)
          echo "Artifact files: $ARTIFACT_COUNT"
          
          # Check specific artifacts
          for artifact in build-info.json build-report.txt version.txt processing-summary.txt; do
            if [ -f "/workspace/source/artifacts/$artifact" ]; then
              echo "✓ $artifact present"
            else
              echo "✗ $artifact missing"
            fi
          done
        else
          echo "✗ Artifacts directory missing"
        fi
        
        # Generate final report
        cat > /workspace/source/final-report.txt << EOF
        Final Pipeline Report
        =====================
        Execution Time: $(date)
        Workspace Size: $(du -sh /workspace/source | cut -f1)
        Total Files: $(find /workspace/source -type f | wc -l)
        Source Files: $(find /workspace/source -name "*.js" -o -name "*.json" | wc -l)
        Artifact Files: $(find /workspace/source/artifacts -type f 2>/dev/null | wc -l)
        
        Verification Status: COMPLETE
        EOF
        
        echo "=== Final Report ==="
        cat /workspace/source/final-report.txt
        
        echo "=== Workspace Summary ==="
        echo "Total workspace usage:"
        du -sh /workspace/source
        echo ""
        echo "Directory structure:"
        find /workspace/source -type d | sort
EOF
Apply the verification task:
oc apply -f verify-workspace-task.yaml
Apply the enhanced pipeline:
oc apply -f enhanced-pipeline-with-workspace.yaml
Subtask 4.3: Execute Pipeline with Workspace
Create a PipelineRun to test workspace sharing:
cat > pipelinerun-with-workspace.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: workspace-test-run-$(date +%s)
spec:
  pipelineRef:
    name: enhanced-build-pipeline
  params:
    - name: git-url
      value: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      value: main
    - name: app-name
      value: nodejs-workspace-demo
  workspaces:
    - name: shared-data
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
EOF
Execute the pipeline:
oc apply -f pipelinerun-with-workspace.yaml
Monitor the pipeline execution:
# Get the latest PipelineRun
PIPELINERUN_NAME=$(oc get pipelinerun --sort-by=.metadata.creationTimestamp -o name | tail -1 | cut -d'/' -f2)
echo "Monitoring PipelineRun: $PIPELINERUN_NAME"

# Watch the pipeline progress
tkn pipelinerun logs $PIPELINERUN_NAME -f
Subtask 4.4: Verify Workspace Data Persistence
Check the PipelineRun status:
oc get pipelinerun $PIPELINERUN_NAME -o yaml
Verify workspace data by creating a debug pod:
cat > debug-workspace-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: workspace-debug-pod
spec:
  containers:
  - name: debug
    image: registry.redhat.io/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    volumeMounts:
    - name: workspace-volume
      mountPath: /debug-workspace
  volumes:
  - name: workspace-volume
    persistentVolumeClaim:
      claimName: pipeline-workspace-pvc
  restartPolicy: Never
EOF
Apply and access the debug pod:
oc apply -f debug-workspace-pod.yaml

# Wait for pod to be ready
oc wait --for=condition=Ready pod/workspace-debug-pod --timeout=60s

# Explore workspace contents
oc exec -it workspace-debug-pod -- bash -c "
echo '=== Workspace Contents After Pipeline ==='
ls -la /debug-workspace/
echo ''
echo '=== Artifacts Directory ==='
ls -la /debug-workspace/artifacts/ 2>/dev/null || echo 'No artifacts directory'
echo ''
echo '=== Final Report ==='
cat /debug-workspace/final-report.txt 2>/dev/null || echo 'No final report'
"
Task 5: Advanced Workspace Scenarios and Troubleshooting
Subtask 5.1: Test Multiple Workspace Types
Create a pipeline with multiple workspace types:
cat > multi-workspace-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: multi-workspace-demo
spec:
  description: Pipeline demonstrating multiple workspace types
  workspaces:
    - name: source-data
      description: Main source code workspace (PVC)
    - name: temp-data
      description: Temporary data workspace (emptyDir)
    - name: config-data
      description: Configuration data workspace (ConfigMap)
      optional: true
  tasks:
    - name: setup-workspaces
      taskRef:
        name: workspace-setup-task
      workspaces:
        - name: source
          workspace: source-data
        - name: temp
          workspace: temp-data
        - name: config
          workspace: config-data
EOF
Create the workspace setup task:
cat > workspace-setup-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: workspace-setup-task
spec:
  description: Demonstrate different workspace types
  workspaces:
    - name: source
      description: Persistent source workspace
      mountPath: /workspace/source
    - name: temp
      description: Temporary workspace
      mountPath: /workspace/temp
    - name: config
      description: Configuration workspace
      mountPath: /workspace/config
      optional: true
  steps:
    - name: explore-workspaces
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        
        echo "=== Workspace Types Demonstration ==="
        
        # Check source workspace (PVC)
        echo "=== Source Workspace (PVC) ==="
        echo "Mount point: /workspace/source"
        df -h /workspace/source
        echo "Writing to source workspace..."
        echo "Persistent data from $(date)" > /workspace/source/persistent-file.txt
        
        # Check temp workspace (emptyDir)
        echo "=== Temp Workspace (emptyDir) ==="
        echo "Mount point: /workspace/temp"
        df -h /workspace/temp
        echo "Writing to temp workspace..."
        echo "Temporary data from $(date)" > /workspace/temp/temp-file.txt
        
        # Check config workspace (ConfigMap) if available
        if [ -d "/workspace/config" ]; then
          echo "=== Config Workspace (ConfigMap) ==="
          echo "Mount point: /workspace/config"
          ls -la /workspace/config/
          echo "Config contents:"
          find /workspace/config -type f -exec echo "File: {}" \; -exec cat {} \; 2>/dev/null || echo "No config files found"
        else
          echo "=== Config Workspace Not Available ==="
        fi
        
        echo "=== Workspace Summary ==="
        echo "Source workspace files: $(find /workspace/source -type f 2>/dev/null | wc -l)"
        echo "Temp workspace files: $(find /workspace/temp -type f 2>/dev/null | wc -l)"
        echo "Config workspace files: $(find /workspace/config -type f 2>/dev/null | wc -l)"
EOF
Subtask 5.2: Create ConfigMap for Configuration Workspace
Create a ConfigMap to use as a workspace:
cat > pipeline-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-config
data:
  app.properties: |
    app.name=nodejs-workspace-demo
    app.version=1.0.0
    build.environment=development
    logging.level=info
  build.yaml: |
    build:
      compiler: node
      version: "16"
      optimization: true
      tests: enabled
EOF
Apply the ConfigMap:
oc apply -f pipeline-config.yaml
oc apply -f workspace-setup-task.yaml
oc apply -f multi-workspace-pipeline.yaml
Subtask 5.3: Test Multi-Workspace Pipeline
Create a PipelineRun with multiple workspaces:
cat > multi-workspace-run.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: multi-workspace-test-$(date +%s)
spec:
  pipelineRef:
    name: multi-workspace-demo
  workspaces:
    - name: source-data
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
    - name: temp-data
      emptyDir: {}
    - name: config-data
      configMap:
        name: pipeline-config
EOF
Execute and monitor:
oc apply -f multi-workspace-run.yaml

# Get the latest run
MULTI_RUN_NAME=$(oc get pipelinerun --sort-by=.metadata.creationTimestamp -o name | tail -1 | cut -d'/' -f2)
echo "Monitoring Multi-Workspace PipelineRun: $MULTI_RUN_NAME"

tkn pipelinerun logs $MULTI_RUN_NAME -f
Subtask 5.4: Troubleshooting Common Workspace Issues
Create a troubleshooting guide script:
cat > troubleshoot-workspaces.sh << 'EOF'
#!/bin/bash

echo "=== OpenShift Pipeline Workspace Troubleshooting ==="

# Check PVC status
echo "=== PVC Status ==="
oc get pvc
echo ""

# Check storage class
echo "=== Storage Classes ==="
oc get storageclass
echo ""

# Check recent PipelineRuns
echo "=== Recent PipelineRuns ==="
oc get pipelinerun --sort-by=.metadata.creationTimestamp | tail -5
echo ""

# Check for failed TaskRuns
echo "=== Failed TaskRuns ==="
oc get taskrun --field-selector=status.conditions[0].status=False
echo ""

# Check pod logs for workspace issues
echo "=== Checking for Workspace Mount Issues ==="
for pod in $(oc get pods -l tekton.dev/task --no-headers | grep -E "(Error|Failed|Pending)" | awk '{print $1}'); do
  echo "Pod: $pod"
  oc describe pod $pod | grep -A 5 -B 5 -i "workspace\|volume\|mount"
  echo "---"
done

echo "=== Common Workspace Issues and Solutions ==="
cat << 'TROUBLESHOOT'

1. PVC Not Found:
   - Verify PVC exists: oc get pvc
   - Check PVC status: oc describe pvc <pvc-name>
   - Ensure correct PVC name in PipelineRun

2. Mount Permission Issues:
   - Check PVC access modes
   - Verify storage class supports required access mode
   - Check pod security context

3. Workspace Not Shared Between Tasks:
   - Verify workspace name consistency across tasks
   - Check workspace mount paths
   - Ensure tasks run in correct order with runAfter

4. ConfigMap/Secret Workspace Issues:
   - Verify ConfigMap/Secret exists
   - Check data keys in ConfigMap/Secret
   - Ensure proper RBAC permissions

5. Storage Full:
   - Check PVC size: oc describe pvc
   - Monitor disk usage in tasks
   - Consider increasing PVC size

TROUBLESHOOT
EOF

chmod +x troubleshoot-workspaces.sh
Run the troubleshooting script:
./troubleshoot-workspaces.sh
Conclusion
In this comprehensive lab, you have successfully:

• Mastered Workspace Concepts: Learned how workspaces enable data sharing and persistence across pipeline tasks, understanding the different types of workspaces (PVC, emptyDir, ConfigMap) and their appropriate use cases.

• Implemented Pipeline Workspaces: Created sophisticated pipeline definitions that utilize workspaces for sharing source code, build artifacts, and configuration data between multiple tasks.

• Built Artifact Management: Developed tasks that create, store, and process build artifacts using shared workspaces, demonstrating how to maintain data consistency across the entire pipeline execution.

• Validated Data Persistence: Tested workspace functionality thoroughly by verifying that data persists correctly between tasks and remains accessible after pipeline completion.

• Explored Advanced Scenarios: Implemented multi-workspace pipelines using different storage types simultaneously, showcasing the flexibility and power of workspace management in OpenShift Pipelines.

• Developed Troubleshooting Skills: Created diagnostic tools and learned common workspace-related issues and their solutions, preparing you for real-world pipeline management challenges.

Why This Matters: Workspaces are fundamental to building robust, production-ready CI/CD pipelines. They enable:

Efficient Resource Utilization: Share data without duplicating storage or network transfers
Pipeline Reliability: Ensure consistent data availability across all pipeline stages
Scalable Architecture: Support complex workflows with multiple interdependent tasks
Security and Isolation: Provide controlled access to sensitive data and configurations
The skills you've developed in this lab are essential for the Red Hat OpenShift Developer II certification and are directly applicable to enterprise-level application deployment scenarios. You can now design and implement sophisticated pipeline workflows that efficiently manage data sharing, artifact storage, and configuration management across complex CI/CD processes.

Next Steps: Consider exploring advanced topics such as workspace security policies, dynamic workspace provisioning, and integration with external storage systems to further enhance your OpenShift Pipelines expertise.
