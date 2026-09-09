<div align="center">

# 🔌 Working with Tekton PipelineResources

![Tekton](https://img.shields.io/badge/Tekton-CI%2FCD-2091FF?style=for-the-badge&logo=tekton&logoColor=white)
![OpenShift](https://img.shields.io/badge/OpenShift-Red%20Hat-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Git](https://img.shields.io/badge/Git-Repositories-F05032?style=for-the-badge&logo=git&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Level](https://img.shields.io/badge/Level-Intermediate-yellow?style=for-the-badge)

</div>

---

## 📋 Table of Contents

- [📖 Overview](#-overview)
- [🎯 Learning Objectives](#-learning-objectives)
- [✅ Prerequisites](#-prerequisites)
- [🛠️ Lab Environment](#️-lab-environment)
- [📚 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)

---

## 📖 Overview

This lab focuses on Tekton PipelineResources — the way pipelines declare and configure their external dependencies. You'll define resources for both Git repositories and image registries, build tasks that use those resources for real operations like source cloning and image building, and assemble everything into a coordinated CI/CD pipeline that you'll test and troubleshoot end to end.

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Define PipelineResources for Git repositories and image registries |
| 2 | Configure external dependencies in Tekton pipelines |
| 3 | Create and configure tasks that use these resources for source code cloning and image building |
| 4 | Build a complete CI/CD pipeline integrating multiple resources and tasks in a coordinated workflow |
| 5 | Test resource integration through multiple pipeline runs, validating external dependencies |
| 6 | Troubleshoot common resource issues and apply best practices for pipeline resource management |

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🔧 OpenShift Pipelines Operator | Installed and verified (prior lab) |
| 💻 tkn CLI | Installed and configured (prior lab) |
| 📄 Working Tekton Pipeline | A deployment pipeline, as built in the previous lab |
| 🐙 Git Repository Access | A Git repository to use as a source resource |
| 📦 Image Registry Access | An image registry to push/pull built images |
| ☸️ oc CLI | Installed and authenticated to your cluster |

## 🛠️ Lab Environment

> 💡 This lab continues from the previous deployment-stage lab in this series. Ensure your existing Pipeline YAML is available to extend, and that you're logged in via `oc login` with the `tkn` CLI configured before proceeding.

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **PipelineResource** | A declared external dependency (e.g., Git repo, image registry) a pipeline consumes |
| **Git PipelineResource** | A resource type configuring a Git repository as a pipeline input |
| **Image PipelineResource** | A resource type configuring a container image registry destination |
| **Resource-Backed Task** | A Task written to consume a defined PipelineResource for its operations |
| **External Dependency Integration** | Coordinating multiple external systems (repos, registries) within one pipeline |
| **Resource Troubleshooting** | Diagnosing and resolving issues with resource configuration or connectivity |

---

## 🏁 Conclusion

In this lab, you have successfully:

- 🔌 **Defined PipelineResources** for both Git repositories and image registries, learning how to configure external dependencies in Tekton pipelines
- 🛠️ **Created and configured tasks** that utilize these resources to perform real-world operations like source code cloning and image building
- 🔗 **Built a complete CI/CD pipeline** that integrates multiple resources and tasks in a coordinated workflow
- ✅ **Tested resource integration** through multiple pipeline runs, validating that external dependencies work correctly
- 🩺 **Troubleshot common issues** and learned best practices for managing pipeline resources

### 💡 Why This Matters

PipelineResources are fundamental to creating robust CI/CD pipelines that interact with external systems. By mastering resource management, you can build pipelines that automatically pull source code from Git repositories, push built images to registries, and integrate with various external services. This knowledge is essential for implementing production-ready DevOps workflows in cloud-native environments.

The skills you've developed in this lab directly apply to real-world scenarios where applications need to be automatically built, tested, and deployed from source code repositories to container registries, forming the backbone of modern software delivery practices.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
