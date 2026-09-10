<div align="center">

# 🐞 Lab 19: Debugging and Troubleshooting Tekton Pipelines

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Tekton](https://img.shields.io/badge/Tekton-FD495C?style=for-the-badge&logo=tekton&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-tkn_%2F_oc-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

</div>

## 📖 Table of Contents

- [📋 Lab Summary](#-lab-summary)
- [🔁 Key Debugging Workflow](#-key-debugging-workflow)
- [🧠 Key Concepts](#-key-concepts)
- [🔭 Next Steps](#-next-steps)

---

## 📋 Lab Summary

This lab centered on diagnosing and fixing a real Tekton pipeline failure end to end. A **deliberately failing Tekton pipeline** was built, and `tkn pipelinerun describe`, `tkn taskrun logs`, and `oc logs` / `oc describe pod` were used together to isolate **two distinct root causes**. Tekton's built-in retry mechanism was then verified using `retriesStatus`, before a **self-healing task** was implemented. An improved pipeline — combining retries, cleanup, and a `finally` notification block — was assembled and proven by rerunning it to a fully `Succeeded` state.

---

## 🔁 Key Debugging Workflow

> The core takeaway is a **repeatable debugging workflow** that applies to any production Tekton pipeline failure:
>
> 1. **Start broad** — `tkn pipelinerun describe` to get the overall picture
> 2. **Narrow down** — identify the specific failing `TaskRun`
> 3. **Confirm** — inspect container-level detail with `oc logs`
> 4. **Fix** — apply a targeted fix based on the confirmed root cause
> 5. **Validate** — rerun the pipeline to confirm a `Succeeded` state

---

## 🧠 Key Concepts

| Concept | Description |
|---|---|
| `tkn pipelinerun describe` | High-level diagnostic entry point for inspecting an overall PipelineRun's status |
| `tkn taskrun logs` | Retrieves logs scoped to a specific failing TaskRun |
| `oc logs` / `oc describe pod` | Container-level diagnostics used to confirm the exact root cause of a failure |
| Root Cause Isolation | Narrowing from pipeline-level to task-level to container-level to pinpoint distinct failure causes |
| Retry Mechanism (`retriesStatus`) | Tekton's built-in ability to automatically retry a failed Task and track retry history |
| Self-Healing Task | A task designed to recover from failure conditions automatically |
| `finally` Notification Block | Pipeline section that runs regardless of success/failure, used here for notifications |
| Succeeded State | The verified end state confirming a fix resolved the pipeline failure |

---

## 🔭 Next Steps

- 🔀 **Tekton Triggers** — event-driven pipeline execution
- 🔗 **Tekton Chains** — supply-chain security
- 📊 **Tekton Results** — long-term pipeline run history and auditing

---

<div align="center">

**Made with ❤️ for Al Nafi Learners**

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Training-blue?style=for-the-badge)

</div>
