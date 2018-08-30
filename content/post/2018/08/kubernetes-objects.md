---
title: 'Kubernetes 对象'
slug: kubernetes-objects
date: 2018-08-28
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/

本文介绍了如何使用 Kubernetes API 表示 Kubernetes 对象，以及如何以 `.yaml` 格式表达它们。

<!--more-->

## 理解 Kubernetes 对象

**Kubernetes 对象** 是 Kubernetes 中持久化的实体。Kubernetes 使用这些实体来表示集群的状态。具体来说，它们可以描述为：

- 哪些容器化的程序在运行（以及在哪些节点上）
- 可以被应用使用的资源
- 应用程序如何运行的策略，例如重启策略、升级策略，以及容错策略

Kubernetes 对象是一个 “目标性记录”，一旦创建了对象，Kubernetes 系统将不断努力确保对象存在。通过创建对象，你可以有效地告诉 Kubernetes 系统所需要的集群工作负载看起来是什么样子的，这就是集群的期望状态。

操作 Kubernetes 对象，无论是创建、修改还是删除它们，都需要使用 [Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)。例如，当你使用 `kubectl` 命令行接口时，CLI 会执行必要的 Kubernetes API 调用。你也可以在程序中直接调用 Kubernetes API。[Client Libraries](https://kubernetes.io/docs/reference/using-api/client-libraries/)

### 对象的规约与状态

每个 Kubernetes 对象都包含两个嵌套对象字段，它们用于控制对象的配置：对象规约和对象状态。规约是必须提供的，它描述了对象的期望状态 -- 希望对象具有的特征。状态描述了对象的实际状态，由 Kubernetes 系统提供和更新。在任何给定的时间，Kubernetes 控制平台一直努力地管理着对象的实际状态以与期望状态相匹配。

例如：Kubernetes Deployment 对象可以表示运行在集群上的应用。当你创建 Deployment，可能需要设置 Deployment 的规约来指定该应用需要有 3 个副本在运行。Kubernetes 系统读取 Deployment 的规约并启动 3 个所需要应用的实例以更新状态与规约相匹配。如果这些实例中的任何一个失败（一种状态变更），Kubernetes 系统在这种情况下会启动一个代替的实例来修正来响应状态和规约之间的不一致。

更多有关对象 spec、status 和 metadata 的信息，请查看 [Kubernetes API Conventions](https://git.k8s.io/community/contributors/devel/api-conventions.md)

### 描述一个 Kubernetes 对象

当你在 Kubernetes 创建一个对象时，你必须提供一个对象的规约，描述了期望的状态和一些对象的基础信息（例如名称）。当你使用 Kubernetes API 创建对象时（直接或通过 `kubectl`），API 请求必须在请求体中包含 JSON 格式的这些信息。**通常，你通过一个 `.yaml` 的文件提供这些信息给 `kubectl`。**当进行 API 请求时，`kubectl` 将这些信息转化成 JSON 格式。

这里有一个 `.yaml` 示例文件，展示了 Kubernetes Deployment 的必需字段和对象规约：

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

使用类似上面的 `.yaml` 文件创建部署的一种方法是使用 kubectl 命令行接口中的 `kubectl create` 命令，将 `.yaml` 文件作为参数。这里有一个例子：

```shell
$ kubectl create -f https://k8s.io/examples/application/deployment.yaml --record
```

输出类似于：

```shell
deployment.apps/nginx-deployment created
```

### 必需字段

在创建想要 Kubernetes 对象的对应 `.yaml` 文件中，需要配置如下的字段：

- `apiVersion` -- 创建该对象所使用的 Kubernetes API 的版本
- `kind` -- 想要创建的对象的类型
- `metadata` -- 帮助识别对象唯一性的数据，包括一个 `name` 字符串、UID 和可选的 `namespace`

你还需要提供对象的 `spec` 字段。对于每个 Kubernetes 对象，对象 `spec` 的精确格式是不同的。[Kubernetes API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/) 可以帮助你找到任何想创建的对象的 `spec` 格式。例如，`Pod` 对象的 `spec` 格式在 [这里](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#podspec-v1-core) 找到，`Deployment` 对象的 `spec` 格式在 [这里](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#deploymentspec-v1-apps) 找到。
