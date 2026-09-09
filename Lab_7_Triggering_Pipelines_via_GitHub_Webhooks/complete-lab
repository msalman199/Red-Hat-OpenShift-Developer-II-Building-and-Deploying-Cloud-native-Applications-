Lab 7: Triggering Pipelines via GitHub Webhooks
Objectives
By the end of this lab, you will be able to:

• Configure GitHub webhooks to automatically trigger OpenShift pipelines • Modify Tekton pipelines to pull source code from GitHub repositories • Implement continuous integration workflows using webhook-triggered automation • Troubleshoot webhook connectivity and pipeline execution issues • Understand the integration between GitHub events and OpenShift CI/CD processes

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Git and GitHub operations • Familiarity with OpenShift CLI (oc) commands • Knowledge of Tekton pipelines and pipeline resources • Experience with YAML configuration files • Understanding of containerization concepts • Access to a GitHub account with repository creation permissions

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with Tekton Pipelines operator installed • Pre-configured CLI tools (oc, tkn, git) • Sample application code and pipeline templates • Network connectivity to GitHub for webhook configuration

Task 1: Set up GitHub Webhook to Trigger Pipeline
Subtask 1.1: Create a GitHub Repository
First, we'll create a new GitHub repository that will serve as our source code location.

Log into GitHub and navigate to your dashboard

Create a new repository:

Click the New button or go to https://github.com/new
Repository name: webhook-pipeline-demo
Description: Demo repository for OpenShift webhook pipeline integration
Set to Public (required for webhook functionality)
Initialize with README: Yes
Click Create repository
Clone the repository locally:

git clone https://github.com/YOUR_USERNAME/webhook-pipeline-demo.git
cd webhook-pipeline-demo
Subtask 1.2: Create Sample Application Code
Let's add a simple Node.js application to our repository.

