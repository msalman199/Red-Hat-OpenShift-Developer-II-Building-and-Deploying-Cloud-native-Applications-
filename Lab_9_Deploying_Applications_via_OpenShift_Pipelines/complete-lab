Lab 9: Deploying Applications via OpenShift Pipelines
Objectives
By the end of this lab, you will be able to:

• Create and configure deployment tasks within OpenShift Pipelines • Modify existing pipelines to include application deployment to OpenShift clusters • Monitor deployment logs and troubleshoot deployment issues • Verify successful application deployment and validate running applications • Understand the integration between CI/CD pipelines and OpenShift deployment mechanisms • Implement best practices for automated application deployment using Tekton

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift concepts (pods, services, deployments) • Familiarity with Kubernetes YAML manifests • Knowledge of container images and registries • Previous experience with OpenShift Pipelines (Tekton) basics • Understanding of Git workflows and source code management • Basic command-line interface (CLI) skills

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift and all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install software.

Your lab environment includes: • OpenShift cluster with admin access • OpenShift CLI (oc) pre-installed • Tekton CLI (tkn) pre-installed • Git client configured • Sample application source code

Task 1: Create a Deployment Task in the Pipeline
Subtask 1.1: Access Your Lab Environment
Click Start Lab to access your cloud machine
Open a terminal window
Verify your OpenShift connection:
oc whoami
oc cluster-info
Check if you're in the correct project:
oc project
If not in a project, create one:

