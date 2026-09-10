<div align="center">

# 🚀 Building a Self-Contained Multi-Environment CI/CD Pipeline

![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

</div>

## 📖 Table of Contents

- [📋 Overview](#-overview)
- [🎯 Key Accomplishments](#-key-accomplishments)
- [🧠 Key Concepts](#-key-concepts)
- [🌍 Real-World Applications](#-real-world-applications)
- [🔭 Next Steps](#-next-steps)

---

## 📋 Overview

This lab walked through building a self-contained **multi-environment CI/CD project** from the ground up — spanning environment-aware application structure, Kubernetes manifests, parameterized automation scripts, and a GitHub Actions pipeline that enforces a safe promotion order across **dev → staging → production**.

---

## 🎯 Key Accomplishments

- 🗂️ **Environment-separated directory structure** — configuration and manifests cleanly split across `dev`, `staging`, and `production`
- 🩺 **Node.js application with a health endpoint** — used as the deployable workload and the basis for automated verification
- ⚙️ **Environment-specific Kubernetes resources** — ConfigMaps, Deployments, and Services tuned per environment, with appropriately scaled resource limits and replica counts
- 📜 **Parameterized shell scripts** — a single set of build, deploy, and test scripts that target any environment without duplicating logic
- 🔁 **Validated GitHub Actions workflow** — enforces a realistic promotion order, only advancing a build to staging and production after it succeeds in the preceding stage

### 🧭 Core Discipline Practiced

> Through this process, two principles anchored the design of safe multi-environment delivery:
> 1. **Keep environment differences isolated in configuration, not in code.**
> 2. **Gate promotion on automated verification at each stage.**

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| Multi-Environment Directory Structure | Separating configuration and manifests per environment to avoid environment-specific code branches |
| ConfigMap | Kubernetes object used to externalize environment-specific configuration from application code |
| Kubernetes Deployment | Manages the desired state and replica count of the application per environment |
| Kubernetes Service | Exposes the application within the cluster, scoped per environment |
| Parameterized Shell Script | A single reusable script (build/deploy/test) driven by a target-environment parameter, avoiding logic duplication |
| Health Endpoint | Application route used to verify successful deployment before promotion |
| CI/CD Promotion Pipeline | GitHub Actions workflow that gates advancement to the next environment on the success of the previous stage |
| Configuration Isolation | Design principle of pushing environment differences into config rather than conditional code paths |

---

## 🌍 Real-World Applications

This promotion-gated, configuration-isolated pattern mirrors how production teams actually ship software safely: builds move through progressively higher-stakes environments, each stage acting as a checkpoint that must pass before the next is even attempted — reducing the risk of a broken or misconfigured release reaching production.

---

## 🔭 Next Steps

To extend this pipeline further, consider:

- 🔐 **Real secrets management** — e.g., OpenShift Secrets or a HashiCorp Vault integration
- ⏪ **Automated rollback triggers** — based on failed health checks
- ✅ **Manual approval gates** — required before production deployment

---

<div align="center">

**Made with ❤️ for Al Nafi Learners**

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Training-blue?style=for-the-badge)

</div>
