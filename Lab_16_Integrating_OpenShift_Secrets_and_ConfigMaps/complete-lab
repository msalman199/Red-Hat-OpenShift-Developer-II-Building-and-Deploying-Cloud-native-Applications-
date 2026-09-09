Lab 16: Integrating OpenShift Secrets and ConfigMaps
Objectives
By the end of this lab, you will be able to:

• Create and manage OpenShift Secrets for sensitive data in CI/CD pipelines • Implement ConfigMaps for storing non-sensitive configuration data • Integrate Secrets and ConfigMaps into Tekton pipeline tasks • Understand security best practices for handling sensitive information in pipelines • Test and validate the proper usage of Secrets and ConfigMaps in pipeline execution • Troubleshoot common issues related to Secrets and ConfigMaps in OpenShift pipelines

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift concepts and CLI commands • Familiarity with Kubernetes resources (Pods, Services, Deployments) • Knowledge of Tekton pipelines and tasks from previous labs • Understanding of YAML syntax and structure • Basic Linux command-line experience • Completion of previous OpenShift pipeline labs (Labs 14-15 recommended)

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with admin access • Tekton Pipelines operator pre-installed • Command-line tools (oc, tkn) ready to use • Sample applications and configurations

Task 1: Create and Use OpenShift Secrets in the Pipeline
Subtask 1.1: Understanding Secrets in OpenShift
OpenShift Secrets are used to store sensitive information such as passwords, API keys, certificates, and tokens. They provide a secure way to manage confidential data without hardcoding it in your applications or pipeline definitions.

Subtask 1.2: Create Different Types of Secrets
Step 1: Access Your OpenShift Environment
# Verify your OpenShift connection
oc whoami

# Create a new project for this lab
oc new-project secrets-configmaps-lab

# Verify the project creation
oc project
Step 2: Create a Generic Secret for Database Credentials
# Create a secret containing database credentials
oc create secret generic db-credentials \
  --from-literal=username=mydbuser \
  --from-literal=password=mySecurePassword123 \
  --from-literal=host=database.example.com \
  --from-literal=port=5432

# Verify the secret creation
oc get secrets

# View the secret details (values will be base64 encoded)
oc describe secret db-credentials
Step 3: Create a Secret from a File
# Create a sample API key file
echo "sk-1234567890abcdef" > api-key.txt

# Create secret from file
oc create secret generic api-credentials \
  --from-file=api-key=api-key.txt

# Clean up the local file
rm api-key.txt

# Verify the secret
oc get secret api-credentials -o yaml
Step 4: Create a Docker Registry Secret
# Create a secret for Docker registry authentication
oc create secret docker-registry registry-secret \
  --docker-server=quay.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myuser@example.com

# Verify the docker registry secret
oc get secret registry-secret -o yaml
Subtask 1.3: Create a Pipeline Task that Uses Secrets
Step 5: Create a Task Definition with Secret Integration
Create a file named secret-task.yaml:

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: database-connection-task
  namespace: secrets-configmaps-lab
spec:
  params:
    - name: operation
      description: Database operation to perform
      default: "connect"
  steps:
    - name: connect-to-database
      image: postgres:13-alpine
      env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: host
        - name: DB_PORT
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: port
      script: |
        #!/bin/sh
        echo "Connecting to database..."
        echo "Host: $DB_HOST"
        echo "Port: $DB_PORT"
        echo "Username: $DB_USERNAME"
        echo "Password: [HIDDEN]"
        echo "Operation: $(params.operation)"
        
        # Simulate database connection
        echo "Database connection successful!"
        echo "Performing operation: $(params.operation)"
Apply the task:

# Apply the task definition
oc apply -f secret-task.yaml

# Verify the task creation
tkn task list
Step 6: Create a Task that Uses API Credentials
Create a file named api-task.yaml:

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: api-call-task
  namespace: secrets-configmaps-lab
spec:
  params:
    - name: endpoint
      description: API endpoint to call
      default: "https://api.example.com/data"
  steps:
    - name: make-api-call
      image: curlimages/curl:latest
      env:
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-credentials
              key: api-key
      script: |
        #!/bin/sh
        echo "Making API call to $(params.endpoint)"
        echo "Using API key: ${API_KEY:0:8}..."
        
        # Simulate API call
        curl -H "Authorization: Bearer $API_KEY" \
             -H "Content-Type: application/json" \
             "$(params.endpoint)" || echo "API call simulation completed"
Apply the API task:

# Apply the API task definition
oc apply -f api-task.yaml

# Verify both tasks are created
tkn task list
Task 2: Use ConfigMaps for Pipeline Configurations
Subtask 2.1: Understanding ConfigMaps
ConfigMaps store non-sensitive configuration data in key-value pairs. They're perfect for application settings, environment configurations, and other non-confidential information that your pipelines need.

