Lab 14: Creating Multi-Stage Pipelines
Objectives
By the end of this lab, you will be able to:

• Understand the concept and benefits of multi-stage CI/CD pipelines • Split a monolithic pipeline into separate stages for building, testing, and deploying • Define and configure dependencies between pipeline stages • Implement stage-specific conditions and triggers • Test and validate multi-stage pipeline execution • Troubleshoot common issues in multi-stage pipeline configurations • Apply best practices for organizing complex CI/CD workflows

Prerequisites
Before starting this lab, you should have:

• Basic understanding of CI/CD concepts and workflows • Familiarity with YAML syntax and configuration files • Experience with Git version control system • Knowledge of containerization concepts (Docker) • Understanding of Kubernetes/OpenShift fundamentals • Completion of previous pipeline labs or equivalent experience • Basic command-line interface skills

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes: • OpenShift CLI (oc) pre-installed • Git client configured • Text editors (vim, nano) • Sample application code • Access to OpenShift cluster

Task 1: Split the Pipeline into Separate Stages
Subtask 1.1: Understanding Multi-Stage Pipeline Architecture
Multi-stage pipelines organize CI/CD workflows into distinct phases, each with specific responsibilities. This approach provides better control, visibility, and maintainability.

Key Benefits: • Separation of Concerns: Each stage has a specific purpose • Parallel Execution: Independent stages can run simultaneously • Conditional Logic: Stages can be triggered based on conditions • Better Debugging: Issues can be isolated to specific stages • Resource Optimization: Different stages can use different resources

Subtask 1.2: Create the Project Structure
Access your lab environment and open a terminal

Create a new project directory:

mkdir multi-stage-pipeline-lab
cd multi-stage-pipeline-lab
Initialize a Git repository:
git init
git config user.name "Lab Student"
git config user.email "student@example.com"
Create the basic project structure:
mkdir -p src tests deploy pipelines
touch src/app.py tests/test_app.py deploy/deployment.yaml
Subtask 1.3: Create Sample Application Code
Create a simple Python application:
cat > src/app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Multi-Stage Pipeline!',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'stage': os.getenv('DEPLOYMENT_STAGE', 'development')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF
Create application requirements:
cat > src/requirements.txt << 'EOF'
Flask==2.3.3
gunicorn==21.2.0
EOF
Create a Dockerfile:
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
EOF
Subtask 1.4: Create Test Files
Create unit tests:
cat > tests/test_app.py << 'EOF'
import unittest
import sys
import os

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_hello_endpoint(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('message', data)
        self.assertEqual(data['message'], 'Hello from Multi-Stage Pipeline!')

    def test_health_endpoint(self):
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'healthy')

if __name__ == '__main__':
    unittest.main()
