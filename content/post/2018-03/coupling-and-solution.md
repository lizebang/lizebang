---
title: "耦合与解耦"
slug: coupling-and-solution
draft: true
date: 2018-03-16
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- design
tags:
- design
keywords:
- design
---

最近写代码时，由于考虑欠佳，代码前前后后改了几次，每次看似小小的修改基本上都是重写了一次！为什么说是重写呢，修改需要修改的部分不就好了吗？因为许多函数只是抽象出了几个简单的接口，实现接口的代码内部依然是严重耦合，所以导致在修改代码时依然得去思考不需修改的那部分代码是否对所修改的部分产生影响，这无形之中就增加了工作量。

<!--more-->

# 耦合
