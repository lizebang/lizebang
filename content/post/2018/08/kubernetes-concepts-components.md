---
title: 'Kubernetes 组件'
slug: kubernetes-concepts-components
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

原文：https://kubernetes.io/docs/concepts/overview/components/

本文档概述了 Kubernetes 所需的各种二进制组件, 用于提供齐全的功能。

<!--more-->

## Master 组件

Master 组件提供了集群的控制平台。Master 组件对集群做出全局性决策（例如：调度），并且检测和响应集群事件（当副本控制器的 `replicas` 字段不满足时，启动新的 pod）。

Master 组件能运行在集群中任何机器上。然而，为了简单起见，设置脚本通常会在同一台机器上启动所有主组件，并且不在此机器上运行用户容器。多主节点 VM 的设置请看 [构建高可用性集群](https://kubernetes.io/docs/admin/high-availability/)。

### kube-apiserver

kube-apiserver 是主节点上暴露 Kubernetes API 的组件。它是 Kubernetes 控制平台的前端控制层。

它被设计为水平扩展，即通过部署更多实例来缩放。请看 [构建高可用性集群](https://kubernetes.io/docs/admin/high-availability/)。

### etcd

etcd 提供一致且高可用的键值存储，它被用做 Kubernetes 所有集群数据的后备存储。

它始终为 Kubernetes 集群的 etcd 数据提供备份计划。有关 etcd 的详细信息，请参阅 [etcd 文档](https://github.com/coreos/etcd/blob/master/Documentation/docs.md)。

### kube-scheduler

kube-scheduler 是主节点上的组件，它用于监视未被分配节点的新创建的 pod，并为它们选择有关节点供其运行。

调度决策所考虑的因素包括个人和集体资源需求，硬件/软件/策略约束，亲和力和反亲和性规范，数据位置，工作负载间的干扰和最后期限。

### kube-controller-manager

kube-controller-manager 是主节点上运行控制器的组件。

从逻辑上讲，每个控制器都是一个单独的进程，但为了降低复杂性，它们都被编译成单个二进制文件并在单个进程中运行。

这些控制器包括：

- 节点控制器：负责在节点出现故障时注意和响应。
- 副本控制器：负责为系统中的每个副本控制器对象维护正确数量的 pod。
- 端点控制器：填充端点对象（即连接 Services & Pods）。
- 服务帐户和令牌控制器：为新的命名空间创建默认帐户和 API 访问令牌。

### cloud-controller-manager

[cloud-controller-manager](https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/) 运行与底层云提供商交互的控制器。cloud-controller-manager 二进制文件是 Kubernetes v1.6 版本中引入的 alpha 功能。

cloud-controller-manager 仅运行云提供商特定的控制器循环。您必须在 kube-controller-manager 中禁用这些控制器循环，您可以通过在启动 kube-controller-manager 时将 `--cloud-provider` 标志设置为`external`来禁用控制器循环。

cloud-controller-manager 允许云供应商代码和 Kubernetes 核心彼此独立发展，在以前的版本中，Kubernetes 核心代码依赖于云提供商特定的功能代码。在未来的版本中，云供应商的特定代码应由云供应商自己维护，并与运行 Kubernetes 的云控制器管理器相关联。

以下控制器具有云提供商依赖关系:

- 节点控制器：用于检查云提供商以确定节点是否在云中停止响应后被删除
- 路由控制器：用于在底层云基础架构中设置路由
- 服务控制器：用于创建，更新和删除云提供商负载平衡器
- 数据卷控制器：用于创建，附加和装载卷，并与云提供商进行交互以协调卷

## Node 组件

Node 组件运行在每个节点上，用于维护运行的 pods 并提供 Kubernetes 运行时环境。

### kubelet

kubelet 是运行在集群中每个节点上的代理。它确保每个 pod 中的容器正常运行。

kubelet 采用通过各种机制提供的一组 PodSpecs，并确保这些 PodSpecs 中描述的容器运行且健康。kubelet 不管理不是由 Kubernetes 创建的容器。

### kube-proxy

[kube-proxy](https://kubernetes.io/docs/admin/kube-proxy/) 通过维护主机上的网络规则和执行连接转发来实现 Kubernetes 服务抽象。

### Container Runtime

Container Runtime 是负责运行容器的软件。Kubernetes 支持多种运行时：docker、rkt、runc 和任何 OCI 运行时规范实现的运行时。

## 插件

插件是实现集群功能的 Pod 和 Service。这些 Pods 可以通过 Deployments，ReplicationControllers 等管理。插件对象在 `kube-system` 命名空间中创建。

下面有部分插件的描述。有关可用插件的扩展列表，请参阅 [Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)。

### DNS

虽然其他插件并不是必需的，但所有 Kubernetes 集群都应该具有[Cluster DNS](/docs/concepts/services-networking/dns-pod-service/)，许多示例依赖于它。

Cluster DNS 是一个 DNS 服务器，和您部署环境中的其他 DNS 服务器一起工作，为 Kubernetes 服务提供 DNS 记录。

Kubernetes 启动的容器自动将 DNS 服务器包含在 DNS 搜索中。

### Dashboard

[Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) 是 Kubernetes 集群的基于 Web 的通用 UI。它允许用户管理集群中运行的应用程序以及集群本身，并可以为其排除故障。

### Container Resource Monitoring

[Container Resource Monitoring](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/) 将关于容器的一些常见的时间序列度量值保存到一个集中的数据库中，并提供用于浏览这些数据的界面。

### Cluster-level Logging

[Cluster-level Logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/) 机制负责将容器的日志数据保存到一个集中的日志存储中，该存储能够提供搜索和浏览接口。