EOF
Create test requirements:
cat > tests/requirements.txt << 'EOF'
pytest==7.4.2
pytest-cov==4.1.0
EOF
Subtask 1.5: Create Basic Pipeline Structure
Create the multi-stage pipeline definition:
cat > pipelines/multi-stage-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: multi-stage-app-pipeline
  namespace: default
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      description: Git revision to build
      default: main
    - name: image-name
      type: string
      description: Name of the image to build
    - name: deployment-namespace
      type: string
      description: Namespace for deployment
      default: default
  
  workspaces:
    - name: shared-workspace
      description: Shared workspace for pipeline tasks
    - name: docker-credentials
      description: Docker registry credentials
  
  tasks:
    # Build Stage
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
      workspaces:
        - name: output
          workspace: shared-workspace
    
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - fetch-source
      params:
        - name: IMAGE
          value: $(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
      workspaces:
        - name: source
          workspace: shared-workspace
    
    # Test Stage
    - name: run-tests
      taskRef:
        name: python-test-task
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-workspace
    
    # Deploy Stage
    - name: deploy-to-dev
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - build-image
        - run-tests
      params:
        - name: SCRIPT
          value: |
            oc apply -f deploy/deployment.yaml -n $(params.deployment-namespace)
            oc set image deployment/multi-stage-app app=$(params.image-name) -n $(params.deployment-namespace)
      workspaces:
        - name: manifest-dir
          workspace: shared-workspace
EOF
Task 2: Define Dependencies Between Stages
Subtask 2.1: Understanding Pipeline Dependencies
Pipeline dependencies control the execution order and conditions for stages. Tekton uses the runAfter field to define these dependencies.

Dependency Types: • Sequential: Stages run one after another • Parallel: Independent stages run simultaneously • Conditional: Stages run based on specific conditions • Fan-out/Fan-in: Multiple stages branch out and converge

Subtask 2.2: Create Custom Tasks for Each Stage
Create the Python test task:
cat > pipelines/python-test-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: python-test-task
  namespace: default
spec:
  description: Run Python unit tests
  workspaces:
    - name: source
      description: Source code workspace
  
  steps:
    - name: install-dependencies
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        echo "Installing test dependencies..."
        pip install -r tests/requirements.txt
        pip install -r src/requirements.txt
    
    - name: run-unit-tests
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        echo "Running unit tests..."
        python -m pytest tests/ -v --tb=short
        echo "Unit tests completed successfully!"
    
    - name: code-coverage
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        echo "Generating code coverage report..."
        python -m pytest tests/ --cov=src --cov-report=term-missing
        echo "Code coverage analysis completed!"
EOF
Create a security scanning task:
cat > pipelines/security-scan-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: security-scan-task
  namespace: default
spec:
  description: Perform security scanning on the application
  workspaces:
    - name: source
      description: Source code workspace
  
  params:
    - name: image-name
      type: string
      description: Container image to scan
  
  steps:
    - name: dependency-check
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        echo "Checking for security vulnerabilities in dependencies..."
        pip install safety
        pip install -r src/requirements.txt
        safety check --json || echo "Security scan completed with warnings"
    
    - name: code-analysis
      image: python:3.9-slim
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/bash
        set -e
        echo "Performing static code analysis..."
        pip install bandit
        bandit -r src/ -f json || echo "Static analysis completed"
        echo "Security scanning completed!"
EOF
Create an integration test task:
cat > pipelines/integration-test-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: integration-test-task
  namespace: default
spec:
  description: Run integration tests
  workspaces:
    - name: source
      description: Source code workspace
  
  params:
    - name: image-name
      type: string
      description: Container image to test
    - name: test-namespace
      type: string
      description: Namespace for testing
      default: default
  
  steps:
    - name: deploy-test-instance
      image: quay.io/openshift/origin-cli:latest
      script: |
        #!/bin/bash
        set -e
        echo "Deploying test instance..."
        
        cat << EOF | oc apply -f -
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: test-app
          namespace: $(params.test-namespace)
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: test-app
          template:
            metadata:
              labels:
                app: test-app
            spec:
              containers:
              - name: app
                image: $(params.image-name)
                ports:
                - containerPort: 5000
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: test-app-service
          namespace: $(params.test-namespace)
        spec:
          selector:
            app: test-app
          ports:
          - port: 5000
            targetPort: 5000
        EOF
        
        echo "Waiting for deployment to be ready..."
        oc wait --for=condition=available --timeout=300s deployment/test-app -n $(params.test-namespace)
    
    - name: run-integration-tests
      image: curlimages/curl:latest
      script: |
        #!/bin/sh
        set -e
        echo "Running integration tests..."
        
        # Wait a bit for the service to be fully ready
        sleep 10
        
        # Test the health endpoint
        echo "Testing health endpoint..."
        curl -f http://test-app-service.$(params.test-namespace).svc.cluster.local:5000/health
        
        # Test the main endpoint
        echo "Testing main endpoint..."
        curl -f http://test-app-service.$(params.test-namespace).svc.cluster.local:5000/
        
        echo "Integration tests passed!"
    
    - name: cleanup-test-instance
      image: quay.io/openshift/origin-cli:latest
      script: |
        #!/bin/bash
        set -e
        echo "Cleaning up test instance..."
        oc delete deployment test-app -n $(params.test-namespace) --ignore-not-found=true
        oc delete service test-app-service -n $(params.test-namespace) --ignore-not-found=true
        echo "Cleanup completed!"
EOF
Subtask 2.3: Create Enhanced Multi-Stage Pipeline
Create the comprehensive multi-stage pipeline:
cat > pipelines/enhanced-multi-stage-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: enhanced-multi-stage-pipeline
  namespace: default
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      description: Git revision to build
      default: main
    - name: image-name
      type: string
      description: Name of the image to build
    - name: deployment-namespace
      type: string
      description: Namespace for deployment
      default: default
    - name: enable-security-scan
      type: string
      description: Enable security scanning
      default: "true"
    - name: run-integration-tests
      type: string
      description: Run integration tests
      default: "true"
  
  workspaces:
    - name: shared-workspace
      description: Shared workspace for pipeline tasks
  
  tasks:
    # Stage 1: Source Code Management
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
      workspaces:
        - name: output
          workspace: shared-workspace
    
    # Stage 2: Build (runs after source fetch)
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - fetch-source
      params:
        - name: IMAGE
          value: $(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
      workspaces:
        - name: source
          workspace: shared-workspace
    
    # Stage 3: Testing (parallel execution)
    - name: unit-tests
      taskRef:
        name: python-test-task
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-workspace
    
    - name: security-scan
      taskRef:
        name: security-scan-task
      runAfter:
        - build-image
      when:
        - input: $(params.enable-security-scan)
          operator: in
          values: ["true"]
      params:
        - name: image-name
          value: $(params.image-name)
      workspaces:
        - name: source
          workspace: shared-workspace
    
    # Stage 4: Integration Testing (runs after build and unit tests)
    - name: integration-tests
      taskRef:
        name: integration-test-task
      runAfter:
        - build-image
        - unit-tests
      when:
        - input: $(params.run-integration-tests)
          operator: in
          values: ["true"]
      params:
        - name: image-name
          value: $(params.image-name)
        - name: test-namespace
          value: $(params.deployment-namespace)
      workspaces:
        - name: source
          workspace: shared-workspace
    
    # Stage 5: Deployment (runs after all tests pass)
    - name: deploy-to-staging
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - integration-tests
        - security-scan
      params:
        - name: SCRIPT
          value: |
            echo "Deploying to staging environment..."
            
            cat << EOF | oc apply -f -
            apiVersion: apps/v1
            kind: Deployment
            metadata:
              name: multi-stage-app
              namespace: $(params.deployment-namespace)
              labels:
                app: multi-stage-app
                stage: staging
            spec:
              replicas: 2
              selector:
                matchLabels:
                  app: multi-stage-app
              template:
                metadata:
                  labels:
                    app: multi-stage-app
                spec:
                  containers:
                  - name: app
                    image: $(params.image-name)
                    ports:
                    - containerPort: 5000
                    env:
                    - name: APP_VERSION
                      value: "$(params.git-revision)"
                    - name: DEPLOYMENT_STAGE
                      value: "staging"
                    resources:
                      requests:
                        memory: "128Mi"
                        cpu: "100m"
                      limits:
                        memory: "256Mi"
                        cpu: "200m"
            ---
            apiVersion: v1
            kind: Service
            metadata:
              name: multi-stage-app-service
              namespace: $(params.deployment-namespace)
            spec:
              selector:
                app: multi-stage-app
              ports:
              - port: 80
                targetPort: 5000
              type: ClusterIP
            EOF
            
            echo "Waiting for deployment to be ready..."
            oc wait --for=condition=available --timeout=300s deployment/multi-stage-app -n $(params.deployment-namespace)
            echo "Deployment to staging completed successfully!"
      workspaces:
        - name: manifest-dir
          workspace: shared-workspace
    
    # Stage 6: Production Deployment (manual approval simulation)
    - name: deploy-to-production
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - deploy-to-staging
      params:
        - name: SCRIPT
          value: |
            echo "Production deployment would require manual approval..."
            echo "In a real scenario, this would be triggered by a separate pipeline or manual process"
            echo "Staging deployment is ready for promotion to production"
      workspaces:
        - name: manifest-dir
          workspace: shared-workspace
EOF
Task 3: Test the Execution of Multi-Stage Pipeline
Subtask 3.1: Prepare the OpenShift Environment
Login to OpenShift cluster:
# Use the provided cluster credentials
oc login --server=https://your-cluster-api:6443 --token=your-token
Create a new project for the lab:
oc new-project multi-stage-pipeline-lab
oc project multi-stage-pipeline-lab
Verify Tekton is installed:
oc get pods -n openshift-pipelines
Subtask 3.2: Deploy Pipeline Resources
Apply all task definitions:
oc apply -f pipelines/python-test-task.yaml
oc apply -f pipelines/security-scan-task.yaml
oc apply -f pipelines/integration-test-task.yaml
Apply the pipeline definition:
oc apply -f pipelines/enhanced-multi-stage-pipeline.yaml
Verify resources are created:
oc get tasks
oc get pipelines
Subtask 3.3: Create Pipeline Workspace and Credentials
Create a persistent volume claim for the workspace:
cat > pipelines/workspace-pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: multi-stage-pipeline-lab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

oc apply -f pipelines/workspace-pvc.yaml
Create a service account with necessary permissions:
cat > pipelines/pipeline-sa.yaml << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline-service-account
  namespace: multi-stage-pipeline-lab
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pipeline-service-account-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- kind: ServiceAccount
  name: pipeline-service-account
  namespace: multi-stage-pipeline-lab
EOF

oc apply -f pipelines/pipeline-sa.yaml
Subtask 3.4: Commit Code to Git Repository
Add all files to Git:
git add .
git commit -m "Initial commit: Multi-stage pipeline implementation"
Create a simple Git server (for lab purposes):
# Create a bare repository
git clone --bare . /tmp/multi-stage-app.git

# Start a simple HTTP server (in a separate terminal)
cd /tmp
python3 -m http.server 8080 &
Subtask 3.5: Execute the Multi-Stage Pipeline
Create a PipelineRun to execute the pipeline:
cat > pipelines/pipeline-run.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: multi-stage-pipeline-run-$(date +%s)
  namespace: multi-stage-pipeline-lab
spec:
  pipelineRef:
    name: enhanced-multi-stage-pipeline
  
  params:
    - name: git-url
      value: "file:///tmp/multi-stage-app.git"
    - name: git-revision
      value: "main"
    - name: image-name
      value: "image-registry.openshift-image-registry.svc:5000/multi-stage-pipeline-lab/multi-stage-app:latest"
    - name: deployment-namespace
      value: "multi-stage-pipeline-lab"
    - name: enable-security-scan
      value: "true"
    - name: run-integration-tests
      value: "true"
  
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
  
  serviceAccountName: pipeline-service-account
EOF

# Apply the PipelineRun
oc apply -f pipelines/pipeline-run.yaml
Monitor the pipeline execution:
# Watch the pipeline run
oc get pipelineruns -w

# Get detailed status
PIPELINE_RUN=$(oc get pipelineruns --sort-by=.metadata.creationTimestamp -o name | tail -1)
oc describe $PIPELINE_RUN
View logs from specific tasks:
# View logs from the unit tests task
oc logs -f $PIPELINE_RUN-unit-tests-pod

# View logs from the build task
oc logs -f $PIPELINE_RUN-build-image-pod

# View logs from integration tests
oc logs -f $PIPELINE_RUN-integration-tests-pod
Subtask 3.6: Analyze Pipeline Execution Results
Check the pipeline execution graph:
# Get pipeline run details
oc get pipelinerun $PIPELINE_RUN -o yaml

# Check task execution order and timing
oc get taskruns --sort-by=.metadata.creationTimestamp
Verify stage dependencies:
# Check which tasks ran in parallel
oc get taskruns -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].type,START:.status.startTime,COMPLETION:.status.completionTime
Examine the deployed application:
# Check if the application was deployed
oc get deployments
oc get services
oc get pods

# Test the deployed application
oc port-forward service/multi-stage-app-service 8080:80 &
curl http://localhost:8080/
curl http://localhost:8080/health
Subtask 3.7: Test Pipeline with Different Scenarios
Test with security scan disabled:
cat > pipelines/pipeline-run-no-security.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: pipeline-run-no-security-$(date +%s)
  namespace: multi-stage-pipeline-lab
spec:
  pipelineRef:
    name: enhanced-multi-stage-pipeline
  
  params:
    - name: git-url
      value: "file:///tmp/multi-stage-app.git"
    - name: git-revision
      value: "main"
    - name: image-name
      value: "image-registry.openshift-image-registry.svc:5000/multi-stage-pipeline-lab/multi-stage-app:v2"
    - name: deployment-namespace
      value: "multi-stage-pipeline-lab"
    - name: enable-security-scan
      value: "false"
    - name: run-integration-tests
      value: "true"
  
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
  
  serviceAccountName: pipeline-service-account
EOF

oc apply -f pipelines/pipeline-run-no-security.yaml
Monitor the execution and verify security scan was skipped:
# Watch the new pipeline run
PIPELINE_RUN_2=$(oc get pipelineruns --sort-by=.metadata.creationTimestamp -o name | tail -1)
oc get taskruns | grep $(echo $PIPELINE_RUN_2 | cut -d'/' -f2)
Subtask 3.8: Create Pipeline Visualization
Create a simple pipeline status dashboard:
cat > pipelines/pipeline-status.sh << 'EOF'
#!/bin/bash

echo "=== Multi-Stage Pipeline Status Dashboard ==="
echo "=============================================="

# Get all pipeline runs
echo "Recent Pipeline Runs:"
oc get pipelineruns --sort-by=.metadata.creationTimestamp -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].type,REASON:.status.conditions[0].reason,START:.status.startTime,COMPLETION:.status.completionTime

