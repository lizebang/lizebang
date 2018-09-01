---
title: 'Kubernetes 命名空间'
slug: kubernetes_concepts_overview_working-with-objects_namespaces
date: 2018-08-30
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/

Kubernetes 支持同一物理集群支撑多虚拟集群。这些虚拟集群被称为 namespaces。

<!--more-->

## 何时使用多命名空间

命名空间旨在用于多个用户分布在多个团队或项目中的环境中。对于具有几个到几十个用户的集群，你根本不需要创建或考虑命名空间。当你需要它们提供功能时再开始使用命名空间。

命名空间提供名称范围。资源的名称在一个命名空间中必须是唯一的，但跨命名空间可以相同。

命名空间是一种在多用户间划分集群资源的方法（通过 [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/)）。

在 Kubernetes 的未来版本中，默认情况下，同一名称空间中的对象将具有相同的访问控制策略。

没有必要使用多个名称空间来分隔略有不同的资源，例如同一软件的不同版本：可以使用 [标签](https://kubernetes.io/docs/user-guide/labels) 来区分同一命名空间中的资源。

## 使用命名空间

[命名空间管理手册](https://kubernetes.io/docs/admin/namespaces) 描述了命名空间的创建和删除。

### 查看命名空间

你可以使用下面命令列出当前集群中的命名空间：

```shell
$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    1d
kube-system   Active    1d
kube-public   Active    1d
```

Kubernetes 开始时会创建三个初始的命名空间：

- `default` 没有其他命名空间的对象
- `kube-system` Kubernetes 系统创建的对象
- `kube-public` 此命名空间是自动创建的，并且所有用户可以读取（包括未经过身份验证的用户）。此命名空间主要用于集群使用，以确保某些资源在整个群集中可见且可公开读取。此命名空间只是一个约定，而不是一个要求。

### 设置请求的命名空间

为了一个请求临时设置命名空间，可以使用 `--namespace`。

例如：

```shell
$ kubectl --namespace=<insert-namespace-name-here> run nginx --image=nginx
$ kubectl --namespace=<insert-namespace-name-here> get pods
```

### 设置命名空间首选项

你可以在命名空间中永久地保存上下文所有随后使用的 kubectl 命令。

```shell
$ kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
# Validate it
$ kubectl config view | grep namespace:
```

## 命名空间和 DNS

当你创建一个 [Service](https://kubernetes.io/docs/user-guide/services)，它会创建相应的 [DNS 条目](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)。此条目的格式为 `<service-name>.<namespace-name>.svc.cluster.local`，这意味着如果容器只使用 `<service-name>`，它将解析为所在命名空间的服务。这对于在那些跨越多个命名空间，例如开发、预演以及生产中使用相同配置时来讲非常有用。如果要跨命名空间访问，则需要使用完全限定的域名（FQDN）。

## 并非所有对象都在命名空间中

大部分的 Kubernetes 资源（例如，pods、services、replication controllers 以及一些其他的资源）都在命名空间里。然而，命名空间资源本身并不在命名空间中。低级别的资源并不在任何命名空间，例如 [nodes](https://kubernetes.io/docs/admin/node) 和持久卷。

可以用下面命令查看哪些 Kubernetes 资源在命名空间，哪些不在：

```shell
# In a namespace
$ kubectl api-resources --namespaced=true

# Not in a namespace
$ kubectl api-resources --namespaced=false
```