oc new-project pipeline-deployment-lab
Subtask 1.2: Examine the Existing Pipeline
List existing pipelines in your project:
tkn pipeline list
If no pipeline exists, create a basic pipeline structure. First, create a workspace for our pipeline:
cat << EOF | oc apply -f -
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
Create a basic pipeline with build tasks:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: app-deployment-pipeline
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
    - name: app-name
      type: string
      description: Name of the application
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
          value: \$(params.git-url)
        - name: revision
          value: \$(params.git-revision)
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
          value: \$(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
EOF
Subtask 1.3: Create a Custom Deployment Task
Create a custom task for deploying applications to OpenShift:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-to-openshift
spec:
  params:
    - name: app-name
      type: string
      description: Name of the application
    - name: image-name
      type: string
      description: Container image to deploy
    - name: namespace
      type: string
      description: Target namespace for deployment
      default: \$(context.pipelineRun.namespace)
  steps:
    - name: create-deployment
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        
        # Install OpenShift CLI
        curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar xz
        mv oc /usr/local/bin/
        
        # Create deployment manifest
        cat << DEPLOY_EOF > deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: \$(params.app-name)
          namespace: \$(params.namespace)
          labels:
            app: \$(params.app-name)
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: \$(params.app-name)
          template:
            metadata:
              labels:
                app: \$(params.app-name)
            spec:
              containers:
              - name: \$(params.app-name)
                image: \$(params.image-name)
                ports:
                - containerPort: 8080
                resources:
                  limits:
                    memory: "256Mi"
                    cpu: "200m"
                  requests:
                    memory: "128Mi"
                    cpu: "100m"
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: \$(params.app-name)-service
          namespace: \$(params.namespace)
          labels:
            app: \$(params.app-name)
        spec:
          selector:
            app: \$(params.app-name)
          ports:
          - port: 8080
            targetPort: 8080
          type: ClusterIP
        ---
        apiVersion: route.openshift.io/v1
        kind: Route
        metadata:
          name: \$(params.app-name)-route
          namespace: \$(params.namespace)
          labels:
            app: \$(params.app-name)
        spec:
          to:
            kind: Service
            name: \$(params.app-name)-service
          port:
            targetPort: 8080
        DEPLOY_EOF
        
        # Apply the deployment
        oc apply -f deployment.yaml
        
        # Wait for deployment to be ready
        oc rollout status deployment/\$(params.app-name) -n \$(params.namespace) --timeout=300s
        
        # Get route URL
        echo "Application deployed successfully!"
        echo "Route URL: http://\$(oc get route \$(params.app-name)-route -n \$(params.namespace) -o jsonpath='{.spec.host}')"
EOF
Verify the task was created:
tkn task list
Task 2: Modify the Pipeline to Deploy the Image to OpenShift
Subtask 2.1: Update the Pipeline with Deployment Task
Update the existing pipeline to include the deployment task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: app-deployment-pipeline
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
    - name: app-name
      type: string
      description: Name of the application
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
          value: \$(params.git-url)
        - name: revision
          value: \$(params.git-revision)
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
          value: \$(params.image-name)
        - name: DOCKERFILE
          value: ./Dockerfile
    - name: deploy-application
      taskRef:
        name: deploy-to-openshift
      runAfter:
        - build-image
      params:
        - name: app-name
          value: \$(params.app-name)
        - name: image-name
          value: \$(params.image-name)
        - name: namespace
          value: \$(context.pipelineRun.namespace)
EOF
Subtask 2.2: Create a Sample Application
Create a simple Node.js application for testing:
mkdir -p ~/sample-app
cd ~/sample-app
Create a simple application file:
cat << EOF > app.js
const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from OpenShift Pipeline Deployment!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(\`App listening at http://localhost:\${port}\`);
});
EOF
Create a package.json file:
cat << EOF > package.json
{
  "name": "sample-pipeline-app",
  "version": "1.0.0",
  "description": "Sample app for OpenShift Pipeline deployment",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
Create a Dockerfile:
cat << EOF > Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8080

CMD ["npm", "start"]
EOF
Initialize a Git repository and commit the code:
git init
git add .
git commit -m "Initial commit of sample application"
Subtask 2.3: Create a PipelineRun
Create a PipelineRun to execute the complete pipeline:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: app-deployment-run-\$(date +%s)
  generateName: app-deployment-run-
spec:
  pipelineRef:
    name: app-deployment-pipeline
  params:
    - name: git-url
      value: https://github.com/openshift/nodejs-ex.git
    - name: git-revision
      value: main
    - name: image-name
      value: image-registry.openshift-image-registry.svc:5000/\$(oc project -q)/sample-app:latest
    - name: app-name
      value: sample-app
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace-pvc
EOF
Task 3: Monitor Deployment Logs and Verify Successful Application Deployment
Subtask 3.1: Monitor Pipeline Execution
List running PipelineRuns:
tkn pipelinerun list
Get the name of the latest PipelineRun and monitor its progress:
PIPELINE_RUN=$(tkn pipelinerun list --limit 1 -o name | cut -d'/' -f2)
echo "Monitoring PipelineRun: $PIPELINE_RUN"
Watch the pipeline execution in real-time:
tkn pipelinerun logs $PIPELINE_RUN -f
Check the status of the pipeline run:
tkn pipelinerun describe $PIPELINE_RUN
Subtask 3.2: Monitor Individual Task Logs
List TaskRuns for the current PipelineRun:
tkn taskrun list --label tekton.dev/pipelineRun=$PIPELINE_RUN
Monitor the deployment task specifically:
DEPLOY_TASKRUN=$(tkn taskrun list --label tekton.dev/pipelineRun=$PIPELINE_RUN | grep deploy-application | awk '{print $1}')
tkn taskrun logs $DEPLOY_TASKRUN -f
Check the build task logs:
BUILD_TASKRUN=$(tkn taskrun list --label tekton.dev/pipelineRun=$PIPELINE_RUN | grep build-image | awk '{print $1}')
tkn taskrun logs $BUILD_TASKRUN
Subtask 3.3: Verify Application Deployment
Check if the deployment was created successfully:
oc get deployments
oc get pods -l app=sample-app
Verify the service was created:
oc get services
oc describe service sample-app-service
Check the route:
oc get routes
ROUTE_URL=$(oc get route sample-app-route -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_URL"
Test the application:
curl http://$ROUTE_URL
curl http://$ROUTE_URL/health
Subtask 3.4: Verify Deployment Status
Check deployment rollout status:
oc rollout status deployment/sample-app
Get detailed information about the deployment:
oc describe deployment sample-app
Check pod logs to ensure the application is running correctly:
POD_NAME=$(oc get pods -l app=sample-app -o jsonpath='{.items[0].metadata.name}')
oc logs $POD_NAME
Verify the application is responding:
oc port-forward $POD_NAME 8080:8080 &
sleep 2
curl http://localhost:8080
curl http://localhost:8080/health
pkill -f "port-forward"
Troubleshooting Common Issues
Pipeline Execution Issues
Issue: Pipeline fails at the build stage Solution:

# Check build logs
tkn taskrun logs $BUILD_TASKRUN
# Verify Dockerfile syntax and base image availability
Issue: Deployment task fails Solution:

# Check deployment task logs
tkn taskrun logs $DEPLOY_TASKRUN
# Verify image exists in registry
oc get imagestream
Issue: Application pods are not starting Solution:

# Check pod events
oc describe pod $POD_NAME
# Check resource quotas
oc describe quota
Application Access Issues
Issue: Route is not accessible Solution:

# Verify route configuration
oc get route sample-app-route -o yaml
# Check service endpoints
oc get endpoints sample-app-service
Issue: Application returns errors Solution:

# Check application logs
oc logs $POD_NAME
# Verify environment variables
oc describe pod $POD_NAME
Advanced Configuration
Adding Environment Variables
Modify the deployment task to include environment variables:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-to-openshift-advanced
spec:
  params:
    - name: app-name
      type: string
    - name: image-name
      type: string
    - name: namespace
      type: string
      default: \$(context.pipelineRun.namespace)
    - name: env-vars
      type: string
      description: Environment variables in KEY=VALUE format, separated by commas
      default: ""
  steps:
    - name: create-deployment
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        
        curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar xz
        mv oc /usr/local/bin/
        
        # Create deployment with environment variables
        ENV_SECTION=""
        if [ -n "\$(params.env-vars)" ]; then
          IFS=',' read -ra ENVS <<< "\$(params.env-vars)"
          ENV_SECTION="env:"
          for env in "\${ENVS[@]}"; do
            key=\${env%%=*}
            value=\${env#*=}
            ENV_SECTION="\$ENV_SECTION
                - name: \$key
                  value: \"\$value\""
          done
        fi
        
        cat << DEPLOY_EOF > deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: \$(params.app-name)
          namespace: \$(params.namespace)
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: \$(params.app-name)
          template:
            metadata:
              labels:
                app: \$(params.app-name)
            spec:
              containers:
              - name: \$(params.app-name)
                image: \$(params.image-name)
                ports:
                - containerPort: 8080
                \$ENV_SECTION
        DEPLOY_EOF
        
        oc apply -f deployment.yaml
        oc rollout status deployment/\$(params.app-name) -n \$(params.namespace)
EOF
Health Checks and Readiness Probes
Add health checks to the deployment:
# This would be included in the deployment YAML within the task
# livenessProbe:
#   httpGet:
#     path: /health
#     port: 8080
#   initialDelaySeconds: 30
#   periodSeconds: 10
# readinessProbe:
#   httpGet:
#     path: /health
#     port: 8080
#   initialDelaySeconds: 5
#   periodSeconds: 5
Lab Validation
Validation Checklist
Complete the following to validate your lab work:

 Pipeline created successfully with all three tasks
 Custom deployment task created and functional
 PipelineRun executed without errors
 Application deployed to OpenShift
 Service and Route created correctly
 Application accessible via Route URL
 Application responds to HTTP requests
 Deployment logs show successful completion
 Pod is running and healthy
Validation Commands
Run these commands to validate your deployment:

# Validate pipeline
tkn pipeline describe app-deployment-pipeline

# Validate deployment
oc get all -l app=sample-app

# Test application
curl http://$(oc get route sample-app-route -o jsonpath='{.spec.host}')

# Check pipeline run status
tkn pipelinerun list | head -5
Conclusion
In this lab, you have successfully:

• Created a comprehensive deployment pipeline that integrates source code fetching, image building, and application deployment into a single automated workflow • Developed a custom deployment task that handles OpenShift-specific deployment requirements including Deployments, Services, and Routes • Implemented monitoring and logging practices to track pipeline execution and troubleshoot deployment issues • Verified application deployment through multiple validation methods including HTTP testing and resource inspection

Why This Matters:

This lab demonstrates the power of GitOps and CI/CD practices in modern cloud-native development. By automating the deployment process through OpenShift Pipelines, you've created a repeatable, reliable, and auditable deployment mechanism that:

Reduces manual errors and deployment inconsistencies
Enables rapid iteration and continuous delivery
Provides clear visibility into the deployment process
Supports rollback and recovery procedures
Integrates security and compliance checks into the deployment workflow
The skills you've developed here are essential for DevOps engineers and developers working with containerized applications in enterprise environments. OpenShift Pipelines, built on Tekton, provides a Kubernetes-native CI/CD solution that scales with your organization's needs while maintaining the flexibility to customize deployment processes for specific application requirements.

These automated deployment capabilities form the foundation for more advanced practices like blue-green deployments, canary releases, and multi-environment promotion strategies that are crucial for production-ready applications.