echo ""
echo "Task Execution Summary:"
echo "======================"

# Get latest pipeline run
LATEST_RUN=$(oc get pipelineruns --sort-by=.metadata.creationTimestamp -o name | tail -1 | cut -d'/' -f2)

if [ ! -z "$LATEST_RUN" ]; then
    echo "Latest Pipeline Run: $LATEST_RUN"
    echo ""
    
    # Show task execution order and status
    oc get taskruns -l tekton.dev/pipelineRun=$LATEST_RUN --sort-by=.metadata.creationTimestamp -o custom-columns=TASK:.metadata.labels.tekton\.dev/pipelineTask,STATUS:.status.conditions[0].type,DURATION:.status.completionTime
    
    echo ""
    echo "Pipeline Execution Graph:"
    echo "========================"
    echo "fetch-source → build-image → security-scan"
    echo "fetch-source → unit-tests ↘"
    echo "                           → integration-tests → deploy-to-staging → deploy-to-production"
    echo "build-image → integration-tests ↗"
fi
EOF

chmod +x pipelines/pipeline-status.sh
./pipelines/pipeline-status.sh
Troubleshooting Common Issues
Issue 1: Pipeline Tasks Failing
Problem: Tasks are failing with permission errors

Solution:

# Check service account permissions
oc describe sa pipeline-service-account