Create the application files:
# Create package.json
cat > package.json << 'EOF'
{
  "name": "webhook-demo-app",
  "version": "1.0.0",
  "description": "Simple Node.js app for webhook pipeline demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo \"No tests specified\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Webhook Pipeline Demo!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 8080

USER node

CMD ["npm", "start"]
EOF
Commit and push the initial code:
git add .
git commit -m "Initial commit: Add Node.js application"
git push origin main
Subtask 1.3: Create OpenShift Pipeline Resources
Now we'll create the necessary OpenShift resources for our pipeline.

Log into your OpenShift cluster:
oc login --server=YOUR_OPENSHIFT_SERVER --token=YOUR_TOKEN
Create a new project:
oc new-project webhook-pipeline-lab
Create the pipeline definition:
cat > pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: webhook-demo-pipeline
  namespace: webhook-pipeline-lab
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      description: Git revision to checkout
      default: main
    - name: image-name
      type: string
      description: Name of the image to build
  workspaces:
    - name: shared-workspace
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      workspaces:
        - name: output
          workspace: shared-workspace
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
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
    - name: deploy-app
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - build-image
      params:
        - name: SCRIPT
          value: |
            oc new-app $(params.image-name) --name=webhook-demo-app || true
            oc expose svc/webhook-demo-app || true
            oc rollout latest dc/webhook-demo-app || true
EOF

oc apply -f pipeline.yaml
Create a PersistentVolumeClaim for the workspace:
cat > pvc.yaml << 'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-workspace-pvc
  namespace: webhook-pipeline-lab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

oc apply -f pvc.yaml
Subtask 1.4: Create EventListener and TriggerBinding
The EventListener will receive webhook events from GitHub and trigger our pipeline.

Create the TriggerBinding:
cat > triggerbinding.yaml << 'EOF'
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
  namespace: webhook-pipeline-lab
spec:
  params:
    - name: git-url
      value: $(body.repository.clone_url)
    - name: git-revision
      value: $(body.head_commit.id)
    - name: image-name
      value: image-registry.openshift-image-registry.svc:5000/webhook-pipeline-lab/webhook-demo-app:$(body.head_commit.id)
EOF

oc apply -f triggerbinding.yaml
Create the TriggerTemplate:
cat > triggertemplate.yaml << 'EOF'
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-push-template
  namespace: webhook-pipeline-lab
spec:
  params:
    - name: git-url
      description: The git repository url
    - name: git-revision
      description: The git revision
    - name: image-name
      description: The image name
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: webhook-demo-pipeline-run-
        namespace: webhook-pipeline-lab
      spec:
        pipelineRef:
          name: webhook-demo-pipeline
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
          - name: image-name
            value: $(tt.params.image-name)
        workspaces:
          - name: shared-workspace
            persistentVolumeClaim:
              claimName: pipeline-workspace-pvc
EOF

oc apply -f triggertemplate.yaml
Create the EventListener:
cat > eventlistener.yaml << 'EOF'
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-webhook-listener
  namespace: webhook-pipeline-lab
spec:
  serviceAccountName: pipeline
  triggers:
    - name: github-push-trigger
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
      interceptors:
        - name: github
          params:
            - name: eventTypes
              value: ["push"]
EOF

oc apply -f eventlistener.yaml
Expose the EventListener service:
oc expose svc el-github-webhook-listener
Get the webhook URL:
WEBHOOK_URL=$(oc get route el-github-webhook-listener -o jsonpath='{.spec.host}')
echo "Webhook URL: http://$WEBHOOK_URL"
Subtask 1.5: Configure GitHub Webhook
Now we'll configure GitHub to send webhook events to our EventListener.

Navigate to your GitHub repository (webhook-pipeline-demo)

Go to Settings > Webhooks:

Click Add webhook
Configure the webhook:

Payload URL: http://YOUR_WEBHOOK_URL (use the URL from previous step)
Content type: application/json
Secret: Leave empty for this demo
Which events: Select Just the push event
Active: Ensure this is checked
Click Add webhook
Verify webhook creation:

You should see a green checkmark next to your webhook
GitHub will send a test ping to verify connectivity
Task 2: Modify Pipeline to Pull Code from GitHub Repository
Subtask 2.1: Update Pipeline with GitHub Integration
Our pipeline is already configured to pull from GitHub, but let's enhance it with better error handling and logging.

Create an enhanced pipeline version:
cat > enhanced-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: enhanced-webhook-pipeline
  namespace: webhook-pipeline-lab
spec:
  params:
    - name: git-url
      type: string
      description: Git repository URL
    - name: git-revision
      type: string
      description: Git revision to checkout
      default: main
    - name: image-name
      type: string
      description: Name of the image to build
  workspaces:
    - name: shared-workspace
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
        kind: ClusterTask
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
        - name: verbose
          value: "true"
    - name: list-source
      runAfter:
        - fetch-source
      taskSpec:
        workspaces:
          - name: source
        steps:
          - name: list-files
            image: registry.redhat.io/ubi8/ubi:latest
            workingDir: $(workspaces.source.path)
            script: |
              #!/bin/bash
              echo "=== Repository Contents ==="
              ls -la
              echo "=== Package.json Contents ==="
              cat package.json || echo "No package.json found"
              echo "=== Git Information ==="
              git log --oneline -5 || echo "No git history available"
      workspaces:
        - name: source
          workspace: shared-workspace
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - list-source
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
        - name: CONTEXT
          value: .
    - name: deploy-app
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - build-image
      params:
        - name: SCRIPT
          value: |
            echo "Deploying application..."
            oc new-app $(params.image-name) --name=webhook-demo-app || echo "App already exists"
            oc expose svc/webhook-demo-app || echo "Route already exists"
            oc set image dc/webhook-demo-app webhook-demo-app=$(params.image-name) || true
            oc rollout latest dc/webhook-demo-app || true
            echo "Deployment completed"
EOF

oc apply -f enhanced-pipeline.yaml
Update the TriggerTemplate to use the enhanced pipeline:
cat > updated-triggertemplate.yaml << 'EOF'
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-push-template
  namespace: webhook-pipeline-lab
spec:
  params:
    - name: git-url
      description: The git repository url
    - name: git-revision
      description: The git revision
    - name: image-name
      description: The image name
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: enhanced-webhook-pipeline-run-
        namespace: webhook-pipeline-lab
        labels:
          app: webhook-demo
          trigger: github-webhook
      spec:
        pipelineRef:
          name: enhanced-webhook-pipeline
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
          - name: image-name
            value: $(tt.params.image-name)
        workspaces:
          - name: shared-workspace
            persistentVolumeClaim:
              claimName: pipeline-workspace-pvc
EOF

oc apply -f updated-triggertemplate.yaml
Subtask 2.2: Test Manual Pipeline Execution
Before testing the webhook, let's manually trigger the pipeline to ensure it works correctly.

Create a manual PipelineRun:
cat > manual-pipelinerun.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: manual-test-run
  namespace: webhook-pipeline-lab
spec:
  pipelineRef:
    name: enhanced-webhook-pipeline
  params:
    - name: git-url
      value: https://github.com/YOUR_USERNAME/webhook-pipeline-demo.git
    - name: git-revision
      value: main
    - name: image-name
      value: image-registry.openshift-image-registry.svc:5000/webhook-pipeline-lab/webhook-demo-app:manual-test
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
EOF

# Replace YOUR_USERNAME with your actual GitHub username
sed -i 's/YOUR_USERNAME/your-actual-username/g' manual-pipelinerun.yaml

oc apply -f manual-pipelinerun.yaml
Monitor the pipeline execution:
# Watch the pipeline run
tkn pipelinerun logs manual-test-run -f

# Check pipeline run status
tkn pipelinerun list

# Get detailed information
oc describe pipelinerun manual-test-run
Task 3: Push a Change to GitHub and Observe Automatic Trigger
Subtask 3.1: Make Changes to the Application
Now we'll make changes to our application and push them to GitHub to trigger the webhook.

Navigate to your local repository:
cd webhook-pipeline-demo
Update the application with new features:
# Update server.js with new endpoint
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Webhook Pipeline Demo - Updated!',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    features: ['webhooks', 'auto-deployment', 'continuous-integration']
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.get('/version', (req, res) => {
  res.json({
    version: '2.0.0',
    buildTime: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log('New features added: /version endpoint');
});
EOF

# Update package.json version
sed -i 's/"version": "1.0.0"/"version": "2.0.0"/g' package.json
Add a simple test file:
cat > test.js << 'EOF'
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 8080,
  path: '/',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log(`statusCode: ${res.statusCode}`);
  
  res.on('data', (d) => {
    const data = JSON.parse(d);
    console.log('Response:', data);
    
    if (data.version === '2.0.0') {
      console.log('✅ Test passed: Version updated correctly');
    } else {
      console.log('❌ Test failed: Version not updated');
    }
  });
});

req.on('error', (error) => {
  console.error('Test failed:', error);
});

req.end();
EOF
Subtask 3.2: Commit and Push Changes
Commit the changes:
git add .
git commit -m "feat: Add version endpoint and update to v2.0.0

- Added /version endpoint with build information
- Updated main endpoint with new features list
- Enhanced health endpoint with system metrics
- Added basic test script"
Push to GitHub:
git push origin main
Subtask 3.3: Monitor Webhook Trigger and Pipeline Execution
Check GitHub webhook delivery:

Go to your GitHub repository
Navigate to Settings > Webhooks
Click on your webhook
Check the Recent Deliveries section
You should see a successful delivery with a green checkmark
Monitor the triggered pipeline in OpenShift:

# List recent pipeline runs
tkn pipelinerun list

# Watch the latest pipeline run
LATEST_RUN=$(tkn pipelinerun list -o name | head -1 | cut -d'/' -f2)
echo "Watching pipeline run: $LATEST_RUN"
tkn pipelinerun logs $LATEST_RUN -f
Check the EventListener logs:
# Get EventListener pod
EL_POD=$(oc get pods -l eventlistener=github-webhook-listener -o name)
echo "EventListener pod: $EL_POD"

# Check logs
oc logs $EL_POD
Verify the application deployment:
# Check if the application is running
oc get pods -l app=webhook-demo-app

# Get the application route
APP_ROUTE=$(oc get route webhook-demo-app -o jsonpath='{.spec.host}')
echo "Application URL: http://$APP_ROUTE"

# Test the updated application
curl http://$APP_ROUTE/
curl http://$APP_ROUTE/version
curl http://$APP_ROUTE/health
Subtask 3.4: Verify Continuous Integration Workflow
Let's make another change to fully demonstrate the CI/CD workflow.

Create a README update:
cat > README.md << 'EOF'
# Webhook Pipeline Demo

This is a demonstration application for OpenShift webhook-triggered pipelines.

## Features

- **Automatic Deployment**: Code changes trigger automatic builds and deployments
- **GitHub Integration**: Webhooks automatically trigger pipelines on push events
- **Health Monitoring**: Built-in health and version endpoints
- **Container Ready**: Dockerized application ready for OpenShift deployment

## Endpoints

- `/` - Main application endpoint with feature information
- `/health` - Health check endpoint with system metrics
- `/version` - Version information and build details

## Version History

- **v2.0.0**: Added version endpoint and enhanced features
- **v1.0.0**: Initial release with basic functionality

## CI/CD Pipeline

This application uses Tekton pipelines triggered by GitHub webhooks:

1. **Source Fetch**: Pulls latest code from GitHub
2. **Build**: Creates container image using Buildah
3. **Deploy**: Deploys to OpenShift and exposes service

## Testing

Run the test script to verify functionality:

```bash
node test.js
Development
To run locally:

npm install
npm start
The application will be available at http://localhost:8080 EOF


2. **Commit and push the documentation update**:

```bash
git add README.md
git commit -m "docs: Add comprehensive README with pipeline information"
git push origin main
Monitor the second webhook trigger:
# Wait a moment for the webhook to trigger
sleep 10

# Check for new pipeline run
tkn pipelinerun list

# Watch the latest run
LATEST_RUN=$(tkn pipelinerun list -o name | head -1 | cut -d'/' -f2)
tkn pipelinerun logs $LATEST_RUN -f
Troubleshooting Common Issues
Issue 1: Webhook Not Triggering Pipeline
Symptoms: GitHub shows webhook delivery but no pipeline runs are created.

Solutions:

# Check EventListener status
oc get eventlistener github-webhook-listener -o yaml

# Check EventListener pod logs
oc logs -l eventlistener=github-webhook-listener

# Verify TriggerBinding and TriggerTemplate
oc get triggerbinding,triggertemplate

# Check service account permissions
oc get serviceaccount pipeline -o yaml
Issue 2: Pipeline Fails During Git Clone
Symptoms: Pipeline fails at the fetch-source task.

Solutions:

# Check if repository URL is accessible
curl -I https://github.com/YOUR_USERNAME/webhook-pipeline-demo.git

# Verify git-clone ClusterTask exists
oc get clustertask git-clone

# Check workspace PVC
oc get pvc pipeline-workspace-pvc
Issue 3: Build Fails
Symptoms: buildah task fails during image build.

Solutions:

# Check Dockerfile syntax
docker build -t test-build .

# Verify buildah ClusterTask
oc get clustertask buildah

# Check build logs
tkn taskrun logs <taskrun-name> -s build-image
Issue 4: Deployment Issues
Symptoms: Application doesn't deploy or isn't accessible.

Solutions:

# Check deployment status
oc get dc webhook-demo-app

# Check pod status
oc get pods -l app=webhook-demo-app

# Check service and route
oc get svc,route webhook-demo-app

# Check application logs
oc logs -l app=webhook-demo-app
Verification and Testing
Final Verification Steps
Verify webhook configuration:
# Check webhook URL is accessible
WEBHOOK_URL=$(oc get route el-github-webhook-listener -o jsonpath='{.spec.host}')
curl -X POST http://$WEBHOOK_URL -H "Content-Type: application/json" -d '{"test": "ping"}'
Test complete workflow:
# Make a simple change
echo "# Last updated: $(date)" >> README.md
git add README.md
git commit -m "test: Verify webhook pipeline integration"
git push origin main

# Monitor the triggered pipeline
sleep 5
tkn pipelinerun list
Verify application functionality:
APP_ROUTE=$(oc get route webhook-demo-app -o jsonpath='{.spec.host}')
echo "Testing application at: http://$APP_ROUTE"

# Test all endpoints
curl -s http://$APP_ROUTE/ | jq .
curl -s http://$APP_ROUTE/health | jq .
curl -s http://$APP_ROUTE/version | jq .
Conclusion
Congratulations! You have successfully completed Lab 7: Triggering Pipelines via GitHub Webhooks.

What You Accomplished
In this lab, you have:

• Configured GitHub Webhooks: Set up automatic triggers that respond to code changes in your GitHub repository • Created Tekton Pipeline Integration: Built a complete CI/CD pipeline that automatically pulls code, builds container images, and deploys applications • Implemented Event-Driven Automation: Established a workflow where code commits automatically trigger build and deployment processes • Mastered OpenShift CI/CD: Gained hands-on experience with EventListeners, TriggerBindings, and TriggerTemplates • Verified End-to-End Workflow: Successfully tested the complete integration from code commit to application deployment

Why This Matters
The webhook-triggered pipeline integration you've implemented represents a fundamental DevOps practice that:

• Accelerates Development Cycles: Developers can see their changes deployed automatically without manual intervention • Reduces Human Error: Automated processes eliminate manual deployment mistakes and ensure consistency • Enables Continuous Integration: Every code change is automatically tested and deployed, catching issues early • Improves Team Productivity: Teams can focus on writing code rather than managing deployment processes • Supports Modern Development Practices: This foundation enables advanced practices like feature flags, canary deployments, and automated testing

Next Steps
To further enhance your webhook pipeline integration skills, consider:

• Adding automated testing stages to your pipeline • Implementing approval workflows for production deployments • Exploring advanced Tekton features like conditional tasks and parallel execution • Integrating security scanning and compliance checks • Setting up monitoring and alerting for pipeline failures

This lab has provided you with the essential skills needed for the Red Hat OpenShift Developer II certification and real-world DevOps implementations. The webhook-triggered pipeline pattern you've mastered is widely used in enterprise environments and forms the backbone of modern continuous integration and deployment strategies.
