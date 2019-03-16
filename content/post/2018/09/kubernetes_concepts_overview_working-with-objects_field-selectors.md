---
title: "Kubernetes 字段选择器"
slug: kubernetes_concepts_overview_working-with-objects_field-selectors
date: 2018-09-01
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/

字段选择器允许你根据一个或多个资源字段的值 [选择 Kubernetes 资源](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects)。

<!--more-->

以下是一些字段选择器查询的示例：

- `metadata.name=my-service`
- `metadata.namespace!=default`
- `status.phase=Pending`

下面 `kubectl` 命令可以选择所有 [`status.phase`](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase) 字段值为 `Running` 的 Pods：

```shell
$ kubectl get pods --field-selector status.phase=Running
```

> 字段选择器本质上是资源过滤器。默认情况下，不使用选择器/过滤器意味着将选择指定类型的所有资源。这使得下面的 `kubectl` 查询语句是等效的：

```shell
$ kubectl get pods
$ kubectl get pods --field-selector ""
```

## 支持的字段

选择器支持的字段因 Kubernetes 资源类型而异。所有的资源类型都支持 `metadata.name` 和 `metadata.namespace` 字段。使用不受支持的字段，选择器会产生错误。例如：

```shell
$ kubectl get ingress --field-selector foo.bar=baz
Error from server (BadRequest): Unable to find "ingresses" that match label selector "", field selector "foo.bar=baz": "foo.bar" is not a known field selector: only "metadata.name", "metadata.namespace"
```

## 支持的操作

与 [标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels) 和其他选择器一样，字段选择器的条件可以链接成一个逗号列表。用下面命令可以选择所有 `status.phase` 不等于 `Running` 且 `spec.restartPolicy` 等于 `Always` 的 Pods：

```shell
$ kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always
```

## 多种资源类型

你可以跨多种资源类型使用字段选择器。用下面 `kubectl` 命令可以选择所有不在 `default` 命名空间的 Statefulsets 和 Services 对象：

```shell
$ kubectl get statefulsets,services --field-selector metadata.namespace!=default
```
