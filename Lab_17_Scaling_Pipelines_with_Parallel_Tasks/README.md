<div align="center">

# ⚡ Sequential vs. Parallel Tekton Pipelines with Conditional Branching

![Tekton](https://img.shields.io/badge/Tekton-FD495C?style=for-the-badge&logo=tekton&logoColor=white)
![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Performance-blue?style=for-the-badge&logo=githubactions&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

</div>

---

## 📑 Table of Contents

- [📖 Overview](#-overview)
- [📝 Lab Summary](#-lab-summary)
- [🎯 Key Takeaway](#-key-takeaway)
- [🔑 Key Concepts](#-key-concepts)

---

## 📖 Overview

In this lab, you built and compared sequential and parallel Tekton pipelines to measure — not just observe — the real performance impact of parallelization, using conditional `when` expressions to control which branches run.

---

## 📝 Lab Summary

You built and compared sequential and parallel Tekton pipelines using identical custom tasks, then used `when` expressions to make specific parallel branches conditional on pipeline parameters.

Rather than relying on visual inspection of logs, you wrote scripts that pull real TaskRun timestamps from the cluster to prove that tasks overlapped in execution and to quantify the resulting time savings compared to the sequential baseline.

---

## 🎯 Key Takeaway

Parallelization in CI/CD pipelines reduces total execution time by shortening the critical path to the longest concurrent task rather than the sum of all tasks — but this benefit depends on sufficient cluster resources to schedule concurrent pods, and on carefully designed `when` conditions so that conditional branches skip cleanly without breaking downstream task dependencies.

---

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| **Sequential Pipeline** | A pipeline where tasks run one after another, with total time equal to the sum of all task durations |
| **Parallel Pipeline** | A pipeline where independent tasks run concurrently, reducing total execution time |
| **`when` Expression** | A Tekton construct that conditionally includes or skips a task/branch based on pipeline parameters |
| **Conditional Branch** | A pipeline path that only executes when its `when` condition is met |
| **TaskRun Timestamp** | Cluster-recorded start/end times for a task execution, used to empirically verify overlap |
| **Critical Path** | The longest chain of dependent tasks that determines a pipeline's minimum possible runtime |
| **Cluster Resource Contention** | The constraint where insufficient CPU/memory limits how many pods can be scheduled concurrently |

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-orange?style=for-the-badge)

</div>
