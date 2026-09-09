<div align="center">

# 🚢 Adding an Automated Deployment Stage to a Pipeline

![Tekton](https://img.shields.io/badge/Tekton-CI%2FCD-2091FF?style=for-the-badge&logo=tekton&logoColor=white)
![OpenShift](https://img.shields.io/badge/OpenShift-Red%20Hat-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-Automated%20Delivery-success?style=for-the-badge)
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

This lab completes your pipeline by adding the deployment stage — the final step after source fetching, building, and testing. You'll build a custom deployment task that handles OpenShift-specific resources (Deployments, Services, and Routes), add monitoring and logging so you can track pipeline execution and troubleshoot issues, and validate the deployed application through both HTTP testing and direct resource inspection.

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Build a comprehensive deployment pipeline that integrates source fetching, image building, and application deployment into one automated workflow |
| 2 | Develop a custom deployment task handling OpenShift-specific requirements — Deployments, Services, and Routes |
| 3 | Implement monitoring and logging practices to track pipeline execution and troubleshoot deployment issues |
| 4 | Verify application deployment through multiple validation methods, including HTTP testing and resource inspection |

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🔧 OpenShift Pipelines Operator | Installed and verified (prior lab) |
| 💻 tkn CLI | Installed and configured (prior lab) |
| 📄 Working Tekton Pipeline | A pipeline with build and test stages, as built in the previous lab |
| ☸️ oc CLI | Installed and authenticated to your cluster |
| 🔄 CI/CD Basics | Understanding of build → test → deploy pipeline concepts |

## 🛠️ Lab Environment

> 💡 This lab continues from the previous test-stage lab in this series. Ensure your existing Pipeline YAML is available to extend, and that you're logged in via `oc login` with the `tkn` CLI configured before proceeding.

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Deployment Task** | A custom Tekton Task that applies OpenShift Deployment, Service, and Route resources |
| **OpenShift Route** | The resource exposing a Service externally via a URL |
| **Pipeline Monitoring & Logging** | Tracking pipeline execution and capturing logs for troubleshooting |
| **HTTP-Based Validation** | Confirming a deployed application responds correctly over HTTP |
| **Resource Inspection** | Directly checking OpenShift resources (Deployments, Pods, Services) to confirm state |
| **GitOps/CI-CD Automation** | End-to-end automated delivery from source code to running application |

---

## 🏁 Conclusion

In this lab, you have successfully:

- 🔗 **Created a comprehensive deployment pipeline** that integrates source code fetching, image building, and application deployment into a single automated workflow
- 🛠️ **Developed a custom deployment task** that handles OpenShift-specific deployment requirements including Deployments, Services, and Routes
- 📊 **Implemented monitoring and logging practices** to track pipeline execution and troubleshoot deployment issues
- ✅ **Verified application deployment** through multiple validation methods including HTTP testing and resource inspection

### 💡 Why This Matters

This lab demonstrates the power of GitOps and CI/CD practices in modern cloud-native development. By automating the deployment process through OpenShift Pipelines, you've created a repeatable, reliable, and auditable deployment mechanism that:

- Reduces manual errors and deployment inconsistencies
- Enables rapid iteration and continuous delivery
- Provides clear visibility into the deployment process
- Supports rollback and recovery procedures
- Integrates security and compliance checks into the deployment workflow

The skills you've developed here are essential for DevOps engineers and developers working with containerized applications in enterprise environments. OpenShift Pipelines, built on Tekton, provides a Kubernetes-native CI/CD solution that scales with your organization's needs while maintaining the flexibility to customize deployment processes for specific application requirements.

These automated deployment capabilities form the foundation for more advanced practices like blue-green deployments, canary releases, and multi-environment promotion strategies that are crucial for production-ready applications.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
