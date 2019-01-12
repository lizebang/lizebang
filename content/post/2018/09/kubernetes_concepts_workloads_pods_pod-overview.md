---
title: 'Kubernetes Pod 概述'
slug: kubernetes_concepts_workloads_pods_pod-overview
date: 2018-09-10
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

原文：https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/

本文概述了 Pod，它是 Kubernetes 对象模型中最小可部署对象。

<!--more-->

## 理解 Pod

Pod 是 Kubernetes 最基本的构建块 -- 在 Kubernetes 对象模型中可以创建或部署的最小、最简单的单元。一个 Pod 代表一个运行在集群里的进程。

一个 Pod 封装了一个应用容器（多数情况下是多个容器）、存储资源、唯一的网络 IP 以及控制容器应该如何运行的选项。一个 Pod 代表一个部署单元：Kubernetes 中的应用程序单个实例，它可能包含单个容器或少量紧密耦合且共享资源的容器。

[docker](https://www.docker.com/) 是 Kubernetes Pod 最常用的容器运行时环境，但是 Pod 也支持其他容器运行时环境。

Kubernetes 集群中的 Pod 有以下两种主要的使用方式：

- **Pod 运行单个容器** "one-container-per-Pod" 模式是 Kubernetes 最常见的使用场景。在这种情况下，你可以把 Pod 视为单个容器的包装器，并且 Kubernetes 管理容器而不是直接管理容器。

- **Pod 运行需要协同工作的多个容器** Pod 封装了一个由多个紧耦合、共享资源、协同寻址的容器组成的应用程序。这些共同寻址的容器可能来自一组粘合性很强的服务 -- 一个容器从共享卷对外提供文件的同时，一个单独的 "sidecar" 容器刷新、更新这些文件。Pod 将这些容器和存储资源作为一个管理实体包装在一起。

[Kubernetes Blog](http://kubernetes.io/blog)

- [分布式系统工具箱：混合容器模式](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html)
- [容器设计模式](https://kubernetes.io/blog/2016/06/container-design-patterns)

每个 Pod 都用于运行给定应用程序的单个实例。如果你想水平扩展应用（例如，运行多个实例），你应该使用多个 Pod，每个 Pod 对应一个实例。在 Kubernetes 中，这通常被称为 **replication**。复制的 Pod 通常是由一个被称为 Controller 的抽象创建和管理。更多信息请参考 [Pods 和 Controllers](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pods-and-controllers)

### Pod 如何管理多个容器

Pod 被设计成支持多个相互协作的进程（例如容器）构成一个高粘合性的服务。Pod 中的容器能在集群里的物理或虚拟机上自动地协同寻址、协同调度。容器之间能够共享资源和依赖，能彼此通信，还能协调它们何时以及如何终止。

请注意，将多个协同寻址和协同管理的容器放到一个单独的 Pod 中是一种相对高级的用法。应该仅在容器紧耦合的特定实例中所以这种模式。例如，你可能有一个容器从共享卷对外提供文件的同时，还有一个单独的 "sidecar" 容器刷新、更新这些文件，如下图所示：

![Pod diagram](/images/2018/08/pod.svg)

Pod 为组成它的容器提供两种共享资源：**网络** 和 **存储**。

#### 网络

每个 Pod 都被分配了一个唯一的 IP 地址。Pod 中的所有容器共享一个网络空间，这个网络空间包含了 IP 地址和网络端口。**Pod 内部** 的容器可以使用 `localhost` 相互通讯。但当 Pod 里的容器需要与 **Pod 以外** 的实体进行通讯时，就必须协调它们使用共享网络资源（例如端口）。

#### 存储

Pod 可以指定一系列共享存储 **卷**。Pad 中的所有容器都可以访问共享卷，也可以使用这个共享卷来分享数据。如果 Pod 中的容器需要重新启动，则卷还允许 Pod 中的持久数据保留下来。更多有关 Kubernetes 怎样在 Pod 中实现共享存储。

## 使用 Pod

在 Kubernetes 中，很少直接创建单独的 Pod -- 就算在只有一个 Pod 的场景也是这样。这是因为 Pod 被设计为相对短暂的一次性实体。当 Pod 被创建时（由你直接创建或由 Controller 间接创建），它都被调度到集群中的节点运行。除非 Pod 进程被终止，Pod 对象被删除，由于缺少资源、节点失败等原因 Pod 被驱逐，Pod 将一直存在这个节点上。

> 注意：在 Pod 中重启容器不应该与重启 Pod 混淆。Pod 本身不会运行，但是它是容器运行的环境并且它一直存在直到被删除。

Pod 本身不能自我修复。如果一个 Pod 调度到一个失败的节点上，或调度操作本身失败了，这个 Pod 就会被删除。同样地，由于缺乏资源或节点维护，Pod 将被驱逐删除。Kubernetes 使用了一种被称为 Controller 的高级抽象来管理相对短暂的 Pod 实例。因此，尽管可以直接使用 Pod，但在 Kubernetes 中使用 Controller 管理 Pod 要常见得多。更多有关 Kubernetes 任何使用 Controller 实现 Pod 的缩放和自我恢复请查看 [Pods 和 Controllers](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pods-and-controllers)

### Pods 和 Controllers

Controller 可以为你创建和管理多个 Pod，也提供复制、部署，以及在集群范围内的自我恢复的功能。例如，如果一个节点失败，Controller 可能会通过在其他节点上调度一个相同的 Pod 来自动取代当前的 Pod。

下面这些是 Controller 里包含一个或多个 Pod：

- [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

通常来说，Controller 使用你提供的 Pod 模板来创建它负责的 Pod。

## Pod 模版

Pod 模版是包含其他对象的 Pod 规范，例如，[Replication Controllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)、[Jobs](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/) 和 [DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)。Controllers 使用 Pod 模版生成 Pod。下面是一个简单的示例，一个 Pod 包含一个打印消息的容器。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
    - name: myapp-container
      image: busybox
      command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```

与指定当前理想状态副本的方式相比，Pod 模版更像一个饼干模具。一旦饼干出炉就与模具没有任何关系。模版和实例之间不会互相纠缠。随后对模版上的改动，或者使用新模版都不会对已创建成功的 Pod 产生影响。类似的，通过 replication controller 创建的 Pod 在随后可以直接更新。这与 Pod 对比，它也指明了属于 Pod 的所有容器当前期望的状态。这种方法从根本上简化了系统语义并增加了灵活性。
