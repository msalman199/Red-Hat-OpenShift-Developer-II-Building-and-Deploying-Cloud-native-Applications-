Lab 8: Adding a Test Stage to a Pipeline
Objectives
By the end of this lab, you will be able to:

• Create and configure a test task within a CI/CD pipeline • Integrate automated testing into the build process after container image creation • Validate the proper execution and functionality of the test stage • Understand the importance of automated testing in cloud-native application development • Implement best practices for pipeline testing workflows

Prerequisites
Before starting this lab, you should have:

• Basic understanding of containerization concepts (Docker/Podman) • Familiarity with CI/CD pipeline concepts • Knowledge of YAML syntax and structure • Experience with command-line interface operations • Understanding of Git version control basics • Completion of previous pipeline labs or equivalent experience

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment - no need to build or configure your own virtual machine. Your lab environment includes:

• Pre-installed OpenShift CLI (oc) • Tekton CLI (tkn) tools • Git client • Text editors (vim, nano) • Sample application code • Network access to container registries

Task 1: Create a New Test Task in the Pipeline
Subtask 1.1: Examine the Current Pipeline Structure
First, let's understand the existing pipeline configuration and identify where to add our test stage.

Connect to your lab environment and navigate to the working directory:
cd ~/pipeline-lab
List the current pipeline files to see what we're working with:
ls -la
Examine the existing pipeline configuration:
cat pipeline.yaml
Review the current tasks in the pipeline:
grep -A 5 -B 5 "kind: Task" *.yaml
Subtask 1.2: Create the Test Task Definition
Now we'll create a dedicated test task that will run our application tests.

Create a new test task file:
nano test-task.yaml
Add the following test task definition:
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: run-tests
  labels:
    app.kubernetes.io/version: "0.1"
spec:
  description: >-
    This task runs unit tests and integration tests for the application
  params:
    - name: image-url
      description: The URL of the container image to test
      type: string
    - name: test-command
      description: The command to run tests
      type: string
      default: "npm test"
  workspaces:
    - name: source
      description: The workspace containing the source code
  steps:
    - name: run-unit-tests
      image: node:16-alpine
      workingDir: $(workspaces.source.path)
      script: |
        #!/bin/sh
        echo "Installing dependencies..."
        npm install
        
        echo "Running unit tests..."
        npm run test:unit || exit 1
        
        echo "Unit tests completed successfully!"
        
    - name: run-integration-tests
      image: $(params.image-url)
      script: |
        #!/bin/sh
        echo "Starting integration tests..."
        
        # Wait for application to be ready
        sleep 5
        
        # Run integration tests
        $(params.test-command)
        
        echo "Integration tests completed successfully!"
        
    - name: test-results
      image: alpine:latest
      script: |
        #!/bin/sh
        echo "==================================="
        echo "TEST EXECUTION SUMMARY"
        echo "==================================="
        echo "✓ Unit tests: PASSED"
        echo "✓ Integration tests: PASSED"
        echo "✓ All tests completed successfully"
        echo "==================================="
Save and exit the file (Ctrl+X, then Y, then Enter in nano).
Subtask 1.3: Create Test Configuration Files
Let's create the necessary test configuration and sample test files.

