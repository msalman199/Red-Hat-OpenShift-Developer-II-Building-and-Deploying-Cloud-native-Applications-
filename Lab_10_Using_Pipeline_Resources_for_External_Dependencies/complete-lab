Lab 10: Using Pipeline Resources for External Dependencies
Objectives
By the end of this lab, you will be able to:

• Understand the concept of PipelineResources in Tekton pipelines • Define and configure Git repository resources for source code management • Create and manage image registry resources for container image operations • Integrate PipelineResources with pipeline tasks to pull source code and push images • Test and validate resource integration in a complete CI/CD workflow • Troubleshoot common issues with external dependencies in pipelines

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with container technologies and Docker images • Knowledge of Git version control system • Understanding of CI/CD pipeline concepts • Completion of previous Tekton pipeline labs or equivalent experience • Basic command-line interface skills

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with all necessary tools pre-installed. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with Tekton Pipelines installed • kubectl and oc command-line tools • Git client • Text editor (vim/nano) • Access to public container registries

Task 1: Define PipelineResources for Git and Image Registries
Subtask 1.1: Create a Git Repository Resource
First, we'll create a PipelineResource that points to a Git repository containing our source code.

Create a new directory for your lab files:
mkdir -p ~/lab10-pipeline-resources
cd ~/lab10-pipeline-resources
Create a Git resource definition file:
cat > git-resource.yaml << 'EOF'
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: source-code-repo
  namespace: default
spec:
  type: git
  params:
    - name: revision
      value: main
    - name: url
      value: https://github.com/tektoncd/pipeline.git
EOF
Apply the Git resource to your cluster:
kubectl apply -f git-resource.yaml
Verify the resource was created successfully:
kubectl get pipelineresources
Subtask 1.2: Create an Image Registry Resource
Now we'll create a PipelineResource for pushing built container images to a registry.

Create an image resource definition file:
cat > image-resource.yaml << 'EOF'
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: built-image
  namespace: default
spec:
  type: image
  params:
    - name: url
      value: docker.io/your-username/sample-app:latest
EOF
Note: Replace your-username with your actual Docker Hub username or use a different registry URL if preferred.

Apply the image resource:
kubectl apply -f image-resource.yaml
Verify both resources are available:
kubectl get pipelineresources -o wide
Subtask 1.3: Create Registry Credentials (Optional)
If you're using a private registry, create a secret for authentication:

Create a Docker registry secret:
kubectl create secret docker-registry registry-credentials \
  --docker-server=docker.io \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@example.com
Create a service account that uses this secret:
cat > pipeline-service-account.yaml << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline-sa
  namespace: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
EOF
Apply the service account:
kubectl apply -f pipeline-service-account.yaml
Task 2: Use Resources in Pipeline Tasks
Subtask 2.1: Create a Task to Clone Source Code
Create a task that uses the Git resource to clone source code.

Create a git-clone task definition:
cat > git-clone-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone-task
  namespace: default
spec:
  resources:
    inputs:
      - name: source-repo
        type: git
  steps:
    - name: list-source-files
      image: alpine/git:latest
      workingDir: /workspace/source-repo
      script: |
        #!/bin/sh
        echo "=== Source Code Repository Contents ==="
        ls -la
        echo ""
        echo "=== Git Information ==="
        git log --oneline -5
        echo ""
        echo "=== Repository Status ==="
        git status
EOF
Apply the task:
kubectl apply -f git-clone-task.yaml
Subtask 2.2: Create a Task to Build and Push Images
Create a task that builds a container image and pushes it using the image resource.

Create a build-and-push task:
cat > build-push-task.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-push-task
  namespace: default
