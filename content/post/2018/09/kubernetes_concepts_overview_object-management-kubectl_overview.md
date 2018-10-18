---
title: 'Kubernetes 对象管理'
slug: kubernetes_concepts_overview_object-management-kubectl_overview
date: 2018-09-02
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

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/

命令行工具 `kubectl` 支持几种不同的方法来创建和管理 Kubernetes 对象。本文简单介绍了一下这几种不同的方法。

<!--more-->

## 管理技术

> 警告：一个 Kubernetes 对象只应该用一种技术来管理。针对同一对象的混合和竞争技术会导致未定义的行为。

| 管理技术       | 操作     | 推荐环境 | 支持的编写工具 | 学习曲线 |
| :------------- | :------- | :------- | :------------- | :------- |
| 命令式指令     | 实时对象 | 开发项目 | 1+             | 最低     |
| 命令式对象配置 | 单个文件 | 生产项目 | 1              | 中等     |
| 声明式对象配置 | 文件目录 | 生产项目 | 1+             | 最高     |

## 命令式指令

当使用命令式指令时，用户可以直接在集群里操作对象。用户提供要进行的操作给 `kubectl` 命令作为参数或标志。

这是在集群中启动或开始一个一次性任务的最简单的方法。由于这种技术直接作用于实时对象，所以它不提供先前配置的历史。

### 示例

通过创建一个 Deployment 对象来运行 nginx 容器的实例：

```shell
kubectl run nginx --image nginx
```

下面用不同的语法可以实现相同的事情：

```shell
kubectl create deployment nginx --image nginx
```

### 权衡利弊

与对象配置相比的优势：

- 命令简单，容易学习，容易记忆。
- 命令只需要一个步骤就可以完成对集群的修改。

与对象配置相比的劣势：

- 命令不能集成修改审查流程。
- 命令不能提供与修改相关的审计跟踪。
- 命令不能提供除实时对象外的记录来源。
- 命令不能提供用于创建新对象的模板。

## 命令式对象配置

在命令式对象配置中，kubectl 命令指定操作（创建、替换等）、可选标志和至少一个文件名。指定的文件必须包含一个 YAML 或 JSON 格式的对象的完整定义。

更多对象定义的细节请看 [API 参考](https://v1-11.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/)

> 警告：命令式的 `replace` 命令会用新提供的规约替换目前的规约，同时移除所有不再在配置文件中的对象。此方法不应该用于那些规约对立于配置文件进行更新的资源类型。例如，`LoadBalancer` 类型的 Service 资源，它们的 `externalIPs` 字段是独立于配置，由集群进行更新的。

### 示例

创建配置文件中定义的对象：

```shell
kubectl create -f nginx.yaml
```

删除两个配置文件中定义的对象：

```shell
kubectl delete -f nginx.yaml -f redis.yaml
```

通过重写实时配置，更新配置文件中定义的对象：

```shell
kubectl replace -f nginx.yaml
```

### 权衡利弊

与命令式指令相比的优势：

- 对象配置可以存储在类似 Git 的源代码控制系统中。
- 对象配置可以集成类似推送前检阅更改，以及审计跟踪等流程。
- 对象配置可以提供用于创建新对象的模板。

与命令式指令相比的劣势：

- 对象配置需要对对象模式有基本的了解。
- 对象配置需要编写 YAML 文件这样的额外步骤。

与声明式对象配置相比的优势：

- 命令式对象配置的行为更简单，更容易理解。
- 从 Kubernetes 1.5 版本开始，命令式对象配置更加成熟。

与声明式对象配置相比的劣势：

- 命令式对象配置最适合于文件，而不是目录。
- 实时对象的更新必须反映在配置文件中，否则它们将在下次替换时丢失。

## 声明式对象配置

当使用声明式对象配置时，用户操作本地存储的对象配置文件，然而用户不会定义对文件的操作。创建、更新和删除操作由 `kubectl` 逐个对象自动进行检测。它可以对目录中需要不同操作的不同对象进行处理。

> 注意：声明式对象配置保留了其他修改者所做的修改，即使这些修改没有合并到对象配置文件中。可以通过使用 `patch` API 操作来写入观察到的差异，而不是使用 `replace` API 操作来替换整个对象配置。

### 示例

处理 `configs` 目录中的所有对象的配置文件，并创建或修改实时对象：

```shell
kubectl apply -f configs/
```

递归处理目录：

```shell
kubectl apply -R -f configs/
```

### 权衡利弊

与命令式对象配置相比的优势：

- 直接对实时对象进行的修改将保留，即使这些修改没有合并到对象配置文件中。
- 声明式对象配置更好地支持对目录进行操作，并自动检测每个对象的操作类型（创建、补丁、删除）。

与命令式对象配置相比的劣势：

- 在意想不到的情况下，声明式对象配置很难调试，其结果也很难理解。
- 使用区别对比进行部分更新，使合并和打补丁操作变得复杂。
