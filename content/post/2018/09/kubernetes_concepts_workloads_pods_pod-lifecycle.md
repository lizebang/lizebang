---
title: 'Kubernetes Pod 的生命周期'
slug: kubernetes_concepts_workloads_pods_pod-lifecycle
date: 2018-09-14
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

原文：https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/

这篇介绍了 Pod 的生命周期。

<!--more-->

## Pod `phase`

Pod 的状态字段是一个 [PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#podstatus-v1-core) 对象，它带有一个 `phase` 字段。

Pod 的阶段是 Pod 在其生命周期中的简单、高级的概述。Pod 的阶段不是为了对 Container 或 Pod 状态的进行全面地综合汇总，也不是为了做全面的状态机。

Pod 阶段的数值和含义是严格指定的。除了本文中列举的内容外，不应该再假定 Pod 有其他的 `phase` 值。

下面是 `phase` 的可能值：

| 值          | 描述                                                                                                                                                     |
| :---------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Pending`   | Pod 已经被 Kubernetes 系统接受，但是还有一个或多个容器镜像没有被准备好。这部分等待的时间包括调度之前通过网络下载镜像的时间，这部分花费的时间可能有些长。 |
| `Running`   | Pod 已经被绑定到一个节点上，并且Pod中的所有容器都已经被成功创建。至少有一个容器正在运行，或正处于启动或重启状态。                                        |
| `Succeeded` | Pod 中的所有容器都被成功终止，并且不会被重启。                                                                                                           |
| `Failed`    | Pod中的所有容器都已经终止，并且至少由一个容器终止失败过。也就是说，容器以非 0 状态退出或者被系统终止。                                                   |
| `Unknown`   | 由于某种原因无法获取Pod的状态，这通常是由于Pod的主机通讯时出错。                                                                                         |

## Pod 条件

Pod 由一个 PodStatus 对象，此对象包含一个 [PodConditions](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#podcondition-v1-core) 数组。每个 PodCondition 数组元素包含六个可能的字段：

- `lastProbeTime` 字段提供了最后一次探测 Pod 条件的时间戳。
- `lastTransitionTime` 字段提供了 Pod 最后一次状态转换的时间戳。
- `message` 字段是人类可读的消息，它指明了有关转换的详细信息。
- `reason` 字段是唯一、单字的 CamelCase 原因，它指明了最后一次条件转换的原因。
- `status` 字段是一个字符串，可选值有 `True`、`False` 和 `Unknown`。
- `type` 字段是一个带有下列可能值的字符串:
  - `PodScheduled`：Pod 已经被调度到一个节点上。
  - `Ready`：Pod 可以处理请求，并且应该被添加到所有匹配服务的负载均衡池中。
  - `Initialized`：所有 [Init 容器](https://kubernetes.io/docs/concepts/workloads/pods/init-containers) 都已经成功启动。
  - `Unschedulable`：调度器现在不能调度 Pod，例如缺少资源或其他限制。
  - `ContainersReady`：Pod 中的所有容器都已准备就绪。

## 容器探针

[探针](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#probe-v1-core) 是由 [kubelet](https://kubernetes.io/docs/admin/kubelet/) 定期执行的诊断。为了执行诊断，kubelet 调用了由容器实现的 [Handler](https://godoc.org/k8s.io/kubernetes/pkg/api/v1#Handler)。处理程序有三种类型：

- [ExecAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#execaction-v1-core)：在容器内部执行指定的命令。如果命令以状态码 0 退出，则诊断为成功。
- [TCPSocketAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#tcpsocketaction-v1-core)：对容器 IP 地址的指定端口执行 TCP 检查。如果端口是打开的，则诊断为成功。
- [HTTPGetAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#httpgetaction-v1-core)：对容器 IP 地址的指定端口和路径执行 HTTP GET 请求。如果响应的状态码大于等于 200 且小于 400，则诊断为成功。

每个探针的结果有下面三种：

- Success：容器通过诊断。
- Failure：容器诊断失败。
- Unknown：诊断失败，因此不应采取任何措施。

kubelet 可以选择在运行的容器上执行两种探测并做出反应：

- `livenessProbe`：指示容器是否运行。如果存活探测失败，kubelet 会杀死容器，并且容器将收到其 [重启策略](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy) 的影响。如果容器没有提供存活探针，其默认状态是 `Success`。
- `readinessProbe`：指示容器是否准备好处理请求。如果就绪探测失败，端点控制器会从与 Pod 匹配的所有服务的端点中删除 Pod 的 IP 地址。初始延迟之前的就绪状态的默认值为 `Failure`。如果容器不提供就绪探针，则默认状态为 `Success`。

### 何时应该使用存活探针和就绪探针？

如果容器中的进程在遇到问题或变得不健康时能够自行崩溃，那么你一定不需要存活探针；kubelet 将自动地按照 Pod 的 `restartPolicy` 执行正确的操作。

如果你希望在探测失败时杀死并重启容器，那么请指定一个存活探针并指定 `restartPolicy` 为 Always 或 OnFailure。

如果你希望仅在探测成功时才开始发送流量到 Pod，那么请指定一个就绪探针。在这种情况下，就绪探针可能和存活探针相同，但是在规约中的就绪探针的存在意味着 Pod 开始时没有接收任何流量并且只在探测成功后才开始接收流量。

如果容器在启动时需要载入大量数据、配置或迁移文件，请指定一个就绪探针。

如果希望容器能够自行维护，可以指定一个就绪探针，该探针用于检查特定就绪状态的端点（此端点与存活探针的不同）。

注意，如果你只是想在 Pod 被删除是能够排除请求，则不一定需要使用就绪探针。在删除 Pod 时，无论是否存在就绪探针 Pod 都会自动将自身置于未完成状态。在等待 Pod 中的容器停止时，Pod 会处于未完成状态。

更多有关如何设置存活探针和就绪探针的信息，请查看 [配置存活探针和就绪探针](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)。

## Pod 和 Container 的状态

有关 Pod Container 状态的详细信息，请查看 [PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#podstatus-v1-core) 和 [ContainerStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#containerstatus-v1-core)。注意，报告 Pod 状态的信息取决于当前的 [ContainerState](https://k8smeetup.github.io/docs/resources-reference/v1.7/#containerstatus-v1-core)。

## Pod readiness gate

**FEATURE STATE**：`Kubernetes v1.11` `alpha`

为了通过将额外的反馈或信号注入到 `PodStatus` 来增加 Pod 就绪探针的扩展性，Kubernetes 1.11 引入了一个名为 [Pod ready++](https://github.com/kubernetes/community/blob/master/keps/sig-network/0007-pod-ready++.md) 的功能。你可以在 `PodSpec` 中使用新字段 `ReadinessGate` 指定 Pod 就绪探针进行评估附加条件。如果 Kubernetes 不能在 Pod 的 `status.conditions` 字段中找到这样一个条件，那么条件的默认状态为 `False`。下面是一个例子：

```yaml
Kind: Pod
......
spec:
  readinessGates:
    - conditionType: 'www.example.com/feature-1'
status:
  conditions:
    - type: Ready # this is a builtin PodCondition
      status: 'True'
      lastProbeTime: null
      lastTransitionTime: 2018-01-01T00:00:00Z
    - type: 'www.example.com/feature-1' # an extra PodCondition
      status: 'False'
      lastProbeTime: null
      lastTransitionTime: 2018-01-01T00:00:00Z
  containerStatuses:
    - containerID: docker://abcd...
      ready: true
......
```

新的 Pod 条件必须符合 Kubernetes [标签的格式](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set)。由于 `kubectl patch` 命令仍然不支持对象状态，新的 Pod 条件必须使用 [KubeClient 库](https://kubernetes.io/docs/reference/using-api/client-libraries/) 通过 `PATH` 操作注入进去。

随着新的 Pod 条件的引入，只有当下面两个条件都成立时才会认为 Pod 准备就绪：

- Pod 中所有容器都准备就绪。
- 所有 `ReadinessGates` 指定的条件都为 `True`。

为了便于 Pod 就绪探针对此作出改变，引入新的 Pod 条件 `ContainersReady` 来捕获旧的 Pod `Ready` 条件。

作为 alpha 功能，必须通过将 `PodReadinessGates` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) 设置为 True 来显示地启用 "Pod Ready++" 功能。

## 重启策略

PodSpec 有一个 `restartPolicy` 字段，其可能值有 Always、OnFailure 和 Never。此字段的默认值为 Always。`restartPolicy` 适用于 Pod 中的所有容器。`restartPolicy` 只是指通过同一节点上的 kubelet 重启容器。退出的容器有 kubelet 以五分钟为上限的指数退避延迟重新启动（10s、20s、40s...），指数退避延迟在成功执行十分钟后重置。如 [Pod 文档](https://kubernetes.io/docs/user-guide/pods/#durability-of-pods-or-lack-thereof) 中描述的，一旦绑定到一个节点上，Pod 将永远不会重新绑定到另一个节点上。

## Pod 的生命周期

通常情况上，Pod 不会消失，知道有人销毁它。这可能是一个人会控制器。这个规则唯一的例外是 `phase` 值为 Succeeded 或 Failed 超过一段时间（由主节点上的 `terminated-pod-gc-threshold` 决定的）的 Pod 将过期并被自动销毁。

有三种可用的控制器类型：

- 使用 [Job](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/) 运行预期会终止的 Pod，例如批量计算。Job 只适用于具有 `restartPolicy` 为 OnFailure 或 Never 的 Pod。
- 使用 [ReplicationController](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)、[ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) 或 [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) 运行预期不会终止的 Pod，例如 web 服务器。ReplicationControllers 只适用于具有 `restartPolicy` 为 Always 的 Pod。
- 使用 [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) 运行需要为每台机器运行一个的 Pod，因为它提供特定于机器的系统服务。

所有这三种类型的控制器都包含一个 PodTemplate。建议创建适当的控制器，让它们来创建 Pod，而不是直接自己创建 Pod。这是因为单独的 Pod 在机器故障的情况下没有办法自动复原，而控制器却可以。

如果节点出错或与集群的其余部分断开连接，则 Kubernetes 将应用一个策略将丢失节点上的所有 Pod 的 `phase` 设置为 Failed。

## 例子

### 高级存活探针示例

存活探针由 kubelet 来执行，因此所有的请求都在 kubelet 的网络命名空间中进行。

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
    - args:
        - /server
      image: k8s.gcr.io/liveness
      livenessProbe:
        httpGet:
          # when "host" is not defined, "PodIP" will be used
          # host: my-host
          # when "scheme" is not defined, "HTTP" scheme will be used. Only "HTTP" and "HTTPS" are allowed
          # scheme: HTTPS
          path: /healthz
          port: 8080
          httpHeaders:
            - name: X-Custom-Header
              value: Awesome
        initialDelaySeconds: 15
        timeoutSeconds: 1
      name: liveness
```

### 示例状态

- Pod 正在运行并有一个容器。容器成功退出。
  - 记录完成事件。
  - 如果 `restartPolicy` 为：
    - Always：重启容器，Pod `phase` 仍为 Running。
    - OnFailure：Pod `phase` 变为 Succeeded。
    - Never：Pod `phase` 变为 Succeeded。
- Pod 正在运行并有一个容器。容器失败退出。
  - 记录失败事件。
  - 如果 `restartPolicy` 为：
    - Always：重启容器，Pod `phase` 仍为 Running。
    - OnFailure：重启容器，Pod `phase` 仍为 Running。
    - Never：Pod `phase` 变为 Failed。
- Pod 正在运行并有两个容器。容器 1 失败退出。
  - 记录失败事件。
  - 如果 `restartPolicy` 为：
    - Always：重启容器，Pod `phase` 仍为 Running。
    - OnFailure：重启容器，Pod `phase` 仍为 Running。
    - Never：不重启容器，Pod `phase` 仍为 Running。
  - 如果容器 1 不在运行，而容器 2 退出：
    - 记录失败事件。
    - 如果 `restartPolicy` 为：
      - Always：重启容器，Pod `phase` 仍为 Running。
      - OnFailure：重启容器，Pod `phase` 仍为 Running。
      - Never：Pod `phase` 变为 Failed。
- Pod 正在运行并有一个容器。容器运行超出内存。
  - 容器以失败终止。
  - 记录 OOM（out of memory）事件。
  - 如果 `restartPolicy` 为：
    - Always：重启容器，Pod `phase` 仍为 Running。
    - OnFailure：重启容器，Pod `phase` 仍为 Running。
    - Never：记录失败事件，Pod `phase` 变为 Failed。
- Pod 正在运行，磁盘故障。
  - 杀死所有容器。
  - 记录适当事件。
  - Pod `phase` 变为 Failed。
  - 如果使用控制器运行，Pod 将在其他地方被重新创建。
- Pod 正在运行，但是节点被分隔出来。
  - 节点控制器等待超时。
  - 节点控制器将 Pod `phase` 设置为 Failed。
  - 如果使用控制器运行，Pod 将在其他地方被重新创建。
