---
title: 'SSH 连接到 VirtualBox'
slug: ssh-to-virtualbox
date: 2018-11-18
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - skill
tags:
  - skill
  - ssh
keywords:
  - skill
  - ssh
  - virtualbox
---

VirtualBox 的窗口用起来远不如 terminal 舒服，复制的命令等不能粘贴到 VirtualBox 的窗口中。所以，我就尝试了一下使用 SSH 连接到 VirtualBox，在这里与大家分享一下。

<!--more-->

镜像：ubuntu-16.04.5-server-i386.iso

## 安装 openssh-server

Ubuntu 安装

```shell
sudo apt-get -y update
sudo apt-get install openssh-server
```

CentOS 安装

```shell
sudo yum -y update
sudo yum install openssh-server
```

## 配置端口转发规则

1.打开 VirtualBox 点击 Settings，选择 Network，然后点击 Advanced。

![Step One](/images/2018/11/ssh-to-virtualbox-1.png)

2.如下图所示，将本地 2222 端口流量转发到虚拟机 22 端口。

![Step Two](/images/2018/11/ssh-to-virtualbox-2.png)

## 免密登陆

直接运行下面命令，然后输入密码就完成免密登陆设置了。

```shell
ssh-copy-id -f -p '2222' username@127.0.0.1
```

测试一下.

```shell
ssh -p '2222' username@127.0.0.1
```
