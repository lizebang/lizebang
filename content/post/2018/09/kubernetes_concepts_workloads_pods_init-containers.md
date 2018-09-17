---
title: 'Kubernetes Init 容器'
slug: kubernetes_concepts_workloads_pods_init-containers
date: 2018-09-15
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

原文：https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

本文提供了 Init 容器概览，它是在应用容器之前运行的专用容器，并且包含应用镜像中没有的工具和安装脚本。

<!--more-->

## 理解 Init 容器

[Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 能具有多个运行应用的容器，它也能有一个或多个在应用容器启动前运行的 Init 容器。

Init 容器与普通的容器非常像，除了下面两点：

- 它们总是运行到完成。
- 每个都必须在下一个容器启动前成功完成。

如果 Pod 的 Init 容器失败，则 Kubernetes 不断地重启 Pod 直到 Init 容器成功。然而，如果 Pod 的 `restartPolicy` 值为 Never 时，它将不会重启。

要指定容器为 Init 容器，只要在 PodSpec 中添加 `initContainers` 字段，在应用 `containers` 数组旁添加 [Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#container-v1-core) 类型对象的 JSON 数组。Init 容器的状态在 `status.initContainerStatuses` 字段中以容器状态数组的格式返回（和 `.status.containerStatuses` 字段相同）。

### 和普通容器的区别

Init 容器支持所有应用容器的字段和功能，包括资源限制、数据卷以及安全设置。然而，Init 容器对资源请求和限制的处理稍有不同，下面的 [资源](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#resources) 有说明。Init 容器也不支持就绪探针，因为它们必须在 Pod 准备好之前运行完成。

如果 Pod 中指定了多个 Init 容器，这些容器会按顺序一次运行一个。每个 Init 容器必须运行成功，下一个才能运行。当所有 Init 容器运行完成时，Kubernetes 初始化 Pod 并像平常一样运行应用容器。

## Init 容器可以做什么

因为 Init 容器具有与应用容器分离的镜像，所以它们对于启动相关代码具有如下优势：

- 出于安全原因，它们可以包含和运行应用容器镜像中不希望包含的实用工具。
- 它们可以包含应用程序镜像中没有的用于安装的工具和自定义代码。例如，创建镜像不需要 `FROM` 另一个镜像，只需要在安装过程中使用类似 `sed`、 `awk`、`python` 或 `dig` 这样的工具。
- 应用程序镜像构建器和部署者角色可以单独工作，没必要将它们构建到单个应用程序镜像中。
- 它们使用 Linux 命名空间，对于应用容器它们拥有不同的文件系统视图。因此，它们有权限访问 Secret，而应用容器不能够访问。
- 它们在所有应用容器启动前完成运行，但是应用容器并行运行，所以 Init 容器提供了一种简单的方式来阻塞或延迟应用容器的启动，直到满足一组先决条件。

### 示例

下面是一些使用 Init 容器的想法：

- 等待一个服务被创建，可以使用像下面的 shell 命令：
  ```shell
  for i in {1..100}; do sleep 1; if dig myservice; then exit 0; fi; done; exit 1
  ```
- 注册 Pod 到远程服务器，可以使用像下面的命令调用 API 完成：
  ```shell
  curl -X POST http://$MANAGEMENT_SERVICE_HOST:$MANAGEMENT_SERVICE_PORT/register -d 'instance=$(<POD_NAME>)&ip=$(<POD_IP>)'
  ```
- 在启动应用容器之前等一段时间，可以使用类似 `sleep 60` 的命令。
- 克隆 git 仓库到数据卷。
- 将配置值放到配置文件中，运行模版工具为主应用容器动态生成配置文件。例如，在配置文件中存放 POD_IP 值，并使用 Jinja 生成主要的应用配置文件。

更多详细用法示例，可以在 [StatefulSet 文档](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) 和 [生产环境 Pod 指南](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-initialization/) 中找到。

### Init 容器的使用

下面是 Kubernetes 1.5 版本的 yaml 文件，展示了一个具有 2 个 Init 容器的简单 Pod。第一个等待 `myservice` 启动，第二个等待 `mydb` 启动。 一旦这两个容器都启动完成，Pod 将开始启动。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
  annotations:
    pod.beta.kubernetes.io/init-containers: '[
        {
            "name": "init-myservice",
            "image": "busybox",
            "command": ["sh", "-c", "until nslookup myservice; do echo waiting for myservice; sleep 2; done;"]
        },
        {
            "name": "init-mydb",
            "image": "busybox",
            "command": ["sh", "-c", "until nslookup mydb; do echo waiting for mydb; sleep 2; done;"]
        }
    ]'
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
```

这是 Kubernetes 1.6 版本的新语法，尽管旧的注解语法在 1.6 和 1.7 版本中仍然可以使用。在 1.8 或更高版本中，必须使用新的语法。我们已经把 Init 容器的声明移到 spec 中：

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
      command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
    - name: init-myservice
      image: busybox
      command:
        [
          'sh',
          '-c',
          'until nslookup myservice; do echo waiting for myservice; sleep 2; done;',
        ]
    - name: init-mydb
      image: busybox
      command:
        [
          'sh',
          '-c',
          'until nslookup mydb; do echo waiting for mydb; sleep 2; done;',
        ]
```

虽然 1.5 版本的语法在 1.6 版本中仍然适用，但是我们推荐使用 1.6 版本的新语法。在 Kubernetes 1.6 版本中，Init 容器在 API 中创建了一个字段。注解（beta）在 1.6 和 1.7 版本仍然可以使用，但在 1.8 或更高版本中不支持。

下面的 yaml 文件展示了 `mydb` 和 `myservice` 两个服务：

```yaml
kind: Service
apiVersion: v1
metadata:
  name: myservice
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
---
kind: Service
apiVersion: v1
metadata:
  name: mydb
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9377
```

这个 Pod 可以使用下面的命令进行启动和调试：

```shell
$ kubectl create -f myapp.yaml
pod/myapp-pod created
$ kubectl get -f myapp.yaml
NAME        READY     STATUS     RESTARTS   AGE
myapp-pod   0/1       Init:0/2   0          6m
$ kubectl describe -f myapp.yaml
Name:          myapp-pod
Namespace:     default
[...]
Labels:        app=myapp
Status:        Pending
[...]
Init Containers:
  init-myservice:
[...]
    State:         Running
[...]
  init-mydb:
[...]
    State:         Waiting
      Reason:      PodInitializing
    Ready:         False
[...]
Containers:
  myapp-container:
[...]
    State:         Waiting
      Reason:      PodInitializing
    Ready:         False
[...]
Events:
  FirstSeen    LastSeen    Count    From                      SubObjectPath                           Type          Reason        Message
  ---------    --------    -----    ----                      -------------                           --------      ------        -------
  16s          16s         1        {default-scheduler }                                              Normal        Scheduled     Successfully assigned myapp-pod to 172.17.4.201
  16s          16s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Pulling       pulling image "busybox"
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Pulled        Successfully pulled image "busybox"
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Created       Created container with docker id 5ced34a04634; Security:[seccomp=unconfined]
  13s          13s         1        {kubelet 172.17.4.201}    spec.initContainers{init-myservice}     Normal        Started       Started container with docker id 5ced34a04634
$ kubectl logs myapp-pod -c init-myservice # Inspect the first init container
$ kubectl logs myapp-pod -c init-mydb      # Inspect the second init container
```

一旦我们启动 `mydb` 和 `myservice` 这两个服务，我们就能看到 Init 容器的完成以及 `myapp-pod` 被创建：

```shell
$ kubectl create -f services.yaml
service/myservice created
service/mydb created
$ kubectl get -f myapp.yaml
NAME        READY     STATUS    RESTARTS   AGE
myapp-pod   1/1       Running   0          9m
```

这个例子非常简单，但应该为你创建自己的 Init 容器提供了一些灵感。

## 具体的行为

在 Pod 启动过程中，Init 容器会在网络和数据卷初始化后按顺序启动。每个容器必须在下一个容器启动之前成功退出。如果由于运行时或失败退出导致容器启动失败，它会根据 Pod 的 `restartPolicy` 策略进行重试。然而，如果 Pod 的 `restartPolicy` 设置为 Always，则 Init 容器会使用 `RestartPolicy` OnFailure 策略。

在所有 Init 容器成功之前，Pod 的状态不会变为 `Ready`。Init 容器上的端口不会被聚集到服务上。正在初始化中的 Pod 处于 `Pending` 状态，但应将条件 `Initializing` 设置为 true。

如果 Pod 被 [重启](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#pod-restart-reasons)，所有的 Init 容器必须再执行一次。

对 Init 容器规约的修改仅限于容器镜像字段。更改 Init 容器的镜像字段，等价于重启该 Pod。

因为 Init 容器可以被重启、重试或者重新执行，所以 Init 容器的代码应该是幂等的。特别的是，被写到 `EmptyDirs` 上文件中的代码应该对输出文件已经存在的可能性做好准备。

Init 容器拥有应用容器的所有字段。然而，Kubernetes 禁止使用 `readinessProbe`，因为 Init 容器不能定义与完成不同的就绪情况。这在验证期间强制执行。

在 Pod 中使用 `activeDeadlineSeconds` 和容器中使用 `livenessProbe` 能够避免 Init 容器一直失败。这就为 Init 容器活跃设置了一个期限。

Pod 中每个应用容器和 Init 容器的名称必须是唯一的，任何容器和其他容器共用一个名称都会引发一个验证错误。

### 资源

对于 Init 容器给定的顺序和执行的任务，将应用下面对资源使用的规则：

- 在所有 Init 容器上定义的任何特殊资源请求或限制的最大值，被称为 **有效初始请求/限制**
- Pod 对资源的 **有效请求/限制** 要高于：
  - 所有应用容器对某一资源的请求/限制之和
  - 对某一资源的有效初始请求/限制
- 基于有效请求/限制完成调度，意味着 Init 容器可以为初始化预留资源，这些资源在 Pod 生命周期内被不使用。
- Pod 的 **有效 QoS 层** 是 Init 容器和应用容器的 QoS 层。

配额和限制是根据有效的 Pod 请求和限制来申请的。

Pod 级别的 cgroups 基于有效的 Pod 请求和限制，与调度器相同。

### Pod 重启的原因

Pod 能够重启，导致 Init 容器重新执行，主要有如下几个原因：

- 用户更新 PodSpec 导致 Init 容器镜像发生改变。应用容器镜像的改变只会重启应用容器。
- Pod 基础设施容器被重启。这种情况并不常见，并且由具有节点 root 访问权限的人员才能完成操作。
- 当 `restartPolicy` 设置为 Always，Pod 中的所有容器会被终止，强制重启，并且由于垃圾回收会导致 Init 容器完成的记录丢失。

## 支持和兼容性

apiserver 版本为 1.6.0 或更高的集群支持 Init 容器使用 `.spec.initContainers` 字段。以前的版本使用注解（alpha 和 beta）。`.spec.initContainers` 字段也被加入到注解（alpha 和 beta）中，所以版本为 1.3.0 或更高的 kubelets 可以执行 Init 容器，并且 1.6 版本的 apiserver 可以安全的回滚到 1.5.x 版本，而不会使存在的已创建的 Pod 失去 Init 容器到功能。

在 apiserver 和 kubelet 1.8.0 或更高版本中，删除了对注解（alpha 和 beta）的支持，需要从已弃用的注解转换为 `.spec.initContainers` 字段。

此功能已在 1.6 版本中结束测试。可以 PodSpec 应用程序 `containers` 数组后指定 Init 容器。注解（beta）在 1.6 和 1.7 版本被弃用，虽然它们仍然可以使用并覆盖 PodSpec 字段值。在 1.8 版本中，不再支持注解，必须将其转换为 PodSpec 字段。
