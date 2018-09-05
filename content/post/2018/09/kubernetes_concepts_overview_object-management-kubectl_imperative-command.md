---
title: '使用命令式指令管理 Kubernetes 对象'
slug: kubernetes_concepts_overview_object-management-kubectl_imperative-command
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

原文：https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-command/

直接使用内置于 `kubectl` 命令行工具的命令式指令，可以快速地创建、更新和删除 Kubernetes 对象。本文介绍了任何组织这些命令，以及如何使用它们管理实时对象。

<!--more-->

## 权衡利弊

`kubectl` 工具支持三种对象管理的方式：

- 命令式指令
- 命令式对象配置
- 声明式对象配置

在 [Kubernetes 对象管理](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/) 中讨论了每一种对象管理方式的优缺点。

## 如何创建对象

`kubectl` 工具支持用于创建一些最常见对象类型的动词驱动命令。这些命令被命名为让对 Kubernetes 对象类型不熟悉的用户也认可的词。

- `run`：创建一个新的 Deployment 对象，以在一个或多个 Pod 中运行容器。
- `expose`：创建一个新的 Service 对象，以跨多个 Pod 实现流量的负载均衡。
- `autoscale`：创建一个新的 Autoscaler 对象，以自动横行缩放如 Deployment 这样的控制器。

`kubectl` 工具也支持由对象类型驱动的创建命令。这些命令支持更多的对象类型并且它们的目的更明确，但是要求用户知道它们打算创建的对象的类型。

- `create <objecttype> [<subtype>] <instancename>`

某些对象类型具有可以在 `create` 命令中指定的子类型。例如，Service 对象有几种子类型，包括 ClusterIP、LoadBalancer 和 NodePort。下面是创建一个带有子类型 NodePort 的 Service 的例子：

```shell
kubectl create service nodeport <myservicename>
```

在前面的例子中，`create service nodeport` 命令被称为 `create service` 命令的子命令。

你可以使用 `-h` 标志查找子命令支持的参数和标志：

```shell
kubectl create service nodeport -h
```

## 如何更新对象

`kubectl` 命令支持某些常见更新操作的动词驱动命令。这些命令的命名为了使不熟悉 Kubernetes 对象的用户在不知道必须设置的特定字段的情况下也可以执行更新：

- `scale`：通过更新控制器的副本数量横向缩放控制器来添加或移除 Pods。
- `annotate`：给一个对象添加或移除注解。
- `label`：给一个对象添加或移除标签。

`kubectl` 也支持由对象的某个方面驱动的更新命令。设置这方面可能会为不同的对象类型设置不同的字段：

- `set`：设置对象的某个方面。

> 注意：从 Kubernetes 1.5 版本开始，不是每个动词驱动的命令都有一个相关的方面驱动命令。

`kubectl` 工具支持这些额外的方法来直接更新实时对象，但是它们需要更好地了解 Kubernetes 对象架构。

- `edit`：通过在编辑器中打开其配置直接编辑实时对象的原始配置。
- `patch`：使用 patch 字符串直接修改实时对象的特定字段。有关 patch 字符串的详细信息，请参考 [API 约定](https://git.k8s.io/community/contributors/devel/api-conventions.md#patch-operations) patch 部分。

## 如何删除对象

你可以使用 `delete` 命令从集群中删除一个对象：

- `delete <type>/<name>`

> 注意：命令式指令和命令式对象配置都可以使用 `kubectl delete`。它们的不同是传递给命令的参数。想要 `kubectl delete` 用作命令性命令使用，请将要删除的对象作为参数。这里有一个删除名为 nginx 的 Deployment 对象的例子：

```shell
kubectl delete deployment/nginx
```

## 如何查看对象

有几个打印关于对象信息的命令：

- `get`：打印所匹配对象的基本信息。使用 `get -h` 可以查看选项列表。
- `describe`：打印所匹配对象的汇总详细信息。
- `logs`：打印在 Pod 中运行的容器的 stdout 和 stderr。

## 在创建之前使用 `set` 命令修改对象

有些对象字段没有可以在 `create` 命令中使用的标志。在这些情况下，可以在创建对象之前使用 `set` 和 `create` 的组合来指定字段的值。这是通过将 `create` 命令的输出传递到 `set` 命令，然后返回 `create` 命令来完成的。这里有一个例子：

```shell
kubectl create service clusterip my-svc --clusterip="None" -o yaml --dry-run | kubectl set selector --local -f - 'environment=qa' -o yaml | kubectl create -f -
```

1.`kubectl create service -o yaml --dry-run` 命令为 Service 创建配置，但将其以 YAML 格式打印到 stdout，而不是将其发送到 Kubernetes API 服务器。

2.`kubectl set --local -f - -o yaml` 命令从 stdin 中读取配置，并将更新后的配置作为 YAML 写入 stdout。

3.`kubectl create -f -` 命令使用由 stdin 提供的配置创建对象。

## 在创建之前使用 `--edit` 修改对象

你可以使用 `kubectl create --edit` 在对象创建之前进行任意的改变。这里有一个例子：

```shell
kubectl create service clusterip my-svc --clusterip="None" -o yaml --dry-run > /tmp/srv.yaml
kubectl create --edit -f /tmp/srv.yaml
```

1.`kubectl create service` 命令为 Service 创建配置，并将其保存到 `/tmp/srv.yaml`。

2.`kubectl create --edit` 命令在创建对象之前打开配置文件进行编辑。
