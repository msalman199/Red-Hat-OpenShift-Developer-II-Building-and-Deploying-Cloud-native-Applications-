<div align="center">

# 🚀 Creating and Triggering Tekton Pipelines with the tkn CLI

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

This lab builds directly on your OpenShift Pipelines Operator installation and `tkn` CLI setup, taking you into hands-on pipeline authoring and execution. You'll construct a complete Tekton Pipeline YAML definition, trigger it through several different `tkn`-driven approaches, and practice the monitoring and troubleshooting workflow every pipeline operator relies on in production.

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Author a complete Tekton Pipeline YAML with a build Task, including proper parameter handling |
| 2 | Configure Pipeline workspaces correctly for task data sharing |
| 3 | Trigger pipelines using multiple `tkn` CLI methods, including interactive mode |
| 4 | Trigger pipelines via YAML-based PipelineRun definitions |
| 5 | Monitor pipeline execution using real-time log streaming |
| 6 | Check pipeline status and diagnose failed executions |
| 7 | Apply best practices for pipeline organization, parameter management, and workspace utilization |

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🔧 OpenShift Pipelines Operator | Installed and verified (prior lab) |
| 💻 tkn CLI | Installed and configured (prior lab) |
| ☸️ oc CLI | Installed and authenticated to your cluster |
| 📄 YAML Familiarity | Comfortable reading/writing basic YAML |
| 🔄 CI/CD Basics | Understanding of build → deploy pipeline concepts |

## 🛠️ Lab Environment

> 💡 This lab assumes an OpenShift cluster with the **OpenShift Pipelines Operator** already installed and the **`tkn` CLI** already configured on your workstation, continuing on from the previous labs in this series. Ensure you're logged in via `oc login` and have a project/namespace selected before proceeding.

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Tekton Pipeline** | A YAML-defined sequence of Tasks that make up a CI/CD workflow |
| **Task** | A reusable unit of work (e.g., a build step) within a Pipeline |
| **PipelineRun** | An execution instance of a Pipeline, definable via YAML |
| **tkn CLI** | Command-line tool for creating, triggering, and inspecting Tekton resources |
| **Interactive Mode** | A `tkn` prompt-driven flow for starting pipelines without hand-writing a PipelineRun |
| **Workspace** | Shared storage Tekton Tasks use to pass data between pipeline steps |
| **Parameter** | Configurable input passed into a Pipeline or Task at runtime |
| **Log Streaming** | Real-time output of a running PipelineRun's Task logs via `tkn` |

---

## 🏁 Conclusion

In this lab, you have successfully:

- 🛠️ **Created a comprehensive pipeline YAML** that includes a build task with proper parameter handling and workspace configuration
- ⚡ **Learned multiple methods to trigger pipelines** using the `tkn` CLI tool, including interactive mode and YAML-based pipeline runs
- 📊 **Mastered pipeline monitoring techniques** through real-time log streaming, status checking, and troubleshooting failed executions
- ✅ **Implemented best practices** for pipeline organization, parameter management, and workspace utilization

### 💡 Why This Matters

Understanding how to define and execute Tekton pipelines is fundamental to implementing CI/CD workflows in cloud-native environments. These skills enable you to automate build, test, and deployment processes, making your development workflow more efficient and reliable. The monitoring and troubleshooting techniques you've learned are essential for maintaining robust pipeline operations in production environments.

### 🚀 Next Steps

With this foundation, you're ready to explore more advanced pipeline concepts such as conditional execution, parallel tasks, pipeline triggers, and integration with external systems. These skills directly support the **Red Hat OpenShift Developer II** certification objectives and prepare you for real-world cloud-native application development scenarios.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
