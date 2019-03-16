---
title: "Kubernetes 中的设计模式 -- 选项模式"
slug: design-patterns-in-kubernetes-optional
draft: true
date: 2019-01-10
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
  - golang
  - design-patterns
keywords:
  - kubernetes
  - design-patterns
  - optional
---

最近，会总结上一年看 Kubernetes 源代码所遇到的一些设计模式。今天要介绍的是 -- 选项模式。

注意，阅读此文章需要读者学过 [golang](https://golang.org)。

<!--more-->

[Code Path](https://github.com/kubernetes/kubernetes/blob/release-1.13/staging/src/k8s.io/apimachinery/pkg/runtime/scheme_builder.go)

> Note: Git Branch -- release-1.13

首先介绍一下选项模式，因为它不是常见的 23 中设计模式中的一种。

## 选项模式