# Add additional permissions if needed
oc adm policy add-scc-to-user privileged -z pipeline-service-account
Issue 2: Workspace Issues
Problem: Tasks cannot access the shared workspace

Solution:

# Check PVC status
oc get pvc pipeline-workspace-pvc

# Verify workspace mounting
oc describe taskrun <failing-taskrun-name>
Issue 3: Image Build Failures
Problem: Buildah task fails to build the image

Solution:

# Check if the internal registry is accessible
oc get route -n openshift-image-registry

# Verify buildah cluster task exists
oc get clustertask buildah
Issue 4: Integration Tests Timeout
Problem: Integration tests fail due to timeout

Solution:

# Increase timeout in the task definition
# Check if the test application is actually running
oc get pods -l app=test-app

# Check service connectivity
oc get svc test-app-service
Best Practices for Multi-Stage Pipelines
1. Stage Organization
• Keep stages focused: Each stage should have a single responsibility • Use meaningful names: Stage names should clearly indicate their purpose • Group related tasks: Combine closely related tasks into the same stage

2. Dependency Management
• Minimize dependencies: Only add dependencies when necessary • Use parallel execution: Run independent tasks in parallel to save time • Implement proper error handling: Ensure failures in one stage don't leave the system in an inconsistent state

3. Resource Management
• Use appropriate resource limits: Set CPU and memory limits for tasks • Share workspaces efficiently: Use shared workspaces to pass artifacts between stages • Clean up resources: Implement cleanup tasks to remove temporary resources

