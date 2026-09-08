<div align="center">

# 🧪 Lab 8: Adding a Test Stage to a Pipeline

![Tekton](https://img.shields.io/badge/Tekton-CI%2FCD-2091FF?style=for-the-badge&logo=tekton&logoColor=white)
![OpenShift](https://img.shields.io/badge/OpenShift-Red%20Hat-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Testing](https://img.shields.io/badge/Testing-Quality%20Gates-brightgreen?style=for-the-badge)
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

This lab adds a testing stage to your existing pipeline, sitting between build and deployment. You'll build a test Task covering both unit and integration tests, wire it into the pipeline so it runs automatically after the build stage, and implement a quality gate that stops the pipeline when tests fail — keeping untested code from ever reaching production.

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Create a comprehensive test task covering both unit and integration tests |
| 2 | Modify an existing pipeline to run automated testing after the build stage |
| 3 | Implement a quality gate that halts the pipeline when tests fail |
| 4 | Apply industry-standard practices for structuring test stages in cloud-native pipelines |

## ✅ Prerequisites

| Requirement | Details |
|---|---|
| 🔧 OpenShift Pipelines Operator | Installed and verified (prior lab) |
| 💻 tkn CLI | Installed and configured (prior lab) |
| 📄 Working Tekton Pipeline | A webhook-triggered build/deploy pipeline, as built in the previous lab |
| ☸️ oc CLI | Installed and authenticated to your cluster |
| 🔄 CI/CD Basics | Understanding of build → test → deploy pipeline concepts |

## 🛠️ Lab Environment

> 💡 This lab continues from the previous GitHub-webhooks lab in this series. Ensure your existing Pipeline YAML is available to extend, and that you're logged in via `oc login` with the `tkn` CLI configured before proceeding.

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Test Task** | A Tekton Task dedicated to running application tests within the pipeline |
| **Unit Testing** | Validating individual components or functions in isolation |
| **Integration Testing** | Validating that combined components work correctly together |
| **Pipeline Orchestration** | Sequencing build, test, and deploy stages so each depends on the last succeeding |
| **Quality Gate** | A pipeline checkpoint that halts progression when a stage (e.g., tests) fails |
| **Test-then-Deploy Pattern** | Ensuring only successfully tested code proceeds to deployment |

---

## 🏁 Conclusion

Congratulations! You have successfully completed **Lab 8: Adding a Test Stage to a Pipeline**. In this lab, you accomplished several important objectives:

### 📖 What You Learned

- 🧪 **Test Integration** — you created a comprehensive test task that includes both unit and integration tests, demonstrating how to validate application functionality within a CI/CD pipeline
- 🔀 **Pipeline Orchestration** — you modified an existing pipeline to include automated testing after the build stage, ensuring that only tested code proceeds to deployment
- 🚦 **Quality Gates** — you implemented a quality gate mechanism where the pipeline stops if tests fail, preventing faulty code from reaching production
- 📋 **Best Practices** — you learned industry-standard practices for structuring test stages in cloud-native application pipelines

### 💡 Why This Matters

Testing is a critical component of modern DevOps practices. By integrating automated tests into your pipeline, you ensure that:

- Code quality is maintained throughout the development lifecycle
- Bugs are caught early in the process, reducing costs and time to fix
- Deployments are more reliable and stable
- Teams can move faster with confidence in their releases

### 🌍 Real-World Applications

The skills you've developed in this lab are directly applicable to enterprise environments where:

- Multiple developers contribute to the same codebase
- Applications must meet strict quality and reliability standards
- Automated testing reduces manual effort and human error
- Continuous integration and deployment are essential for competitive advantage

You now have the knowledge to implement robust testing strategies in your own CI/CD pipelines, making you a more valuable contributor to any development team working with cloud-native applications and OpenShift environments.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-blueviolet?style=for-the-badge)

</div>
