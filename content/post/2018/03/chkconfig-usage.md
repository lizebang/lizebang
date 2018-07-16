---
title: "在 Linux 设置开机启动项"
slug: chkconfig-usage
date: 2018-03-21
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- linux
tags:
- linux
- chkconfig
keywords:
- linux
- chkconfig
---

在服务器上怎样添加一个开机启动项呢？我们可以使用 chkconfig 来做到这一切，下面给大家介绍介绍 chkconfig 的使用方法。

<!--more-->

## 使用 chkconfig

我们先看一个例子 `/etc/init.d/xxx`，仅截取部分

```shell
#! /bin/bash
#
# network       Bring up/down networking
#
# chkconfig: 2345 10 90
xxx
```

注意最后一行，`chkconfig: 2345 10 90`，2345 说明了适用场景

```shell
0 表示：表示关机
1 表示：单用户模式
2 表示：无网络连接的多用户命令行模式
3 表示：有网络连接的多用户命令行模式
4 表示：不可用
5 表示：带图形界面的多用户模式
6 表示：重新启动
```

`10 90` 分别表示开机序列和关机序列，数字均是越小越先被执行。

添加开机项

```shell
chkconfig --add name
```

删除开机项

```shell
chkconfig --del name
```

## 注意

如果无法开机启动，请检查 `/etc/init.d/xxx` 是否可执行。

```shell
$ ls -al /etc/init.d
...
-rw-r--r--   1 ***  staff     0 Apr 19 20:55 xxx   <- 没有 x 属性，不可执行
```

为 xxx 添加 x 属性（Execute）

```
$ chmod +x /etc/init.d/xxx
$ ls -al /etc/init.d
...
-rwxr-xr-x   1 ***  staff     0 Apr 19 20:55 xxx   <- 可执行
```
