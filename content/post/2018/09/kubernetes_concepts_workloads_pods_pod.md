---
title: 'Kubernetes Pods'
slug: kubernetes_concepts_workloads_pods_pod
date: 2018-09-12
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

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/pod/

Pod 是 Kubernetes 中可以被创建和管理的最小部署计算单元。

<!--more-->

## 什么是 Pod

Pod（就像鲸群或者豌豆荚一样）是一组共享存储、网络以及指明运行方式的容器（例如 docker 容器）。一个 Pod 的内容总是协同寻址，协同调度的，并在共享的上下文中运行。Pod 为应用程序模拟了专用的逻辑主机 -- 它包含一个或多个相互紧密联系的应用程序镜像 -- 在没有容器技术之前，它们将在相同物理或虚拟机上执行。

虽然 Kubernetes 支持除 docker 外的其他容器运行时环境，但是 docker 是最广为人知的运行时环境，所以使用 docker 术语来描述 Pod 有助于理解。

Pod 共享的上下文是一系列 Linux namespaces、cgroups 和其他底层的隔离设施 -- 这些技术同样是 docker 容器隔离的基础。在 Pod 的上下文中，各个应用可能具有进一步的子隔离。

Pod 中的容器共享一个 IP 地址和端口空间，并且能通过 `localhost` 找到 Pod 中的其他容器。它们也可以使用标准的进程间通信方式相互交流，例如 SystemV 信号量、POSIX 共享内存。不同 Pod 中的容器由不同的 IP 地址并且在没有 [特殊配置](https://v1-11.docs.kubernetes.io/docs/concepts/policy/pod-security-policy/) 的情况下不能通过进程间通信进行交流。这些容器通常通过 Pod IP 地址相互交流。

Pod 中的应用程序也可以访问共享卷，共享卷被定义为 Pod 的一部分，可以挂载到每个应用程序的文件系统中。

在 [docker](https://www.docker.com/) 的术语中，Pod 被定义为一组共享命名空间和共享 [卷](https://v1-11.docs.kubernetes.io/docs/concepts/storage/volumes/) 的 docker 容器。

就像单独的应用容器，Pod 被认为是相对短暂的（不是持久的）实体。就像在 [Pod 的生命周期](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) 中所讨论的，Pod 被创建，被标记上一个唯一的 ID（UID），并被调度到一个节点上直到被终止（根据重启策略）或被删除。如果一个节点停止运行，在超过期限之后，调度到该节点上的 Pod 就会被删除。一个给定的 Pod（由 UID 定义）不会重新调度到新的节点，它会被相同的 Pod 替代。如果需要，甚至可以使用相同的名称，但是必须使用一个新的 UID（更多细节请看 [replication controller](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)）。

当我们说某个东西具有与 Pod 相同当生命周期，这意味着只要此 Pod（具有此 UID）存在它也就存在，例如卷。如果由于任何原因 Pod 被删除，即使创建了相同的 Pod 代替它，则与这个 Pod 相关的东西也会被销毁再重新创建，例如卷。

![Pod diagram](/images/2018/08/pod.svg)

**一个多容器 Pod 包含了一个文件拉取器和 web 服务器，该服务器使用持久卷作为容器间的共享存储。**

## 使用 Pod 的动机

### 管理

Pod 是一个模式的模型 -- 多个相互协作的进程形成一个紧密结合的服务单元。它们通过提供比其组成的应用集合更高级别的抽象来简化了应用程序的部署和管理。Pod 被用作部署、横向扩展以及复制的单元。对于 Pod 中的容器来说，协同定位（协同调度）、共享生命周期（例如终止）、协调复制、资源共享以及依赖管理都被自动处理了。

#### 资源共享和交流

Pod 内部实现数据共享和相互通信。

Pod 中的应用程序都使用同样的网络命名空间（相同的 IP 和端口空间），并且彼此之间可以使用 `localhost` 进行通讯。因此，Pod 中的应用程序必须协调它们对端口的使用。每个 Pod 在平面共享网络空间中具有 IP 地址，该网络空间与网络中的其他网络计算机和 Pod 完全通讯。

Pod 里的应用容器的主机名被设置为 Pod 的名字，更多细节查看 [网络](https://v1-11.docs.kubernetes.io/docs/concepts/cluster-administration/networking/)。

除了定义在 Pod 中运行的应用容器之外，Pod 还指定了一组共享存储卷。卷使数据能够在容器重启后继续存在，并且可以让数据在 Pod 中的应用程序之间共享。

## Pod 的使用

Pod 可以被用于托管纵向集成的应用栈（例如 LAMP），但是其主要优势是支持协同定位、协同管理复制程序，例如：

- 内容管理系统，文件和数据加载器，本地缓存管理器等。
- 日志和检查点备份，压缩，循环，快照等。
- 数据更改监视器，日志追踪器，日志和监控适配器，活动发布器等。
- 代理，网桥和适配器。
- 控制器，管理器，配置器和更新器。

通常，独立的 Pod 不应该用于运行同一应用程序的多个实例。

关于这部分的详细解释，请参见 [分布式系统工具箱：混合容器模式](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html)。

## 选择的思考

**为什么不在一个（docker）容器里运行多个程序？**

1.透明度。让 Pod 中的容器对框架可见，使得框架能够为这些容器通过服务，例如，进程管理和资源监控。这为用户提供了许多便利。

2.软件依赖的解耦。各个容器可以单独地管理版本，单独地重新构建以及单独地重新部署。Kubernetes 甚至可能有一天支持单个容器对实时更新。

3.使用方便。用户不需要运行自己的进程管理器，担心信号量和退出处理等。

4.效率。由于框架承担更多的责任，因此容器变得更加轻量级。

**为什么不支持基于亲和性的容器协同调度？**

这个方法可以提供协同寻址，但是不能通过 Pod 的大多数好处，例如资源共享、进程间通信、生命周期共享以及简单化的管理。

## Pod 的持久性（Pod 需要提升的方面）

Pod 不应该被视为持久对实体。它们不会在调度故障、节点故障或其他驱逐（例如缺乏资源）或节点维护对情况下存活下来。

通常，用户不需要直接创建 Pod。它们应该总是使用控制器（例如 [Deployments](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/deployment/)），哪怕只需要一个 Pod 时。Controller 提供了集群内部 Pod 自我修复，也提供了 Pod 复制和回滚管理。像 [StatefulSet](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/controllers/statefulset.md) 这样的 Controller 还可以为有状态的 Pod 提供支持。

使用集群 API 作为主要的面向用户的原语在集群调度系统中相对常见，例如 [Borg](https://research.google.com/pubs/pub43438.html)、[Marathon](https://mesosphere.github.io/marathon/docs/rest-api.html)、[Aurora](http://aurora.apache.org/documentation/latest/reference/configuration/#job-schema) 和 [Tupperware](http://www.slideshare.net/Docker/aravindnarayanan-facebook140613153626phpapp02-37588997)。

Pod 作为暴露的单元，有以下好处：

- 调度器和控制器的可拔插
- 支持 Pod 级操作，不需要通过控制器 API 代理。
- 将 Pod 的生命周期从控制器中剥离出来，从而减少相互影响。
- 剥离出控制器和服务 -- 端点控制器只需要监视 Pod。
- 集群级的功能和 kubelet 级的功能组合更加清晰 - kubelet 实际上是 Pod 控制器
- 高可用应用程序。在终止和删除 Pod 前，必须提前生成替代 Pod。例如，在被计划地驱逐或图像预先拉取的情况下。

## Pod 的终止

因为 Pod 代表集群中节点上运行的进程，所以很重要的一件事是，当它们不再被需要时如何优雅地终止 Pod（而不是粗暴地使用 KILL 命令杀死它们以致于没有机会做清理工作）。用户应该能够发起删除请求并且知道进程何时终止，同时也应该确保最终完成删除。当用户请求删除 Pod 时，系统会在 Pod 被强制终止之前记录下预估期限，并将 TERM 信号量发送给每个容器的主进程。预估期限过期之后，KILL 信号量会被发送到这些进程，并从 API 服务器中删除该 Pod。如果 kubelet 或容器管理器在等待结束进程时重启，终止操作将在预估期限内反复重试。

示例流程：

1.用户发送命令删除 Pod，并使用默认预估期限（30s）。

2.在 API 服务器上的 Pod 在其视为 "dead" 的预估期限前随时间更新。

3.在客户端命令中列出 Pod 时，Pod 显示为 "Terminating"。

4.（与 3 同时）当 kubelet 发现 Pod 已经被标记为终止（因为在 2 时已经设置了），它将开始 Pod 关闭进程。

> 1.如果 Pod 定义了一个 [preStop 钩子](https://v1-11.docs.kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-details)，则会在 Pod 内部调用它。如果预估期限过期之后 `preStop` 钩子仍在运行，则调用下面的步骤 2 并在原来当期限上加上一个小的延时（2s）。

> 2.Pod 中的进程被发送 TERM 信号量。

5.（与 3 同时）Pod 将从服务当端点列表中移除，并不再被看作复本控制器运行的 Pod 集的一部分。Pod 会缓慢关闭直到法继续为流量提供服务，同时负载均衡器（如 服务代理）会将 Pod 从循环列表中移除。

6.当预估期限过期，任何仍然在 Pod 中运行的进程都会被 SIGKILL 杀死。

7.kubelet 将通过在 API 服务器上设置预估期限为 0（立即删除）完成删除 Pod 的过程。这时 Pod 从 API 里消失，也不再能被用户看到。

默认情况下，所有删除在 30s 内都是正常的。`kubectl delete` 命令支持 `--grace-period=<seconds>` 选项，这个选项允许用户用指定的值覆盖默认值。值 `0` 会 [强制删除](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/pod/#force-deletion-of-pods) Pod。在 kubectl 版本 >= 1.5，你必须指定额外的标志 `--grace-period=0` 和 `--force` 一起才能执行强制删除。

### 强制删除 Pod

强制删除 Pod 被定义为从集群状态和 etcd 中立刻删除这个 Pod。当强制删除被执行，API 服务器不会等待来自 Pod 所在节点上的 kubelet 的确认信息：该 Pod 已经终止。它会立即从 API 中移除 Pod 以便使用相同的名字创建新的 Pod。在节点上，Pod 被设置成立即终止后，在强行终止前仍会被给予很短的期限。

强制删除可能对某些 Pod 有潜在危险，应该谨慎执行。对于 StatefulSet Pod 的情况，请参考任务文档 [从 StatefulSet 删除 Pod](https://v1-11.docs.kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)。

## Pod 容器的特权模式

从 Kubernetes v1.1 版本开始，Pod 中的任何容器都可以启动特区模式，只需要将容器规约的 `SecurityContext` 指定为 `privileged`。这对于想使用 Linux 功能的容器非常有用，例如操作网络堆栈和访问系备。容器内的进程获得与容器外部进程几乎完全相同的权限。有了特权模式，编写网络和卷插件变得更加容易，因为它们可以作为独立的 Pod 运行，而不需要编译到 kubelet 中去。

如果主节点运行 Kubernetes v1.1 或更高版本，但是其他节点上运行的版本低于 v1.1。虽然 API 服务器会接受新的特权 Pod，但是这些 Pod 却无法正常运行起来。它们将一直处于 `pending` 状态。如果用户调用 `kubectl describe pod FooPodName`，用户可以看到 Pod 处于 pending 状态的原因。`kubectl describe` 命令将输出如下事件表：

```shell
Error validating pod "FooPodName"."FooPodNamespace" from api, ignoring: spec.containers[0].securityContext.privileged: forbidden '<*>(0xc2089d3248)true'
```

如果主节点运行的版本低于 v1.1，则特权 Pod 不能被创建。如果用户尝试创建具有特权容器的 Pod，用户将收到以下错误：

```shell
The Pod "FooPodName" is invalid. spec.containers[0].securityContext.privileged: forbidden '<*>(0xc20b222db0)true'
```

## API 对象

Pod 是 Kubernetes REST API 中的顶级资源。更多有关 API 对象的细节可以在 [Pod API
对象](https://v1-11.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#pod-v1-core) 中找到。
