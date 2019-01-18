---
title: 'Data Race in Go'
slug: data-race-in-go
date: 2018-04-19
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - golang
tags:
  - golang
  - concurrent
keywords:
  - golang
  - concurrent
  - data race
---

数据竞争是并发系统中最常见也最难调试的错误之一。当至少两个 goroutine 同时访问同一个变量并且至少有一个访问是写入时，就会发生数据争用。

<!--more-->
