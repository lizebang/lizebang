---
title: "Kubernetes 注解"
slug: kubernetes_concepts_overview_working-with-objects_annotations
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/

你可以使用 Kubernetes 注解将任何非标识性元数据关联到对象上。使用客户端（如工具和库）可以检索到这些元数据。

<!--more-->

## 关联元数据到对象

你可以使用标签或注解将元数据关联到 Kubernetes 对象上。标签可以用于选择对象和查找满足特定条件的对象集合。相反，注解不用于识别和选择对象。注解中的元数据可大可小、可结构化也可非结构化，并且可以包含标签不允许的字符。

annotation 和 label 一样都是 key/value 键值对映射结构：

```json
"metadata": {
  "annotations": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```

以下列出了一些可以记录在 annotation 中的对象信息：

- 声明配置层管理的字段。使用注解关联这类字段可以用于区分客户端或服务器设置的默认值、自动生成的字段以及自动调整大小或自动调整系统设置的字段。
- 构建信息、版本信息或镜像信息。例如：时间戳、版本号、git 分支、PR 序号、镜像哈希值以及仓库地址。
- 记录日志、监控、分析或审计存储仓库的指针。
- 用于调试当客户端库或工具的信息。例如：名称、版本和构建信息。
- 用户信息，以及工具或系统来源信息。例如：来自其他生态系统组件相关对象的 URL。
- 轻量级部署工具元数据。例如：配置或检查点。
- 负责人的电话或联系方式、能找到相关信息的目录条目信息（例如，团队网站）。
- 从终端用户到最终实现的指令，用于修改行为或使用非标准特性。

如果不使用注解，你也可以将以上类型的信息存放在外部数据库或目录中，但这样做不利于创建用于部署、管理、内部检查的共享工具和客户端库。

## 语法和字符集

_Annotations_ 是键/值对。有效的 annotation 键有两部分：可选的前缀和名称，用斜杠（`/`）分隔。名称部分是必须的，并且必须小于等于 63 个字符，开始和结尾的字符必须是字母或数字，中间可以使用字母、数字、破折号、下划线或句点（即，名称满足正则 `^[:alnum:][\w-.]{0,61}[:alnum:]$`）。前缀是可选的。如果指定定话，前缀必须是 DNS 子域：一系列由点 `.` 分隔的 DNS 标签，总长度不超过 253 个字符，后面跟着一个斜线 `/`。

如果省略了前缀，这个标签的 key 会被推断为用户私有。自动化系统组件（例如，`kube-scheduler`、`kube-controller-manager`、`kube-apiserver`、`kubectl` 或第三方自动化组件），它们添加到最终用户对象上的标签必须指定前缀。

`kubernetes.io/` 和 `k8s.io/` 前缀是为 `Kubernetes` 核心组件预留的。
