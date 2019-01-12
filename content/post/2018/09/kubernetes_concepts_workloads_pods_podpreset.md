---
title: 'Kubernetes Pod Preset'
slug: kubernetes_concepts_workloads_pods_podpreset
date: 2018-09-17
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

原文：https://kubernetes.io/docs/concepts/workloads/pods/podpreset/

本文是关于 PodPresets 的概述，该对象在创建时将特定信息注入到 pod 对象中。该消息可以包含 secrets、volumes、volume mounts 以及 environment variables。

<!--more-->

## 理解 Pod Presets

`Pod Presets` 是一种 API 资源，用于在创建时将运行时需要的其他资源注入到 Pod 中。你可以使用 [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) 指定要应用给定 Pod Preset 的 Pods。

使用 Pod Preset 允许 pod 模版作者不必明确提供每个 pod 的所有信息。这样，使用特定服务的 pod 模版的作者不需要知道有关服务的所有细节。

有关它背后的更多信息，请查看 [PodPreset 的设计方案](https://git.k8s.io/community/contributors/design-proposals/service-catalog/pod-preset.md)。

## 工作原理

Kubernetes 提供了一个 admission 控制器（`PodPreset`），启用后，将 Pod Presets 应用于传入的 pod 创建请求。发生 pod 创建请求时，系统会执行以下操作：

1.检索所有可供使用的 `PodPresets`。

2.检查是否存在任何 `PodPreset` 的 label selectors 与正在创建的 pod 上的 labels 匹配。

3.尝试将 `PodPreset` 定义的各种资源合并到正在创建的 Pod 中。

4.出错时，抛出一个记录 pod 上合并错误的事件，并创建 pod 且不从 `PodPreset` 注入任何资源。

5.将被修改的 Pod 规格（spec）结果注解到 pod 上，以指明它以被 `PodPreset` 修改。注解的形式 `podpreset.admission.kubernetes.io/podpreset-<pod-preset name>: "<resource version>"`

每个 Pod 可以被零或多个 Pod Presets 匹配，并且每个 `PodPreset` 可以被作用于零或多个 pods。当一个 `PodPreset` 被作用于一个或更多 Pods，Kubernetes 会修改 Pod Spec。对于 `Env`、`EnvFrom` 和 `VolumeMounts` 的更改，Kubernetes 会修改 Pod 中所有容器的规格；对于 `Volume` 的更改，Kubernetes 会修改 Pod Spec。

> 注意：Pod Preset 能够在适当的时候修改 Pod 规格中的 `.spec.containers` 字段。Pod Preset 中的资源定义不会应用于 `initContainers` 字段。

### 禁用指定 Pod 的 Pod Preset

在某些情况下，你希望 Pod 不会被任何 Pod Preset 更改。在这种情况下，你可以在 Pod Spec 中添加注解：`podpreset.admission.kubernetes.io/exclude: "true"`。

## 启用 Pod Preset

要在集群中使用 Pod Preset，你必须确保以下内容：

1.你已经开启 API 类型 `settings.k8s.io/v1alpha1/podpreset`。例如，这可以通过在 API server 的 `--runtime-config` 选项中包含 `settings.k8s.io/v1alpha1=true` 来实现。

2.你已经开启 admission 控制器 `PodPreset`。实现它的一种方法是在 API server 指定的 `--enable-admission-plugins` 选项值中包含 `PodPreset`。

3.你已经通过在你将要使用的命名空间中创建 `PodPreset` 对象来定义 Pod Presets。
