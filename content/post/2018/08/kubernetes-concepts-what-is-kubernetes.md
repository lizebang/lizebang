---
title: '什么是 Kubernetes ？'
slug: kubernetes-concepts-what-is-kubernetes
date: 2018-08-27
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

原文：https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

这篇文章是 Kubernetes 的概述。

<!--more-->

Kubernetes 是一个可移植、可扩展的开源平台，用于管理容器化的工作负载和服务，使声明性配置和自动化更加便利。它具有庞大的、快速发展的生态系统。Kubernetes 服务、支持和工具广泛可用。

Google 在 2014 年开源了 Kubernetes 项目。Kubernetes 建立在 [Google](https://research.google.com/pubs/pub43438.html) 大规模运行生产工作负载的十五年经验基础上，结合了社区中最佳的创意和实践。

## 为什么我需要 Kubernetes 并且它能做什么？

Kubernetes 有许多功能，它可以被认为是：

- 一个容器平台
- 一个微服务平台
- 一个便携式云平台等等

Kubernetes 提供了以容器为中心的管理环境。它把代表用户工作负载的计算、网络和存储基础架构精心编排起来。这提供了平台即服务（PaaS）的大部分简单性，具有基础架构即服务（IaaS）的灵活性，并支持跨基础架构提供商的可移植性。

## 为什么 Kubernetes 是一个平台？

尽管 Kubernetes 提供了许多功能，总会有新的场景受益于新特性。它可以简化应用程序的工作流，加快开发速度。被大家认可的应用编排通常需要有较强的自动化能力。这就是为什么 Kubernetes 被设计作为构建组件和工具的生态系统平台，以便更轻松地部署、扩展和管理应用程序。

[Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) 允许用户按照自己的方式组织管理对应的资源。 [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) 使用户能够以自定义的描述信息来修饰资源，以适用于自己的工作流，并为管理工具提供检查点状态的简单方法。

此外，[Kubernetes 控制平台](https://kubernetes.io/docs/concepts/overview/components/) 是构建在相同的、开发人员和用户都可以使用的 [APIs](https://kubernetes.io/docs/reference/using-api/api-overview/) 上面。用户可以编写自己的控制器，例如[schedulers](https://github.com/kubernetes/community/blob/master/contributors/devel/scheduler.md)，有他们的 [APIs](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) 并可以被通用的 [命令行工具](https://kubernetes.io/docs/user-guide/kubectl-overview/) 访问到。

这种 [设计](https://git.k8s.io/community/contributors/design-proposals/architecture/architecture.md) 使得许多其他系统能够在 Kubernetes 上面构建。

## Kubernetes 不是什么

Kubernetes 不是一个传统意义上的、包罗万象的平台即服务（PaaS）系统。因为 Kubernetes 在容器级而非硬件级工作，因此它提供了通常 PaaS 提供的一些普遍适用的功能，例如：部署、放缩、负载均衡、记录日志和监控。然而，Kubernetes 不是整体的，默认解决方案是可选的、可插拔的。Kubernetes 提供了构建开发者平台的构建块，但在重要的地方保留了用户选择和灵活性。

Kubernetes：

- Kubernetes 不限制支持的应用程序的类型。Kubernetes 旨在支持各种各样的工作负载，包括无状态，有状态和数据处理工作负载。如果一个应用程序可以在容器中运行，它应该在 Kubernetes 上运行得很好。
- Kubernetes 不部署源代码并且不构建应用程序。持续集成，交付和部署（CI/CD）工作流程由组织文化和偏好以及技术要求决定。
- Kubernetes 不提供应用程序级的服务作为内置服务，例如：中间件（消息总线等）、数据处理框架（Spark 等）、数据库（mysql 等）、高速缓存，也不提供集群存储系统。这些组件可以在 Kubernetes 上运行，并可以通过 Open Service Broker 之类的轻量的机制被运行在 Kubernetes 上的应用程序访问。
- Kubernetes 不指定记录日志、监控以及保健解决方案。虽然它提供了一些集成作为概念以及收集和导出指标机制的验证。
- Kubernetes 不提供或授权一个全面的应用程序配置语言/系统（例如 [jsonnet](https://github.com/google/jsonnet)）。它提供了一个声明性的 API，可以通过任意形式的声明性规范来实现。
- Kubernetes 不提供也不采用任何全面机器配置、保养、管理或自我修复系统。

另外，Kubernetes 不仅仅是一个编排系统。事实上，它消除了编排的需要。编排技术的定义是工作流的执行：第一步做 A，然后做 B，接着做 C。相比之下，Kubernetes 由一组独立的、可组合的控制过程，通过声明式语法使其连续地朝着期望状态驱动当前状态。它不关心从 A 到 C 到具体过程，也不需要集中控制。这使得系统更易于使用且功能更强大，更强健，更具弹性且可扩展。

## 为什么是容器?

为什么你应该使用容器呢？

![Why Containers](/images/2018/08/why-containers.svg)

**传统** 部署应用程序的方式，一般是使用操作系统自带的包管理器在主机上安装应用依赖，之后再安装应用程序。这无疑将应用程序的可执行文件、应用的配置、应用依赖库和应用的生命周期与宿主机操作系统进行了紧耦合。在此情境下，可以通过构建不可改变的虚拟机镜像版本，通过镜像版本实现可预测的发布和回滚，但是虚拟机实在是太重量级了，且镜像体积太庞大，便捷性差。

**新方式** 是基于操作系统级虚拟化而不是硬件级虚拟化方法来部署容器。容器之间彼此隔离并与主机隔离：它们具有自己的文件系统，不能看到彼此的进程，并且它们所使用的计算资源是可以被限制的。它们比虚拟机更容易构建，并且因为它们与底层基础架构和主机文件系统隔离，所以它们可以跨云和操作系统快速分发。

由于容器体积小且启动快，因此可以在每个容器镜像中打包一个应用程序。这种一对一的应用镜像关系拥有很多好处。使用容器，不需要与外部的基础架构环境绑定，因为每一个应用程序都不需要外部依赖，更不需要与外部的基础架构环境依赖。完美解决了从开发到生产环境的一致性问题。

容器同样比虚拟机更加透明，这有助于监测和管理。尤其是容器进程的生命周期由基础设施管理，而不是由容器内的进程对外隐藏时更是如此。最后，每个应用程序用容器封装，管理容器部署就等同于管理应用程序部署。

容器优点摘要：

- **敏捷的应用程序创建和部署**：
  与虚拟机镜像相比，容器镜像更容易创建，提升了硬件的使用效率。
- **持续开发、集成和部署**：
  提供可靠与频繁的容器镜像构建和部署，可以很方便及快速的回滚（由于镜像不可变性）。
- **关注开发与运维的分离**：
  在构建/发布时创建应用程序容器镜像，从而将应用程序与基础架构分离。
- **可观察性**：
  不仅可以显示操作系统级信息和指标，还可以显示应用程序运行状况和其他信号。
- **开发、测试和生产环境的一致性**：
  在笔记本电脑上运行与云中一样。
- **云和操作系统的可移植性**：
  可运行在 Ubuntu, RHEL, CoreOS, 内部部署, Google 容器引擎和其他任何地方。
- **以应用为中心的管理**：
  提升了操作系统的抽象级别，以便在使用逻辑资源的操作系统上运行应用程序。
- **松耦合、分布式、弹性伸缩 [微服务](http://martinfowler.com/articles/microservices.html)**：
  应用程序被分成更小，更独立的部分，可以动态部署和管理 - 而不是巨型单体应用运行在专用的大型机上。
- **资源隔离**：
  通过对应用进行资源隔离，可以很容易的预测应用程序性能。
- **资源利用**：
  高效率和高密度。

## Kubernetes 是什么意思? K8s?

名称 **Kubernetes** 源于希腊语，意为舵手或飞行员， 且是英文 "governor" 和 ["cybernetic"](http://www.etymonline.com/index.php?term=cybernetics)的词根。 **K8s** 是通过将 8 个字母 "ubernete" 替换为 8 而导出的缩写。另外，在中文里，k8s 的发音与 Kubernetes 的发音比较接近。
