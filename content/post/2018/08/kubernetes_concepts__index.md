---
title: 'kubernetes 概念'
slug: kubernetes_concepts__index
date: 2018-08-27
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
  - concepts
keywords:
  - kubernetes
  - concepts
---

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/

这篇文章能帮助你了解 Kubernetes 系统的各个部分以及 Kubernetes 对集群的抽象，并帮助你更深入地了解 Kubernetes 的工作原理。

<!--more-->

## 概述

使用 Kubernetes，你只需要使用 Kubernetes API 对象描述集群的期望状态：你想要运行的应用程序或其他工作负载，他们使用的容器镜像，副本数量，你想要提供的网络和磁盘资源，或者更多其他的信息。你可以通过使用 Kubernetes API 创建对象来设置集群的期望状态，通常可以使用命令行接口 -- kubectl。你也可以直接使用 Kubernetes API 与集群交互，并设置或修改集群的期望状态。

一旦你设置了集群的期望状态，Kubernetes 控制平台就会工作，使集群的当前状态接近期望状态。为此，Kubernetes 会自动执行各种任务，例如启动或重启容器，缩放给定应用程序的副本数量等。Kubernetes 控制平台由一组在集群上运行的进程组成：

- **Kubernetes Master** 是在集群中运行在单个节点上的三个进程的集合，它被设计成主节点。这些进程包括：[kube-apiserver](https://v1-11.docs.kubernetes.io/docs/admin/kube-apiserver/)、[kube-controller-manager](https://v1-11.docs.kubernetes.io/docs/admin/kube-controller-manager/) 和 [kube-scheduler](https://v1-11.docs.kubernetes.io/docs/admin/kube-scheduler/)。
- 集群中每个非主节点都运行两个进程：
  - [kubelet](https://v1-11.docs.kubernetes.io/docs/admin/kubelet/) -- 和 Kubernetes Master 进行通讯
  - [kube-proxy](https://v1-11.docs.kubernetes.io/docs/admin/kube-proxy/) -- 一个反映每个节点上的 Kubernetes 网络服务的网络代理

## Kubernetes 对象

Kubernetes 包含许多代表系统状态的抽象：部署的容器化的应用程序和工作负载、相关的网络和磁盘资源以及集群运行相关的其他信息。这些抽象由 Kubernetes API 中的对象表示，有关详情请参考 -- [Kubernetes Objects overview](https://v1-11.docs.kubernetes.io/docs/concepts/abstractions/overview/)

Kubernetes 基础对象包括：

- [Pod](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
- [Service](https://v1-11.docs.kubernetes.io/docs/concepts/services-networking/service/)
- [Volume](https://v1-11.docs.kubernetes.io/docs/concepts/storage/volumes/)
- [Namespace](https://v1-11.docs.kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

此外，Kubernetes 包含许多称为控制器的高级抽象。控制器基于基本对象构建，并提供了其他功能和便利功能。他们包括：

- [ReplicaSet](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [Deployment](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [StatefulSet](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [DaemonSet](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Job](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)

## Kubernetes 控制平台

Kubernetes 控制平台的各个部分，如 Kubernetes Master 和 kubelet 进程，管理 Kubernetes 如何与集群通信。控制平台维护系统中所有 Kubernetes 对象的记录，并运行连续的控制循环来管理这些对象的状态。在任何给定的时间，控制平台的控制循环将响应集群中的改变并努力使系统中所有的对象和你提供的期望状态相匹配。

例如，当你使用 Kubernetes API 创建 Deployment 对象时，你提供一个新的期望状态给系统。Kubernetes 控制平台记录对对象的创建，并通过启动所需的应用程序和将它们调度到集群节点上来执行你的指令 -- 从而使集群的实际状态与期望状态相匹配。

### Kubernetes Master

Kubernetes 主节点负责维护集群的期望状态。当你与 Kubernetes 交互时，使用 kubectl 命令行接口，你将与集群的 Kubernetes 主节点进行通信。

"master" 指的是管理集群状态的进程集合。通常，这些进程都运行在集群中的单个节点上，并且这个节点也就被称为主节点。主节点也可以存在多个，以获取可用性和冗余性。

### Kubernetes Nodes

集群中的节点是运行应用程序和云工作流的机器（可以是虚拟机、物理服务器等）。Kubernetes 主节点控制每个节点，你很少直接与节点交互。
