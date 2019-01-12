---
title: 'Kubernetes 群集管理概述'
slug: kubernetes_concepts_cluster-administration_cluster-administration-overview
date: 2018-09-05
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

原文：https://kubernetes.io/docs/concepts/cluster-administration/cluster-administration-overview/

群集管理概述适用于创建或管理 Kubernetes 群集的任何人。它假定你对核心 Kubernetes [概念](https://kubernetes.io/docs/concepts/) 有一定的了解。

<!--more-->

## 规划集群

有关如何规划、设置以及配置 Kubernetes 集群的例子请查看指南 [选择正确的解决方案](https://kubernetes.io/docs/setup/pick-right-solution/)。本文中列出的解决方案成为 **发行版**。

在查看指南之前，请注意以下几点：

- 你只是想要在计算机上试用 Kubernetes，还是想构建高可用性的多节点集群？请选择最适合您需求的发行版。
- **如果你要设计高可用**，请了解如何配置 [多区域集群](https://kubernetes.io/docs/concepts/cluster-administration/federation/).
- 你是否将使用 **托管的 Kubernetes 集群**（例如 Google Kubernetes Engine）或 **托管自己的集群**？
- 你的群集是在 **本地** 还是 **在云中（IaaS）**？Kubernetes 不直接支持混合集群。不过，你可以设置多个群集。
- **如果你在本地配置 Kubernetes**，请考虑哪种 [网络模型](https://kubernetes.io/docs/concepts/cluster-administration/networking/) 最合适。
- 你是否会在 **裸机硬件** 或 **虚拟机（VM）** 上运行 Kubernetes？
- 你 **只想运行集群**，或者你 **希望积极开发 Kubernetes 项目代码**？如果是后者，请选择积极开发的发行版。有些发行版本只使用二进制版本，但提供了更多种选择。
- 熟悉运行群集所需的 [组件](https://kubernetes.io/docs/admin/cluster-components/)。

注意：并不是所有的发行版都得到了积极维护。请选择最新且已测试的 Kubernetes 发行版。

## 管理集群

- [管理集群](https://kubernetes.io/docs/tasks/administer-cluster/cluster-management/) 描述了有关集群生命周期的几个主题：创建一个新集群、升级集群主节点和工作节点、执行节点维护（例如，内核升级）以及升级正在运行集群的 Kubernetes API 版本。
- 了解如何 [管理节点](https://kubernetes.io/docs/concepts/nodes/node/)。
- 了解如何设置和管理共享群集的 [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/)。

## 保护集群

- [证书](https://kubernetes.io/docs/concepts/cluster-administration/certificates/) 介绍了使用不同工具生成证书的步骤。
- [Kubernetes 容器环境](https://kubernetes.io/docs/concepts/containers/container-environment-variables/) 介绍了 Kubernetes 节点上 Kubelet 管理容器的环境。
- [控制对 Kubernetes API 的访问](https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/) 介绍了如何为用户和服务帐户设置权限。
- [身份验证](https://kubernetes.io/docs/reference/access-authn-authz/authentication/) 介绍了 Kubernetes 中的身份验证，包括各种身份验证选项。
- [授权](https://kubernetes.io/docs/reference/access-authn-authz/authorization/) 与身份验证分开，并控制 HTTP 调用的处理方式。
- [使用许可 admission 控制器](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) 介绍了在认证和授权后拦截对 Kubernetes API 服务器的请求的插件。
- [在 Kubernetes 集群中使用 Sysctls](https://kubernetes.io/docs/concepts/cluster-administration/sysctl-cluster/) 介绍了管理员如何使用 `sysctl` 命令 行工具设置内核参数。
- [审计](https://kubernetes.io/docs/tasks/debug-application-cluster/audit/) 介绍了如何与 Kubernetes 的审计日志进行交互。

## 保护 kubelet

- [主节点通讯](https://kubernetes.io/docs/concepts/architecture/master-node-communication/)
- [TLS 引导](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/)
- [kubelet 身份验证/授权](https://kubernetes.io/docs/admin/kubelet-authentication-authorization/)

## 可选的集群服务

- [DNS 集成](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) 介绍了直接将 DNS 域名解析为 Kubernetes 服务。
- [记录日志和监控群集活动](https://kubernetes.io/docs/concepts/cluster-administration/logging/) 介绍了在 Kubernetes 中日志如何工作以及如何实现它。
