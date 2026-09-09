<div align="center">

# 🔄 Automated Rollback and Blue-Green Deployment for Containerized Applications

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Pipeline-blue?style=for-the-badge&logo=githubactions&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-Deployment%20Strategy-informational?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [📖 Overview](#-overview)
- [📝 Lab Summary](#-lab-summary)
- [🛠️ Key Skills Practiced](#️-key-skills-practiced)
- [🌍 Real-World Applications](#-real-world-applications)
- [🔑 Key Concepts](#-key-concepts)

---

## 📖 Overview

In this lab, you built a complete rollback workflow for a containerized application, then extended it into a blue-green deployment model — two of the core safety patterns behind reliable, zero-downtime CI/CD systems.

---

## 📝 Lab Summary

You started with a simple deploy script that validates each new version with a health check before accepting it, paired with a rollback script that automatically reverts to the last successful version when a deployment fails. Wiring these into a pipeline script, you observed a failed deployment trigger an automatic rollback end to end, verified through both log output and live application responses.

Extending this into a blue-green deployment model showed how maintaining two parallel environments and only switching traffic after a health check passes allows rollback to become a near-instant pointer change rather than a disruptive container replacement.

---

## 🛠️ Key Skills Practiced

- **Health-Gated Deployment** — accepting a new version only after it passes an automated health check
- **Automatic Rollback on Failure** — detecting a failed deployment and reverting to the last known-good version without manual intervention
- **Traffic-Switching for Zero Downtime** — using a blue-green model to make rollback a near-instant pointer change instead of a disruptive container replacement

---

## 🌍 Real-World Applications

These patterns are directly applicable to real-world CI/CD systems and form a foundation for safely deploying software changes.

---

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| **Health Check** | An automated probe that verifies a newly deployed version is functioning correctly before it's accepted |
| **Deploy Script** | Automation that ships a new version and gates its acceptance on a passing health check |
| **Rollback Script** | Automation that automatically reverts to the last successful version when a deployment fails |
| **Pipeline Script** | The orchestration layer wiring deploy and rollback logic into a single end-to-end workflow |
| **Blue-Green Deployment** | A model that keeps two parallel environments running, only routing traffic to the new one after it's verified healthy |
| **Traffic Switching** | Redirecting live traffic between environments via a pointer/routing change rather than replacing running containers |
| **Zero-Downtime Deployment** | A deployment approach where users experience no service interruption during releases or rollbacks |

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-orange?style=for-the-badge)

</div>