Subtask 2.2: Create ConfigMaps for Pipeline Configuration
Step 7: Create a ConfigMap for Application Settings
# Create a ConfigMap with application configuration
oc create configmap app-config \
  --from-literal=app.name="MyApplication" \
  --from-literal=app.version="1.0.0" \
  --from-literal=app.environment="development" \
  --from-literal=log.level="debug" \
  --from-literal=feature.flags="feature1=true,feature2=false"

# Verify the ConfigMap creation
oc get configmaps

# View the ConfigMap contents
oc describe configmap app-config
Step 8: Create a ConfigMap from a Properties File
# Create a properties file
cat > application.properties << EOF
server.port=8080
server.host=0.0.0.0
database.pool.size=10
cache.enabled=true
monitoring.enabled=true
metrics.endpoint=/metrics
health.endpoint=/health
EOF

# Create ConfigMap from the properties file
oc create configmap app-properties \
  --from-file=application.properties

# Clean up the local file
rm application.properties

# Verify the ConfigMap
oc get configmap app-properties -o yaml
Step 9: Create a ConfigMap with Build Configuration
Create a file named build-config.yaml:

apiVersion: v1
kind: ConfigMap
metadata:
  name: build-config
  namespace: secrets-configmaps-lab
data:
  maven.goals: "clean package"
  maven.profiles: "production"
  docker.registry: "quay.io/myorg"
  docker.tag: "latest"
  build.timeout: "600"
  test.skip: "false"
  sonar.enabled: "true"
  sonar.host: "https://sonarqube.example.com"
Apply the build configuration:

# Apply the build ConfigMap
oc apply -f build-config.yaml

# List all ConfigMaps
oc get configmaps
Subtask 2.3: Create Pipeline Tasks Using ConfigMaps
Step 10: Create a Build Task Using ConfigMaps
Create a file named build-task.yaml:

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: maven-build-task
  namespace: secrets-configmaps-lab
spec:
  params:
    - name: source-url
      description: Git repository URL
      default: "https://github.com/example/sample-app.git"
  workspaces:
    - name: source
      description: Workspace for source code
  steps:
    - name: build-application
      image: maven:3.8-openjdk-11
      workingDir: $(workspaces.source.path)
      env:
        - name: MAVEN_GOALS
          valueFrom:
            configMapKeyRef:
              name: build-config
              key: maven.goals
        - name: MAVEN_PROFILES
          valueFrom:
            configMapKeyRef:
              name: build-config
              key: maven.profiles
        - name: BUILD_TIMEOUT
          valueFrom:
            configMapKeyRef:
              name: build-config
              key: build.timeout
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.name
        - name: APP_VERSION
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.version
      script: |
        #!/bin/bash
        echo "Building application: $APP_NAME"
        echo "Version: $APP_VERSION"
        echo "Maven goals: $MAVEN_GOALS"
        echo "Maven profiles: $MAVEN_PROFILES"
        echo "Build timeout: $BUILD_TIMEOUT seconds"
        
        # Simulate Maven build
        echo "Executing: mvn $MAVEN_GOALS -P$MAVEN_PROFILES"
        echo "Build completed successfully!"
Apply the build task:

# Apply the build task
oc apply -f build-task.yaml

# Verify the task creation
tkn task describe maven-build-task
Step 11: Create a Deployment Task Using Both Secrets and ConfigMaps
Create a file named deploy-task.yaml:

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-task
  namespace: secrets-configmaps-lab
spec:
  params:
    - name: image-name
      description: Container image to deploy
      default: "myapp:latest"
  steps:
    - name: deploy-application
      image: quay.io/openshift/origin-cli:latest
      env:
        # From ConfigMaps
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.name
        - name: APP_VERSION
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.version
        - name: ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: app.environment
        - name: DOCKER_REGISTRY
          valueFrom:
            configMapKeyRef:
              name: build-config
              key: docker.registry
        # From Secrets
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: host
      script: |
        #!/bin/bash
        echo "Deploying application: $APP_NAME"
        echo "Version: $APP_VERSION"
        echo "Environment: $ENVIRONMENT"
        echo "Registry: $DOCKER_REGISTRY"
        echo "Database Host: $DB_HOST"
        echo "Database User: $DB_USERNAME"
        
        # Create deployment YAML
        cat > deployment.yaml << EOF
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: $APP_NAME
          labels:
            app: $APP_NAME
            version: $APP_VERSION
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: $APP_NAME
          template:
            metadata:
              labels:
                app: $APP_NAME
                version: $APP_VERSION
            spec:
              containers:
              - name: $APP_NAME
                image: $(params.image-name)
                env:
                - name: DB_HOST
                  valueFrom:
                    secretKeyRef:
                      name: db-credentials
                      key: host
                - name: DB_USERNAME
                  valueFrom:
                    secretKeyRef:
                      name: db-credentials
                      key: username
                - name: DB_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: db-credentials
                      key: password
                envFrom:
                - configMapRef:
                    name: app-config
        EOF
        
        echo "Deployment configuration created:"
        cat deployment.yaml
        echo "Deployment simulation completed!"
