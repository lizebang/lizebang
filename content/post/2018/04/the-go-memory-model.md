---
title: "The Go Memory Model"
slug: the-go-memory-model
date: 2018-04-19
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- go
tags:
- go
- concurrent
- memory model
keywords:
- go
- concurrent
- memory model
---

Go 的内存模型定义了一些情景 -- 一个 goroutine 读取某一变量的值并持续观察到其他 goroutine 对这一变量修改。

<!--more-->
