Lab 1: Setting Up OpenShift Pipelines Operator
Objectives
By the end of this lab, you will be able to:

• Install the OpenShift Pipelines Operator using the OpenShift CLI (oc) • Verify that Tekton Custom Resource Definitions (CRDs) and resources are properly installed • Confirm successful installation through both command-line interface and web console • Understand the core components of OpenShift Pipelines and their relationship to Tekton • Navigate the OpenShift web console to manage pipeline resources

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with OpenShift fundamentals • Knowledge of command-line interface operations • Understanding of YAML file structure • Basic knowledge of CI/CD concepts

Technical Requirements: • Access to an OpenShift cluster (version 4.6 or later) • OpenShift CLI (oc) installed and configured • Cluster administrator privileges or sufficient permissions to install operators

Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment. No need to build your own virtual machine or install additional software - everything is ready to use!

Your lab environment includes: • OpenShift cluster access • Pre-configured oc CLI tool • Web browser for console access • All necessary permissions configured

Lab Tasks
Task 1: Install OpenShift Pipelines Operator using oc
The OpenShift Pipelines Operator provides OpenShift with Tekton capabilities for building CI/CD pipelines. We'll install it using the command-line interface.

Subtask 1.1: Verify Cluster Access
First, let's ensure you have proper access to your OpenShift cluster.

Open your terminal in the lab environment

Check your current cluster connection:

oc whoami
Verify cluster information:
oc cluster-info
Check your current project:
oc project
Expected Output: You should see your username and cluster details. If you encounter authentication errors, contact your lab administrator.

Subtask 1.2: Create Operator Subscription
The OpenShift Pipelines Operator is installed through the Operator Lifecycle Manager (OLM) using a Subscription resource.

Create a YAML file for the operator subscription:
cat > pipelines-operator-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Apply the subscription to install the operator:
oc apply -f pipelines-operator-subscription.yaml
Verify the subscription was created:
oc get subscription openshift-pipelines-operator -n openshift-operators
Expected Output: You should see the subscription with a status showing it's being processed.

Subtask 1.3: Monitor Installation Progress
The operator installation takes a few minutes. Let's monitor the progress.

Check the Cluster Service Version (CSV) status:
oc get csv -n openshift-operators | grep pipelines
Wait for the operator to reach "Succeeded" phase:
oc get csv -n openshift-operators -w | grep pipelines
Note: Press Ctrl+C to stop watching once you see "Succeeded" status.

Verify the operator pod is running:
oc get pods -n openshift-operators | grep pipelines
Expected Output: You should see the openshift-pipelines-operator pod in "Running" status.

Task 2: Verify that Tekton Resources are Available
Now that the operator is installed, let's verify that all Tekton Custom Resource Definitions (CRDs) are properly created and available.

Subtask 2.1: Check Tekton CRDs
Tekton uses several custom resources to define pipelines, tasks, and runs.

List all Tekton-related CRDs:
oc get crd | grep tekton
Expected Output: You should see CRDs including:

tasks.tekton.dev
pipelines.tekton.dev
pipelineruns.tekton.dev
taskruns.tekton.dev
Get detailed information about the Pipeline CRD:
oc describe crd pipelines.tekton.dev
Check for ClusterTasks (pre-installed tasks):
oc get clustertasks
Expected Output: You should see several pre-installed ClusterTasks like git-clone, buildah, etc.

Subtask 2.2: Verify Tekton Components
The OpenShift Pipelines Operator installs several components in the openshift-pipelines namespace.

Check the openshift-pipelines namespace:
oc get namespaces | grep pipelines
List all resources in the openshift-pipelines namespace:
oc get all -n openshift-pipelines
Verify Tekton controller pods are running:
oc get pods -n openshift-pipelines
Expected Output: You should see pods like:

tekton-pipelines-controller
tekton-pipelines-webhook
tekton-triggers-controller
tekton-triggers-webhook
Subtask 2.3: Test Basic Tekton Functionality
Let's create a simple task to verify everything is working correctly.

Create a test namespace for our pipeline resources:
oc new-project pipeline-test
Create a simple Hello World task:
cat > hello-world-task.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: hello-world
spec:
  steps:
    - name: echo
      image: registry.redhat.io/ubi8/ubi-minimal:latest
      command:
        - echo
      args:
        - "Hello World from OpenShift Pipelines!"
EOF
Apply the task:
oc apply -f hello-world-task.yaml
Verify the task was created:
oc get tasks
Create and run a TaskRun to test the task:
cat > hello-world-taskrun.yaml << EOF
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: hello-world-run
spec:
  taskRef:
    name: hello-world
