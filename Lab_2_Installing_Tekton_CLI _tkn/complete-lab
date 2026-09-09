Lab 2: Installing Tekton CLI (tkn)
Objectives
By the end of this lab, you will be able to:

• Install the Tekton CLI (tkn) on a Linux system • Verify the installation by running basic tkn commands • Use tkn to interact with Tekton pipelines in an OpenShift cluster • Understand the basic functionality and purpose of the Tekton CLI • List and inspect available Tekton pipelines using command-line tools

Prerequisites
Before starting this lab, you should have:

• Basic knowledge of Linux command-line operations • Understanding of container concepts and Kubernetes fundamentals • Familiarity with OpenShift or Kubernetes cluster operations • Basic understanding of CI/CD pipeline concepts • Access to a terminal or command-line interface

Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click Start Lab to access your environment. No need to build your own virtual machine or configure additional infrastructure. Your cloud machine comes with:

• Linux operating system (CentOS/RHEL-based) • Internet connectivity for downloading packages • Terminal access with sudo privileges • Pre-configured network settings

Lab Environment Setup
Your cloud machine is ready to use immediately. You will work primarily in the terminal to install and configure the Tekton CLI.

Task 1: Install tkn CLI on Your Local System
Subtask 1.1: Check System Information
First, let's verify your system information to ensure compatibility.

Open a terminal on your cloud machine
Check your operating system version:
cat /etc/os-release
Verify your system architecture:
uname -m
Check if you have curl installed (required for downloading):
which curl
If curl is not installed, install it:

sudo yum install -y curl
Subtask 1.2: Download the Tekton CLI
The Tekton CLI is distributed as a binary that you can download directly from the official GitHub releases.

Navigate to your home directory:
cd ~
Create a directory for the Tekton CLI:
mkdir -p ~/tekton-cli
cd ~/tekton-cli
Download the latest version of tkn CLI for Linux:
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
Verify the download completed successfully:
ls -la tkn_Linux_x86_64.tar.gz
Subtask 1.3: Extract and Install the CLI
Extract the downloaded archive:
tar -xzf tkn_Linux_x86_64.tar.gz
List the extracted files:
ls -la
You should see the tkn binary file.

Make the binary executable:
chmod +x tkn
Move the binary to a directory in your PATH:
sudo mv tkn /usr/local/bin/
Verify the binary is in your PATH:
which tkn
Subtask 1.4: Clean Up Installation Files
Remove the downloaded archive and temporary directory:

cd ~
rm -rf ~/tekton-cli
Task 2: Verify Installation by Running Basic tkn Commands
Subtask 2.1: Check tkn Version
Verify the installation by checking the version:
tkn version
This command should display the client version information. Note that you may see a message about not being able to connect to a cluster, which is expected if you haven't configured cluster access yet.

Subtask 2.2: Display Help Information
View the general help information:
tkn --help
Explore available commands:
tkn help
Get help for a specific command (pipelines):
tkn pipeline --help
Subtask 2.3: Test Basic CLI Functionality
List available tkn commands:
tkn completion --help
Generate bash completion (optional, for better command-line experience):
tkn completion bash > ~/.tkn_completion
echo "source ~/.tkn_completion" >> ~/.bashrc
source ~/.bashrc
Task 3: Use tkn to List Available Pipelines
Subtask 3.1: Configure Cluster Access
Before you can list pipelines, you need access to an OpenShift cluster with Tekton installed. For this lab, we'll simulate the commands and show you what they would look like.

First, check if you have cluster access configured:
tkn pipeline list
If you see an error about cluster access, this is expected in the lab environment.

Subtask 3.2: Understanding Pipeline Commands
Even without cluster access, you can explore the pipeline-related commands:

View pipeline command options:
tkn pipeline --help
View pipelinerun command options:
tkn pipelinerun --help
View task command options:
tkn task --help
Subtask 3.3: Simulated Pipeline Operations
Here are examples of commands you would use when connected to a cluster with Tekton pipelines:

List all pipelines in the current namespace:
# This command would list all pipelines
tkn pipeline list
List pipelines in a specific namespace:
# This command would list pipelines in the 'my-project' namespace
tkn pipeline list -n my-project
Get detailed information about a specific pipeline:
# This command would show details of a pipeline named 'build-pipeline'
tkn pipeline describe build-pipeline
List pipeline runs:
# This command would list all pipeline runs
tkn pipelinerun list
View logs from a pipeline run:
# This command would show logs from a specific pipeline run
tkn pipelinerun logs my-pipeline-run-123
Subtask 3.4: Understanding Output Format
When connected to a cluster, the tkn CLI provides output in various formats:

Default table format - Easy to read in terminal
JSON format - For programmatic processing:
# Example command for JSON output
tkn pipeline list -o json
YAML format - For configuration review:
# Example command for YAML output
tkn pipeline list -o yaml
Troubleshooting Common Issues
Issue 1: Permission Denied During Installation
Problem: Cannot move tkn binary to /usr/local/bin/

Solution:

# Use sudo for system directory access
sudo mv tkn /usr/local/bin/
Issue 2: Command Not Found After Installation
Problem: tkn command not found after installation

Solution:

# Check if /usr/local/bin is in your PATH
echo $PATH

# If not, add it to your PATH
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
Issue 3: Download Fails
Problem: Cannot download the tkn binary

Solution:

# Check internet connectivity
ping -c 3 github.com

# Try alternative download method
wget https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
Issue 4: Architecture Mismatch
Problem: Binary doesn't work on your system

Solution:

# Check your architecture
uname -m

# Download the correct version for your architecture
# For ARM64: tkn_Linux_arm64.tar.gz
# For x86_64: tkn_Linux_x86_64.tar.gz
Verification Steps
To ensure your installation is successful, run these verification commands:

Check version:
tkn version
Verify help system works:
tkn --help
Test command completion:
tkn pipeline --help
Check binary location:
which tkn
ls -la /usr/local/bin/tkn
Key Concepts Learned
Tekton CLI (tkn)
The Tekton CLI is a command-line interface for interacting with Tekton Pipelines. It provides an easy way to:

Create and manage pipelines
Monitor pipeline runs
View logs and status
Debug pipeline issues
Pipeline Management
With tkn, you can:

List pipelines - View all available pipelines in a namespace
Describe pipelines - Get detailed information about pipeline structure
Start pipelines - Trigger new pipeline runs
Monitor runs - Track pipeline execution status
Command Structure
Tekton CLI follows a consistent command structure:

tkn [resource-type] [action] [options]
Examples:

tkn pipeline list - List pipelines
tkn pipelinerun describe my-run - Describe a pipeline run
tkn task start my-task - Start a task
Conclusion
In this lab, you have successfully:

• Installed the Tekton CLI (tkn) on your Linux system using the official binary distribution • Verified the installation by running version checks and help commands • Explored the command structure and available options for pipeline management • Learned the basic commands for listing and inspecting Tekton pipelines • Understood troubleshooting techniques for common installation issues

The Tekton CLI is an essential tool for developers working with cloud-native CI/CD pipelines in OpenShift and Kubernetes environments. It provides a powerful command-line interface for managing complex pipeline workflows, monitoring execution, and debugging issues. This foundation will be crucial as you progress to more advanced Tekton pipeline operations and OpenShift development workflows.

With tkn installed and verified, you're now ready to interact with Tekton pipelines in OpenShift clusters, create custom pipeline definitions, and manage CI/CD workflows effectively. The skills learned in this lab directly support the Red Hat OpenShift Developer II certification objectives and prepare you for real-world cloud-native application development scenarios.