spec:
  resources:
    inputs:
      - name: source-repo
        type: git
    outputs:
      - name: built-image
        type: image
  steps:
    - name: create-dockerfile
      image: alpine:latest
      workingDir: /workspace/source-repo
      script: |
        #!/bin/sh
        echo "=== Creating Simple Dockerfile ==="
        cat > Dockerfile << 'DOCKERFILE_EOF'
        FROM nginx:alpine
        COPY . /usr/share/nginx/html/
        EXPOSE 80
        CMD ["nginx", "-g", "daemon off;"]
        DOCKERFILE_EOF
        echo "Dockerfile created:"
        cat Dockerfile
    
    - name: build-and-push
      image: gcr.io/kaniko-project/executor:latest
      args:
        - --dockerfile=/workspace/source-repo/Dockerfile
        - --context=/workspace/source-repo
        - --destination=$(resources.outputs.built-image.url)
        - --skip-tls-verify
      env:
        - name: DOCKER_CONFIG
          value: /tekton/home/.docker
EOF
Apply the build-push task:
kubectl apply -f build-push-task.yaml
Subtask 2.3: Create a Complete Pipeline
Now create a pipeline that uses both tasks and resources.

Create the pipeline definition:
cat > complete-pipeline.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image-pipeline
  namespace: default
spec:
  resources:
    - name: app-source
      type: git
    - name: app-image
      type: image
  tasks:
    - name: clone-source
      taskRef:
        name: git-clone-task
      resources:
        inputs:
          - name: source-repo
            resource: app-source
    
    - name: build-and-push-image
      taskRef:
        name: build-push-task
      runAfter:
        - clone-source
      resources:
        inputs:
          - name: source-repo
            resource: app-source
        outputs:
          - name: built-image
            resource: app-image
EOF
Apply the pipeline:
kubectl apply -f complete-pipeline.yaml
Verify the pipeline was created:
kubectl get pipelines
Task 3: Test Resource Integration
Subtask 3.1: Create and Run a PipelineRun
Test the complete integration by running the pipeline with our defined resources.

Create a PipelineRun that uses our resources:
cat > pipeline-run.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: test-resource-integration
  namespace: default
spec:
  pipelineRef:
    name: source-to-image-pipeline
  resources:
    - name: app-source
      resourceRef:
        name: source-code-repo
    - name: app-image
      resourceRef:
        name: built-image
  serviceAccountName: pipeline-sa
EOF
Start the pipeline run:
kubectl apply -f pipeline-run.yaml
Monitor the pipeline execution:
kubectl get pipelinerun test-resource-integration -w
Subtask 3.2: Monitor Task Execution
Watch the individual tasks as they execute.

Check the status of all tasks:
kubectl get taskruns
View logs from the git-clone task:
# Get the taskrun name for git-clone
CLONE_TASKRUN=$(kubectl get taskruns -l tekton.dev/pipelineTask=clone-source -o jsonpath='{.items[0].metadata.name}')
kubectl logs -f $CLONE_TASKRUN
View logs from the build-push task:
# Get the taskrun name for build-push
BUILD_TASKRUN=$(kubectl get taskruns -l tekton.dev/pipelineTask=build-and-push-image -o jsonpath='{.items[0].metadata.name}')
kubectl logs -f $BUILD_TASKRUN
Subtask 3.3: Verify Resource Usage
Confirm that resources were properly utilized during the pipeline execution.

Check the PipelineRun status in detail:
kubectl describe pipelinerun test-resource-integration
Verify that the Git repository was cloned by examining task logs:
kubectl logs -l tekton.dev/pipelineTask=clone-source --tail=50
Check if the image was built and pushed successfully:
kubectl logs -l tekton.dev/pipelineTask=build-and-push-image --tail=50
Subtask 3.4: Test with Different Resources
Create and test with different resource configurations.

Create an alternative Git resource pointing to a different repository:
cat > alt-git-resource.yaml << 'EOF'
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: alternative-source
  namespace: default
spec:
  type: git
  params:
    - name: revision
      value: main
    - name: url
      value: https://github.com/spring-projects/spring-petclinic.git
EOF
Apply the alternative resource:
kubectl apply -f alt-git-resource.yaml
Create a new PipelineRun using the alternative resource:
cat > alt-pipeline-run.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: test-alternative-source
  namespace: default