EOF
Apply the TaskRun:
oc apply -f hello-world-taskrun.yaml
Check the TaskRun status:
oc get taskrun hello-world-run
View the logs to confirm execution:
oc logs -f taskrun/hello-world-run
Expected Output: You should see "Hello World from OpenShift Pipelines!" in the logs.

Task 3: Confirm Installation using OpenShift CLI and Web Console
Let's verify the installation through both command-line and web console interfaces.

Subtask 3.1: CLI Verification Commands
Check operator installation status:
oc get operators
Verify all pipeline-related resources are available:
oc api-resources | grep tekton
Check the operator version:
oc get csv -n openshift-operators | grep pipelines
Verify webhook configurations:
oc get validatingwebhookconfigurations | grep tekton
oc get mutatingwebhookconfigurations | grep tekton
Subtask 3.2: Web Console Verification
Now let's verify the installation through the OpenShift web console.

Open your web browser and navigate to the OpenShift web console URL provided in your lab environment

Log in with your credentials

Navigate to Operators → Installed Operators

Verify that Red Hat OpenShift Pipelines appears in the list with status "Succeeded"

Click on the Red Hat OpenShift Pipelines operator to view details

Check the Provided APIs section - you should see:

Pipeline
PipelineRun
Task
TaskRun
ClusterTask
Subtask 3.3: Explore Pipeline Resources in Web Console
Switch to the pipeline-test project using the project dropdown

Navigate to Pipelines → Tasks

Verify that your "hello-world" task appears in the list

Navigate to Pipelines → TaskRuns

Click on the "hello-world-run" TaskRun to view details

Check the Logs tab to see the execution output

Explore the YAML tab to see the resource definition

Subtask 3.4: Verify Pipeline Builder UI
In the web console, navigate to Pipelines → Pipelines

Click Create → Pipeline

Verify that the Pipeline Builder interface loads correctly

You should see options to:

Add tasks from the catalog
Configure parameters
Set up workspaces
Define pipeline structure
Note: You don't need to create a pipeline now - we're just verifying the UI is functional.

Troubleshooting Common Issues
Issue 1: Operator Installation Stuck
Symptoms: CSV remains in "Installing" state for more than 10 minutes

Solution:

# Check operator pod logs
oc logs -n openshift-operators deployment/openshift-pipelines-operator

# Delete and recreate subscription if needed
oc delete subscription openshift-pipelines-operator -n openshift-operators
oc apply -f pipelines-operator-subscription.yaml
Issue 2: Tekton Pods Not Starting
Symptoms: Tekton controller pods in CrashLoopBackOff state

Solution:

# Check pod logs
oc logs -n openshift-pipelines deployment/tekton-pipelines-controller

# Verify cluster resources
oc get nodes
oc describe nodes
Issue 3: TaskRun Fails to Execute
Symptoms: TaskRun remains in "Pending" state

Solution:

# Check TaskRun events
oc describe taskrun hello-world-run

# Verify service account permissions
oc get serviceaccount default
oc describe serviceaccount default
Verification Checklist
Before proceeding to the next lab, ensure you have completed:

 OpenShift Pipelines Operator installed successfully
 All Tekton CRDs are available
 Tekton controller pods are running
 ClusterTasks are available
 Test task created and executed successfully
 Web console shows pipeline resources correctly
 Pipeline Builder UI is accessible
Conclusion
Congratulations! You have successfully completed Lab 1: Setting Up OpenShift Pipelines Operator.

What You Accomplished:

• Installed OpenShift Pipelines Operator - You learned how to use the OpenShift CLI to install operators through subscriptions, which is a fundamental skill for managing OpenShift clusters.

• Verified Tekton Integration - You confirmed that all necessary Tekton Custom Resource Definitions are available, enabling you to create and manage CI/CD pipelines.

• Tested Basic Functionality - By creating and running a simple task, you verified that the pipeline infrastructure is working correctly and ready for more complex workflows.

• Explored Multiple Interfaces - You gained experience with both command-line and web console management, giving you flexibility in how you interact with OpenShift Pipelines.

Why This Matters:

OpenShift Pipelines, based on the open-source Tekton project, provides a Kubernetes-native CI/CD solution that integrates seamlessly with your containerized applications. This foundation enables you to:

Build automated deployment pipelines
Implement GitOps workflows
Create reusable pipeline components
Scale CI/CD processes across multiple projects
Maintain consistency in application delivery
The skills you've developed in this lab form the foundation for creating sophisticated CI/CD pipelines that can automatically build, test, and deploy your applications in a cloud-native environment. In subsequent labs, you'll build upon this foundation to create complete pipeline workflows for real-world applications.

Next Steps:

With OpenShift Pipelines now installed and verified, you're ready to move on to creating your first pipeline, where you'll learn to chain tasks together and build more complex automation workflows.