Apply the deployment task:

# Apply the deployment task
oc apply -f deploy-task.yaml

# List all tasks
tkn task list
Task 3: Test the Use of Secrets and ConfigMaps in Pipeline Tasks
Subtask 3.1: Create a Complete Pipeline
Step 12: Create a Comprehensive Pipeline
Create a file named complete-pipeline.yaml:

apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: secrets-configmaps-pipeline
  namespace: secrets-configmaps-lab
spec:
  params:
    - name: git-url
      description: Git repository URL
      default: "https://github.com/example/sample-app.git"
    - name: image-name
      description: Container image name
      default: "myapp:latest"
  workspaces:
    - name: shared-workspace
      description: Shared workspace for pipeline tasks
  tasks:
    - name: database-setup
      taskRef:
        name: database-connection-task
      params:
        - name: operation
          value: "setup"
    
    - name: build-app
      taskRef:
        name: maven-build-task
      params:
        - name: source-url
          value: $(params.git-url)
      workspaces:
        - name: source
          workspace: shared-workspace
      runAfter:
        - database-setup
    
    - name: api-integration-test
      taskRef:
        name: api-call-task
      params:
        - name: endpoint
          value: "https://api.example.com/health"
      runAfter:
        - build-app
    
    - name: deploy-application
      taskRef:
        name: deploy-task
      params:
        - name: image-name
          value: $(params.image-name)
      runAfter:
        - api-integration-test
Apply the pipeline:

# Apply the complete pipeline
oc apply -f complete-pipeline.yaml

# Verify the pipeline creation
tkn pipeline list
Subtask 3.2: Create and Execute Pipeline Runs
Step 13: Create a Persistent Volume Claim for Workspace
# Create a PVC for the pipeline workspace
cat > workspace-pvc.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: secrets-configmaps-lab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Apply the PVC
oc apply -f workspace-pvc.yaml

# Verify PVC creation
oc get pvc
Step 14: Execute the Pipeline
# Start the pipeline run
tkn pipeline start secrets-configmaps-pipeline \
  --param git-url=https://github.com/example/sample-app.git \
  --param image-name=myapp:v1.0.0 \
  --workspace name=shared-workspace,claimName=pipeline-workspace-pvc \
  --showlog

# Alternative: Create a PipelineRun YAML file
cat > pipeline-run.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: secrets-configmaps-run-$(date +%s)
  namespace: secrets-configmaps-lab
spec:
  pipelineRef:
    name: secrets-configmaps-pipeline
  params:
    - name: git-url
      value: "https://github.com/example/sample-app.git"
    - name: image-name
      value: "myapp:v1.0.0"
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
EOF

# Apply the pipeline run
oc apply -f pipeline-run.yaml
Step 15: Monitor Pipeline Execution
# List pipeline runs
tkn pipelinerun list

# Get the latest pipeline run name
PIPELINE_RUN=$(tkn pipelinerun list -o name | head -1 | cut -d'/' -f2)

# Watch the pipeline run logs
tkn pipelinerun logs $PIPELINE_RUN -f

# Check pipeline run status
tkn pipelinerun describe $PIPELINE_RUN
Subtask 3.3: Test Individual Tasks
Step 16: Test Database Connection Task
# Create a TaskRun for database connection
cat > db-taskrun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-db-connection
  namespace: secrets-configmaps-lab
spec:
  taskRef:
    name: database-connection-task
  params:
    - name: operation
      value: "test-connection"
EOF

# Apply and monitor the task run
oc apply -f db-taskrun.yaml

# Watch the task run logs
tkn taskrun logs test-db-connection -f
Step 17: Test API Call Task
# Create a TaskRun for API call
cat > api-taskrun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-api-call
  namespace: secrets-configmaps-lab
spec:
  taskRef:
    name: api-call-task
  params:
    - name: endpoint
      value: "https://httpbin.org/get"
EOF

# Apply and monitor the task run
oc apply -f api-taskrun.yaml

# Watch the task run logs
tkn taskrun logs test-api-call -f
Subtask 3.4: Verify Secret and ConfigMap Integration
Step 18: Inspect Running Pods
# List pods created by pipeline runs
oc get pods

# Get a pod name from a recent task run
POD_NAME=$(oc get pods -l tekton.dev/taskRun --sort-by=.metadata.creationTimestamp | tail -1 | awk '{print $1}')

# Describe the pod to see environment variables
oc describe pod $POD_NAME

