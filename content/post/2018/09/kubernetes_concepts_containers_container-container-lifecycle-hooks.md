---
title: '容器生命周期的钩子'
slug: kubernetes_concepts_containers_container-container-lifecycle-hooks
date: 2018-09-09
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

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/

本文介绍了由 kubelet 管理的容器是如何使用容器生命周期的钩子框架通过其管理的生命周期内的事件触发来运行代码的。

<!--more-->

## 概述

类似很多具有组件生命周期钩子的编程语言空间（如，Angular），Kubernetes 提供了带有生命周期钩子的容器。钩子使容器能够了解其管理生命周期中的事件，并且当相应的生命周期钩子被调用时运行在处理程序中实现的代码。

## 容器钩子

有两个暴露给容器的钩子：

`PostStart`

这个钩子在容器创建后立即执行。但是不能保证钩子在容器 ENTRYPOINT 前执行。没有参数传递给该处理程序。

`PreStop`

这个钩子在容器终止之前立即被调用。它是阻塞的，意味着它是同步的，所以它必须在删除容器的调用发出之前完成。没有参数传递给该处理程序。

更多有关终止行为的详细描述可以在 [容器的终止](https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods) 里找到。

### 钩子处理程序的实现

容器可以通过实现和注册该钩子的处理程序来访问钩子。这里有两种可以为容器实现的钩子处理程序。

- Exec -- 在容器的 cgroups 或命名空间内执行一个特定的命令，例如 `pre-stop.sh`。该命令消耗的资源被计入容器中。
- HTTP -- 对容器上的特定的端点执行 HTTP 请求。

### 钩子处理函数的执行

当容器生命周期的钩子被调用时，Kubernetes 管理系统执行该钩子在容器中注册的处理程序。

在含有容器的 Pod 的上下文中钩子处理程序的调用是同步的。这意味着对于 `PostStart` 钩子，容器 ENTRYPOINT 和钩子执行是异步的。然而，如果钩子花费太长时间以致于不能运行或者挂起，容器将不能达到 `running` 状态。

`PreStop` 钩子的行为是类似的。如果钩子在执行期间挂起，Pod 阶段将停留在 `running` 状态并且永远不会达到 `failed` 状态。如果 `PostStart` 或者 `PreStop` 钩子失败，它会杀死容器。

用户应该使他们的钩子处理程序尽可能的轻量。然而，有些情况下，长时间运行命令是合理的，比如在停止容器之前保存状态。

### 钩子交付保证

钩子交付至少一次，这意味着对于给定的事件，一个钩子可能被多次调用，例如对于 `PostStart` 或者 `PreStop`。它是由钩子的实现来正确的处理这个。

通常，只有单次交付。例如，如果一个 HTTP 钩子的接收者挂掉不能接收流量，该钩子不会尝试重新发送。然而，在一些极不常见的情况下，可能发生两次交付。例如，如果在发送钩子的途中 kubelet 重启， 该钩子可能在 kubelet 启动之后重新发送。

### 调试钩子处理程序

在 Pod 的事件中没有钩子处理程序的日志。如果一个处理程序因为某些原因运行失败，它会广播一个事件。对于 `PostStart`，这是 `FailedPostStartHook` 事件，对于 `PreStop`，这是 `FailedPreStopHook` 事件。你可以通过运行 `kubectl describe pod <pod_name>` 来查看这些事件。下面是运行这条命令的输出示例：

```shell
Events:
  FirstSeen    LastSeen    Count    From                            SubobjectPath        Type        Reason        Message
  ---------    --------    -----    ----                            -------------        --------    ------        -------
  1m        1m        1    {default-scheduler }                                Normal        Scheduled    Successfully assigned test-1730497541-cq1d2 to gke-test-cluster-default-pool-a07e5d30-siqd
  1m        1m        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Pulling        pulling image "test:1.0"
  1m        1m        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Created        Created container with docker id 5c6a256a2567; Security:[seccomp=unconfined]
  1m        1m        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Pulled        Successfully pulled image "test:1.0"
  1m        1m        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Started        Started container with docker id 5c6a256a2567
  38s        38s        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Killing        Killing container with docker id 5c6a256a2567: PostStart handler: Error executing in Docker Container: 1
  37s        37s        1    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Normal        Killing        Killing container with docker id 8df9fdfd7054: PostStart handler: Error executing in Docker Container: 1
  38s        37s        2    {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}                Warning        FailedSync    Error syncing pod, skipping: failed to "StartContainer" for "main" with RunContainerError: "PostStart handler: Error executing in Docker Container: 1"
  1m         22s         2     {kubelet gke-test-cluster-default-pool-a07e5d30-siqd}    spec.containers{main}    Warning        FailedPostStartHook
```