spec:
  pipelineRef:
    name: source-to-image-pipeline
  resources:
    - name: app-source
      resourceRef:
        name: alternative-source
    - name: app-image
      resourceRef:
        name: built-image
  serviceAccountName: pipeline-sa
EOF
Run the alternative pipeline:
kubectl apply -f alt-pipeline-run.yaml
Monitor the execution:
kubectl get pipelinerun test-alternative-source -w
Troubleshooting Common Issues
Issue 1: Git Clone Failures
If Git cloning fails, check the following:

Verify the Git URL is accessible:
git ls-remote https://github.com/tektoncd/pipeline.git
Check if authentication is required:
kubectl describe pipelineresource source-code-repo
For private repositories, create a Git credential secret:
kubectl create secret generic git-credentials \
  --from-literal=username=your-username \
  --from-literal=password=your-token
Issue 2: Image Push Failures
If image pushing fails:

Verify registry credentials:
kubectl get secret registry-credentials -o yaml
Check if the registry URL is correct:
kubectl describe pipelineresource built-image
Test registry connectivity:
docker login docker.io
Issue 3: Resource Not Found Errors
If resources are not found:

List all available resources:
kubectl get pipelineresources -A
Check resource names and namespaces:
kubectl describe pipelineresource source-code-repo
Verify resource references in pipeline definitions:
kubectl get pipeline source-to-image-pipeline -o yaml
Validation and Testing
Validate Resource Definitions
Check that all resources are properly defined:
kubectl get pipelineresources -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,URL:.spec.params[0].value
Verify resource parameters:
kubectl describe pipelineresource source-code-repo
kubectl describe pipelineresource built-image
Test Pipeline Functionality
Create a simple test to verify the complete workflow:
cat > validation-test.yaml << 'EOF'
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: validation-test
  namespace: default
spec:
  pipelineRef:
    name: source-to-image-pipeline
  resources:
    - name: app-source
      resourceRef:
        name: source-code-repo
    - name: app-image
      resourceRef:
        name: built-image
  serviceAccountName: pipeline-sa
EOF
Run the validation test:
kubectl apply -f validation-test.yaml
Wait for completion and check results:
kubectl wait --for=condition=Succeeded pipelinerun/validation-test --timeout=600s
kubectl get pipelinerun validation-test -o jsonpath='{.status.conditions[0].reason}'
Cleanup
After completing the lab, clean up the resources:

# Delete PipelineRuns
kubectl delete pipelinerun --all

# Delete Pipeline and Tasks
kubectl delete pipeline source-to-image-pipeline
kubectl delete task git-clone-task build-push-task

# Delete PipelineResources
kubectl delete pipelineresource source-code-repo built-image alternative-source

# Delete Service Account and Secrets
kubectl delete serviceaccount pipeline-sa
kubectl delete secret registry-credentials git-credentials

# Remove lab files
cd ~
rm -rf lab10-pipeline-resources
Conclusion
In this lab, you have successfully:

• Defined PipelineResources for both Git repositories and image registries, learning how to configure external dependencies in Tekton pipelines • Created and configured tasks that utilize these resources to perform real-world operations like source code cloning and image building • Built a complete CI/CD pipeline that integrates multiple resources and tasks in a coordinated workflow • Tested resource integration through multiple pipeline runs, validating that external dependencies work correctly • Troubleshot common issues and learned best practices for managing pipeline resources

Why This Matters: PipelineResources are fundamental to creating robust CI/CD pipelines that interact with external systems. By mastering resource management, you can build pipelines that automatically pull source code from Git repositories, push built images to registries, and integrate with various external services. This knowledge is essential for implementing production-ready DevOps workflows in cloud-native environments.

The skills you've developed in this lab directly apply to real-world scenarios where applications need to be automatically built, tested, and deployed from source code repositories to container registries, forming the backbone of modern software delivery practices.
