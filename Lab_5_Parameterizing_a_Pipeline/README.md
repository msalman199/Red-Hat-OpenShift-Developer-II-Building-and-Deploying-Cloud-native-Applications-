<div align="center">

# ⚙️ Parameterizing Tekton Pipelines

![Tekton](https://img.shields.io/badge/Tekton-CI%2FCD-2091FF?style=for-the-badge&logo=tekton&logoColor=white)
![OpenShift](https://img.shields.io/badge/OpenShift-Red%20Hat-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![tkn CLI](https://img.shields.io/badge/tkn-CLI-FF8C00?style=for-the-badge)
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

Building on the pipeline you created and triggered in the previous lab, this lab focuses on making that pipeline reusable across environments and applications. You'll add configurable parameters for image tags, repository URLs, and deployment configurations, then run the pipeline with custom values through both YAML manifests and the `tkn` CLI — validating along the way that your parameters behave correctly and safely.

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Parameterize a Tekton pipeline with configurable inputs for image tags, repository URLs, and deployment configurations |
| 2 | Modify pipeline definitions to accept dynamic input values while maintaining sensible default fallbacks |
| 3 | Execute pipelines with custom parameters via YAML manifests |
| 4 | Execute pipelines with custom parameters via `tkn` CLI commands |
| 5 | Validate parameter usage by examining PipelineRuns and confirming custom values were correctly applied |
| 6 | Implement parameter validation to ensure data integrity and prevent common configuration errors |

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🔧 OpenShift Pipelines Operator | Installed and verified (prior lab) |
| 💻 tkn CLI | Installed and configured (prior lab) |
| 📄 Working Tekton Pipeline | A pipeline YAML with a build Task, as created in the previous lab |
| ☸️ oc CLI | Installed and authenticated to your cluster |
| 🔄 CI/CD Basics | Understanding of build → deploy pipeline concepts |

## 🛠️ Lab Environment

> 💡 This lab continues from the previous pipeline-creation lab in this series. Ensure the Pipeline YAML you built earlier is available to edit, and that you're logged in via `oc login` with the `tkn` CLI configured before proceeding.

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Pipeline Parameter** | A named, typed input a Pipeline or Task accepts at runtime |
| **Default Value** | A fallback value used when a parameter isn't explicitly supplied |
| **Dynamic Input** | Runtime-supplied values (image tag, repo URL, deployment config) that vary per run |
| **PipelineRun (YAML)** | Declarative execution of a parameterized Pipeline via a manifest |
| **tkn CLI Parameter Flags** | Command-line flags for passing custom parameter values at trigger time |
| **Parameter Validation** | Checks that ensure supplied parameter values are well-formed and safe to use |

---

## 🏁 Conclusion

In this lab, you have successfully:

- ⚙️ **Parameterized a Tekton pipeline** by adding configurable parameters for image tags, repository URLs, and deployment configurations
- 🔄 **Modified pipeline definitions** to accept dynamic input values while maintaining default fallbacks
- ▶️ **Executed pipelines with custom parameters** using both YAML manifests and CLI commands
- ✅ **Validated parameter usage** by examining pipeline runs and verifying that custom values were correctly applied
- 🛡️ **Implemented parameter validation** to ensure data integrity and prevent common configuration errors

### 💡 Why This Matters

Pipeline parameterization is crucial for creating reusable, flexible CI/CD workflows. Instead of maintaining multiple similar pipelines for different environments or applications, you can use a single parameterized pipeline that adapts to various scenarios. This approach reduces maintenance overhead, improves consistency, and enables teams to standardize their deployment processes while maintaining the flexibility to customize behavior when needed.

The skills you've learned enable you to build production-ready pipelines that can handle multiple environments, different application versions, and varying deployment requirements — all essential capabilities for modern DevOps practices in enterprise environments.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
