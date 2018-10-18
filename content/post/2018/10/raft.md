---
title: 'Raft'
slug: raft
date: 2018-10-09
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
draft: true
categories:
  - skill
  - distributed
tags:
  - raft
  - distributed
keywords:
  - raft
  - distributed
---

Paxos 算法在很长一段时间一直统治着一致性算法这一领域，然而 Paxos 算法十分复杂令人难以理解并且需要进行大幅的修改才能够应用到实际的系统中，导致了工业界和学术界都对 Paxos 算法感到十分头疼。直到 Raft 算法出现，它更加容易理解并且更容易构建实际的系统。下面我们来学习一下 Raft 算法。

<!--more-->

## 复制状态机

![Replicated State Machines](images/2018/10/raft-figure-1.png)
