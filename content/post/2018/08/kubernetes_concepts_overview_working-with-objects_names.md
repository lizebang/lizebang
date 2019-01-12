---
title: 'Kubernetes 对象名称'
slug: kubernetes_concepts_overview_working-with-objects_names
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/names/

在 Kubernetes REST API 中的所有对象都由 Name 和 UID 明确标识。

<!--more-->

对于不唯一的用户提供的属性，Kubernetes 提供了 [labels](https://kubernetes.io/docs/user-guide/labels) 和 [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) 字段。

有关 Names 和 UIDs 的精确语法规则，请看 [标识符设计文档](https://git.k8s.io/community/contributors/design-proposals/architecture/identifiers.md)

## Names

客户端提供的字符串，用于引用资源 URL 中的对象，例如：`/api/v1/pods/some-name`。

同一时间，同一类型的对象名称不能相同。但是，如果删除该对象，则可以创建具有相同名称的新对象。

按照惯例，Kubernetes 资源的名称最大长度为 253 个字符，并由小写字母、数字、`-` 和 `.` 组成，但是某些资源具有更多特定限制。

## UIDs

UIDs 是 Kubernetes 系统生成的字符串，用于唯一标识对象。

在 Kubernetes 集群的整个生命周期中创建的每个对象都具有不同的 UID。它旨在区分类似实体的历史事件。