4. Security Considerations
• Implement security scanning: Include security checks in your pipeline • Use least privilege: Grant minimal necessary permissions to service accounts • Secure sensitive data: Use secrets for credentials and sensitive configuration

Conclusion
In this lab, you have successfully:

• Created a comprehensive multi-stage pipeline that separates concerns into distinct stages for building, testing, and deploying applications • Implemented stage dependencies using Tekton's runAfter mechanism to control execution order and enable parallel processing where appropriate • Tested pipeline execution with different configurations and scenarios to validate the multi-stage approach • Learned troubleshooting techniques for common pipeline issues and implemented best practices for production use

Why This Matters:

Multi-stage pipelines are essential for modern DevOps practices because they: • Improve reliability by catching issues early in the development process • Enable faster feedback through parallel execution of independent tasks • Provide better visibility into the CI/CD process with clear stage boundaries • Support complex workflows that can adapt to different deployment scenarios • Facilitate team collaboration by allowing different teams to own different stages

The skills you've developed in this lab are directly applicable to real-world scenarios where you need to implement robust, scalable CI/CD pipelines for cloud-native applications. These multi-stage pipelines form the foundation for advanced DevOps practices like GitOps, progressive delivery, and automated quality gates.

Next Steps: • Explore advanced pipeline features like conditional execution and manual approvals • Implement pipeline templates for reusability across multiple projects • Integrate with external tools like SonarQube, Artif
