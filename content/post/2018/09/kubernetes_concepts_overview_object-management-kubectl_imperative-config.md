---
title: '使用配置文件对 Kubernetes 对象的命令式管理'
slug: kubernetes_concepts_overview_object-management-kubectl_imperative-config
date: 2018-09-03
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

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/

通过使用 `kubectl` 命令以及 YAML 或 JSON 格式编写的对象配置文件可以创建、更新和删除 Kubernetes 对象。本文介绍了如何使用配置文件定义和管理对象。

<!--more-->

## 权衡利弊

`kubectl` 工具支持三种对象管理的方式：

- 命令式指令
- 命令式对象配置
- 声明式对象配置

在 [Kubernetes 对象管理](https://v1-11.docs.kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/) 中讨论了每一种对象管理方式的优缺点。

## 如何创建对象

你可以使用 `kubectl create -f` 通过一个配置文件创建一个对象。详细内容请参考 [Kubernetes API 参考](https://v1-11.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/)。

- `kubectl create -f <filename|url>`

## 如何更新对象

> 警告：使用 `replace` 命令更新对象将删除配置文件中规格（spec）未指定的所有部分。它不应该用于集群部分管理规格的对象，例如，`LoadBalancer` 类型的 Services，其 `externalIPs` 字段是独立于配置文件管理的。必须将独立管理的字段复制到配置文件中，以防止 `replace` 删除它们。

你可以使用 `kubectl replace -f` 通过配置文件更新实时对象。

- `kubectl replace -f <filename|url>`

## 如何删除对象

你可以使用 `kubectl delete -f` 删除一个由配置文件描述的对象。

- `kubectl delete -f <filename|url>`

## 如何查看对象

你可以使用 `kubectl get -f` 查看一个由配置文件描述的对象的有关信息。

- `kubectl get -f <filename|url> -o yaml`

`-o yaml` 标签表明需要打印完整的对象配置。使用 `kubectl get -h` 可以查看选项列表。

## 限制

当每个对象的配置被完全定义并记录在配置文件中，`create`、`replace`、`delete` 命令工作正常。然而，当实时对象被更新，并且更新没有合并到它的配置文件中，更新将会在下一次执行 `replace` 时丢失。如果像 HorizontalPodAutoscaler 这样的控制器直接更新实时对象，则可能发生这种情况。看下面的例子：

1.你可以从配置文件创建对象。

2.另一个源通过更改某个字段来更新对象。

3.你可以从配置文件中替换该对象。步骤 2 中其他源所做的更改将丢失。

如果你需要支持同一对象的多个写入，则可以使用 `kubectl apply` 来管理对象。

## 在不保存配置的情况下通过 URL 创建和编辑对象

假设你有一个对象配置文件的 URL。你可以使用 `kubectl create --edit` 在创建对象之前对配置文件进行修改。这对于指向可以被读者修改的配置文件的教程和任务尤为有用。

`kubectl create -f <url> --edit`

## 从命令式指令迁移到命令式配置

从命令式指令迁移到命令式配置的迁移涉及到几个手动步骤。

1.将实时对象导出到本地对象配置文件中：

`kubectl get <kind>/<name> -o yaml --export > <kind>_<name>.yaml`

2.手动地从对象配置文件中移除状态字段。

3.对于后续的对象管理，只使用 `replace`。

`kubectl replace -f <kind>_<name>.yaml`

## 定义控制器选择器和 PodTemplate 标签

> 警告：强烈建议不要更新控制器上的选择器。

建议的方法是定义一个单独的、不可变的 PodTemplate 标签，它仅由控制器选择器使用并且没有其他语意。

示例标签：

```yaml
selector:
  matchLabels:
    controller-selector: 'extensions/v1beta1/deployment/nginx'
template:
  metadata:
    labels:
      controller-selector: 'extensions/v1beta1/deployment/nginx'
```