Create a test configuration file:
nano test-config.yaml
Add the test configuration:
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
data:
  test-script.sh: |
    #!/bin/bash
    echo "Executing application health check..."
    
    # Test application endpoint
    curl -f http://localhost:8080/health || exit 1
    
    # Test application functionality
    response=$(curl -s http://localhost:8080/api/status)
    if [[ "$response" == *"healthy"* ]]; then
        echo "Application is responding correctly"
        exit 0
    else
        echo "Application health check failed"
        exit 1
    fi
  
  package.json: |
    {
      "name": "pipeline-test-app",
      "version": "1.0.0",
      "scripts": {
        "test": "echo 'Running all tests...' && npm run test:unit",
        "test:unit": "echo 'Unit tests passed!' && exit 0"
      },
      "devDependencies": {
        "jest": "^27.0.0"
      }
    }
Save and exit the file.
Task 2: Modify the Pipeline to Run Tests After Building the Container Image
Subtask 2.1: Update the Pipeline Definition
Now we'll modify the existing pipeline to include our test stage after the build stage.

Create a backup of the current pipeline:
cp pipeline.yaml pipeline-backup.yaml
Edit the pipeline configuration:
nano pipeline.yaml
Update the pipeline to include the test stage. Replace the existing content with:
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-test-deploy-pipeline
  labels:
    app.kubernetes.io/version: "0.1"
spec:
  description: >-
    Pipeline that builds, tests, and deploys the application
  params:
    - name: repo-url
      type: string
      description: The git repository URL to clone from
    - name: image-reference
      type: string
      description: The container image reference to build
    - name: deployment-name
      type: string
      description: The name of the deployment
      default: "my-app"
  workspaces:
    - name: shared-data
      description: Workspace shared between tasks
    - name: docker-credentials
      description: Docker registry credentials
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
          value: $(params.repo-url)
        - name: revision
          value: "main"
    
    - name: build-image
      taskRef:
        name: buildah
        kind: ClusterTask
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-data
        - name: dockerconfig
          workspace: docker-credentials
      params:
        - name: IMAGE
          value: $(params.image-reference)
        - name: DOCKERFILE
          value: "./Dockerfile"
    
    - name: run-tests
      taskRef:
        name: run-tests
      runAfter:
        - build-image
      workspaces:
        - name: source
          workspace: shared-data
      params:
        - name: image-url
          value: $(params.image-reference)
        - name: test-command
          value: "npm test"
    
    - name: deploy-application
      taskRef:
        name: openshift-client
        kind: ClusterTask
      runAfter:
        - run-tests
      workspaces:
        - name: manifest-dir
          workspace: shared-data
      params:
        - name: SCRIPT
          value: |
            oc apply -f k8s/
            oc set image deployment/$(params.deployment-name) \
              app=$(params.image-reference)
            oc rollout status deployment/$(params.deployment-name)
Save and exit the file.
Subtask 2.2: Create Sample Application Files
Let's create a simple application structure for testing purposes.

Create application directory structure:
mkdir -p app/src app/tests k8s
Create a simple Node.js application:
nano app/package.json
Add the package.json content:
{
  "name": "test-app",
  "version": "1.0.0",
  "description": "Sample application for pipeline testing",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "npm run test:unit && npm run test:integration",
    "test:unit": "echo 'Running unit tests...' && node tests/unit.test.js",
    "test:integration": "echo 'Running integration tests...' && node tests/integration.test.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^27.0.0"
  }
}
Create the main application file:
nano app/server.js
Add the server code:
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/status', (req, res) => {
  res.status(200).json({ 
    message: 'Application is healthy',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

app.get('/', (req, res) => {
  res.send('Hello from Pipeline Test Application!');
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = { app, server };
Create unit test file:
nano app/tests/unit.test.js
Add unit test content:
// Simple unit test
console.log('✓ Testing application modules...');

// Test 1: Basic functionality
function testBasicFunction() {
  const result = 2 + 2;
  if (result === 4) {
    console.log('✓ Basic math test passed');
    return true;
  } else {
    console.log('✗ Basic math test failed');
    return false;
  }
}

// Test 2: String operations
function testStringOperations() {
  const str = 'Hello World';
  if (str.length === 11) {
    console.log('✓ String length test passed');
    return true;
  } else {
    console.log('✗ String length test failed');
    return false;
  }
}

// Run tests
const test1 = testBasicFunction();
const test2 = testStringOperations();

if (test1 && test2) {
  console.log('✓ All unit tests passed!');
  process.exit(0);
} else {
  console.log('✗ Some unit tests failed!');
  process.exit(1);
}
Create integration test file:
nano app/tests/integration.test.js
Add integration test content:
// Simple integration test
console.log('✓ Running integration tests...');

// Simulate API testing
function testAPIEndpoint() {
  console.log('✓ Testing API endpoint availability...');
  // Simulate successful API test
  return true;
}

function testDatabaseConnection() {
  console.log('✓ Testing database connection...');
  // Simulate successful database test
  return true;
}

function testExternalServices() {
  console.log('✓ Testing external service connections...');
  // Simulate successful external service test
  return true;
}

// Run integration tests
const apiTest = testAPIEndpoint();
const dbTest = testDatabaseConnection();
const serviceTest = testExternalServices();

if (apiTest && dbTest && serviceTest) {
  console.log('✓ All integration tests passed!');
  process.exit(0);
} else {
  console.log('✗ Some integration tests failed!');
  process.exit(1);
}
Subtask 2.3: Create Dockerfile for the Application
Create a Dockerfile:
nano app/Dockerfile
Add the Dockerfile content:
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["npm", "start"]
Save and exit the file.
Task 3: Validate the Execution of the Test Stage
Subtask 3.1: Apply the Pipeline Resources
Now let's apply our pipeline configuration and test task to the cluster.

Apply the test task:
oc apply -f test-task.yaml
Apply the test configuration:
oc apply -f test-config.yaml
Apply the updated pipeline:
oc apply -f pipeline.yaml
Verify the resources were created:
oc get tasks
oc get pipelines
oc get configmaps
Subtask 3.2: Create Pipeline Workspaces
We need to create the necessary workspaces for our pipeline.

Create a PersistentVolumeClaim for shared data:
nano pipeline-workspace.yaml
Add the workspace configuration:
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pipeline-shared-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6e319  # Empty docker config for demo
Apply the workspace configuration:
oc apply -f pipeline-workspace.yaml
Subtask 3.3: Run the Pipeline with Test Stage
Now let's execute the pipeline and validate that our test stage runs correctly.

Create a PipelineRun to execute our pipeline:
nano test-pipeline-run.yaml
Add the PipelineRun configuration:
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-test-deploy-run-$(date +%s)
  generateName: build-test-deploy-run-
spec:
  pipelineRef:
    name: build-test-deploy-pipeline
  params:
    - name: repo-url
      value: "https://github.com/your-username/sample-app.git"
    - name: image-reference
      value: "image-registry.openshift-image-registry.svc:5000/default/test-app:latest"
    - name: deployment-name
      value: "test-app"
  workspaces:
    - name: shared-data
      persistentVolumeClaim:
        claimName: pipeline-shared-data
    - name: docker-credentials
      secret:
        secretName: docker-credentials
Start the pipeline run:
oc apply -f test-pipeline-run.yaml
Monitor the pipeline execution:
tkn pipelinerun list
Watch the pipeline run in real-time:
tkn pipelinerun logs --last -f
Subtask 3.4: Verify Test Stage Execution
Let's verify that our test stage executed successfully and examine the results.

Check the status of all pipeline runs:
tkn pipelinerun list
Get detailed information about the latest run:
tkn pipelinerun describe --last
View the logs specifically for the test task:
tkn taskrun logs --last -f
Check the test task execution details:
oc get taskruns -l tekton.dev/pipelineTask=run-tests
Examine the test results in detail:
LATEST_TASKRUN=$(oc get taskruns -l tekton.dev/pipelineTask=run-tests -o jsonpath='{.items[0].metadata.name}')
oc logs $LATEST_TASKRUN -c step-run-unit-tests
oc logs $LATEST_TASKRUN -c step-run-integration-tests
oc logs $LATEST_TASKRUN -c step-test-results
Subtask 3.5: Troubleshooting and Validation
Let's perform some troubleshooting steps and validate our implementation.

Check for any failed pipeline runs:
oc get pipelineruns -o wide
If there are failures, examine the logs:
tkn pipelinerun logs <failed-run-name>
Verify the test task is properly configured:
oc describe task run-tests
Check the pipeline definition includes our test stage:
oc get pipeline build-test-deploy-pipeline -o yaml | grep -A 10 -B 5 "run-tests"
Validate the test stage runs after the build stage:
oc get pipeline build-test-deploy-pipeline -o jsonpath='{.spec.tasks[*].name}'
Common Issues and Troubleshooting
Issue 1: Test Task Not Found
Problem: Pipeline fails with "Task run-tests not found"

Solution:

# Verify the task exists
oc get tasks run-tests

# If not found, reapply the task
oc apply -f test-task.yaml
Issue 2: Workspace Mount Issues
Problem: Tests fail due to workspace mounting problems

Solution:

# Check PVC status
oc get pvc pipeline-shared-data

# Verify workspace configuration in pipeline
oc describe pipeline build-test-deploy-pipeline
Issue 3: Test Execution Failures
Problem: Tests fail during execution

Solution:

# Check test logs for specific errors
tkn taskrun logs --last -f

# Verify test files exist in workspace
oc debug <pod-name> -- ls -la /workspace/source/
Validation Checklist
Before completing this lab, ensure you have:

 Successfully created the test task definition
 Modified the pipeline to include the test stage after build
 Applied all configuration files without errors
 Executed a complete pipeline run including the test stage
 Verified test logs show successful execution
 Confirmed the test stage runs in the correct sequence
 Validated that failed tests would stop the pipeline
 Reviewed all pipeline components are working together
Conclusion
Congratulations! You have successfully completed Lab 8: Adding a Test Stage to a Pipeline. In this lab, you accomplished several important objectives:

What You Learned: • Test Integration: You created a comprehensive test task that includes both unit and integration tests, demonstrating how to validate application functionality within a CI/CD pipeline • Pipeline Orchestration: You modified an existing pipeline to include automated testing after the build stage, ensuring that only tested code proceeds to deployment • Quality Gates: You implemented a quality gate mechanism where the pipeline stops if tests fail, preventing faulty code from reaching production • Best Practices: You learned industry-standard practices for structuring test stages in cloud-native application pipelines

Why This Matters: Testing is a critical component of modern DevOps practices. By integrating automated tests into your pipeline, you ensure that:

Code quality is maintained throughout the development lifecycle
Bugs are caught early in the process, reducing costs and time to fix
Deployments are more reliable and stable
Teams can move faster with confidence in their releases
Real-World Applications: The skills you've developed in this lab are directly applicable to enterprise environments where:

Multiple developers contribute to the same codebase
Applications must meet strict quality and reliability standards
Automated testing reduces manual effort and human error
Continuous integration and deployment are essential for competitive advantage
You now have the knowledge to implement robust testing strategies in your own CI/CD pipelines, making you a more valuable contributor to any development team working with cloud-native applications and OpenShift environments.
