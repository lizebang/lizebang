---
title: 'Kubernetes Pod Preset'
slug: kubernetes_concepts_workloads_pods_podpreset
date: 2018-09-17
draft: true
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

**Kubernetes v1.11** 原文：https://v1-11.docs.kubernetes.io/docs/concepts/workloads/pods/podpreset/

本文是关于 PodPresets 的概述，该对象在创建时将特定信息注入到 pod 对象中。该消息可以包含 secrets、volumes、volume mounts 以及 environment variables。

<!--more-->

## 理解 Pod Presets