# Check if secrets and configmaps are properly mounted
oc get pod $POD_NAME -o yaml | grep -A 10 -B 5 "env:"
Step 19: Validate Secret Security
# Verify that secrets are base64 encoded
oc get secret db-credentials -o yaml

# Decode a secret value (for testing purposes only)
oc get secret db-credentials -o jsonpath='{.data.username}' | base64 -d
echo

# Check that secrets are not visible in plain text in task definitions
tkn task describe database-connection-task
Subtask 3.5: Update and Test Configuration Changes
Step 20: Update ConfigMap and Test
# Update the app-config ConfigMap
oc patch configmap app-config -p '{"data":{"app.version":"2.0.0","app.environment":"staging"}}'

# Verify the update
oc get configmap app-config -o yaml

# Run the build task again to see the updated configuration
cat > updated-build-taskrun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-updated-config
  namespace: secrets-configmaps-lab
spec:
  taskRef:
    name: maven-build-task
  params:
    - name: source-url
      value: "https://github.com/example/updated-app.git"
  workspaces:
    - name: source
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
EOF

# Apply and monitor
oc apply -f updated-build-taskrun.yaml
tkn taskrun logs test-updated-config -f
Step 21: Test Secret Rotation
# Update the database password
oc patch secret db-credentials -p '{"data":{"password":"'$(echo -n "newSecurePassword456" | base64)'"}}'

# Verify the secret update
oc get secret db-credentials -o jsonpath='{.data.password}' | base64 -d
echo

# Test with updated secret
cat > updated-db-taskrun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-updated-secret
  namespace: secrets-configmaps-lab
spec:
  taskRef:
    name: database-connection-task
  params:
    - name: operation
      value: "test-new-password"
EOF

# Apply and monitor
oc apply -f updated-db-taskrun.yaml
tkn taskrun logs test-updated-secret -f
Troubleshooting Common Issues
Issue 1: Secret Not Found Error
Problem: Task fails with "secret not found" error.

Solution:

# Check if secret exists in the correct namespace
oc get secrets -n secrets-configmaps-lab

# Verify secret name in task definition
oc get task database-connection-task -o yaml | grep -A 5 secretKeyRef
Issue 2: ConfigMap Key Not Found
Problem: Task fails with "key not found in ConfigMap" error.

Solution:

# Check ConfigMap contents
oc describe configmap app-config

# Verify key names match exactly
oc get configmap app-config -o yaml
Issue 3: Permission Denied
Problem: Pipeline cannot access secrets or configmaps.

Solution:

# Check service account permissions
oc get serviceaccount pipeline -o yaml

# Create role binding if needed
oc create rolebinding pipeline-secrets \
  --clusterrole=edit \
  --serviceaccount=secrets-configmaps-lab:pipeline
Issue 4: Base64 Encoding Issues
Problem: Secret values appear corrupted.

Solution:

# Recreate secret with proper encoding
oc delete secret db-credentials
oc create secret generic db-credentials \
  --from-literal=username=mydbuser \
  --from-literal=password=mySecurePassword123
Best Practices and Security Considerations
Security Best Practices
Never log secret values: Always mask or hide secret values in logs
Use least privilege: Grant minimal necessary permissions to service accounts
Rotate secrets regularly: Implement secret rotation policies
Separate environments: Use different secrets for dev, staging, and production
Audit access: Monitor who accesses secrets and when
ConfigMap Best Practices
Separate concerns: Use different ConfigMaps for different types of configuration
Version control: Keep ConfigMap definitions in version control
Environment-specific: Create environment-specific ConfigMaps
Size limits: Keep ConfigMaps under 1MB for performance
Naming conventions: Use consistent naming patterns
Conclusion
In this comprehensive lab, you have successfully:

• Created and managed OpenShift Secrets for storing sensitive information like database credentials, API keys, and registry authentication • Implemented ConfigMaps for non-sensitive configuration data including application settings, build parameters, and deployment configurations • Integrated Secrets and ConfigMaps into Tekton pipeline tasks, demonstrating how to securely pass configuration and credentials to your CI/CD processes • Built a complete pipeline that combines multiple tasks using both Secrets and ConfigMaps, showing real-world integration patterns • Tested and validated the proper functioning of Secrets and ConfigMaps in various scenarios • Learned troubleshooting techniques for common issues related to Secrets and ConfigMaps • Applied security best practices for handling sensitive data in OpenShift environments

This lab demonstrates the critical importance of proper configuration management and security practices in modern DevOps workflows. By separating sensitive data (Secrets) from configuration data (ConfigMaps), you ensure that your pipelines are both secure and maintainable. The skills you've developed here are essential for building production-ready CI/CD pipelines in OpenShift environments.

The integration of Secrets and ConfigMaps in your pipelines provides the foundation for secure, scalable, and maintainable DevOps practices that are crucial for enterprise-level applications and align with Red Hat OpenShift Developer certification objectives.
