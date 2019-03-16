---
title: "apt、dpkg && yum、rpm && pacman 使用详解"
slug: apt-dpkg-yum-rpm-pacman-usage
date: 2017-12-24
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - linux
tags:
  - linux
  - command
keywords:
  - linux
  - command
---

我在这里总结了一下三个比较流行的包管理器的命令，apt、dpkg、yum、rpm 和 ArchLinux 中使用的 pacman，以及 yaourt。

<!--more-->

# apt 与 dpkg (debian、ubuntu 等)

## apt/apt-get 常用命令

| apt 命令         | apt-get 命令         | 命令的功能                          |
| ---------------- | -------------------- | ----------------------------------- |
| apt install      | apt-get install      | 安装软件包                          |
| apt remove       | apt-get remove       | 移除软件包                          |
| apt purge        | apt-get purge        | 移除软件包及配置文件                |
| apt update       | apt-get update       | 刷新存储库索引                      |
| apt upgrade      | apt-get upgrade      | 升级所有可升级的软件包              |
| apt autoremove   | apt-get autoremove   | 自动删除不需要的包                  |
| apt full-upgrade | apt-get dist-upgrade | 在升级软件包时自动处理依赖关系      |
| apt search       | apt-cache search     | 搜索软件包                          |
| apt show         | apt-cache show       | 显示装细节                          |
| apt list         |                      | 列出包含条件的包 (已安装，可升级等) |
| apt edit-sources |                      | 编辑源列表                          |

## deb 安装包

1.依赖问题

```shell
sudo dpkg -i xxx.deb
sudo apt-get intsall -f
```

2.移除软件

```shell
sudo dpkg -r xxx    # 保留软件配置
sudo dpkg -P xxx    # 不保留软件配置
```

3.删除内核

```shell
sudo dpkg --get-selections | grep linux # 查看所安装的内核
sudo apt-get remove xxx
```

# yum 与 rpm (red hat、centos 等)

## yum 常用命令

| yum 命令         | 命令的功能               |
| ---------------- | ------------------------ |
| yum install      | 安装软件包               |
| yum remove       | 移除软件包               |
| yum check-update | 列出所有可更新的软件清单 |
| yum update       | 升级所有可升级的软件包   |
| yum remove       | 删除软件包               |
| yum search       | 搜寻软件包               |
| yum list         | 列出所有可安装的软件包   |
| yum history      | yum 事务历史记录         |

## rpm 安装包

1.依赖问题

```shell
sudo rpm -ivh xxx.rpm
sudo yum install -y xxx.rpm
```

2.移除软件

```shell
sudo yum -y remove xxx
```

or

```shell
sudo yum history list xxx
sudo yum history undo n
```

3.删除内核

```shell
sudo rpm -qa | grep kernel  # 查看所安装的内核
sudo yum remove xxx
```

# pacman (archlinux、manjaro 等)

## 使用 aur

1.编辑 /etc/pacman.conf，添加以下内容

```conf
[archlinuxcn]
packages.SigLevel = Optional TrustAll
Server = [https://mirrors.ustc.edu.cn/archlinuxcn/$arch]
```

2.安装 yaourt 并导入 keyring

```shell
sudo pacman -Syu yaourt
sudo pacman -Sy archlinux-keyring archlinuxcn-keyring
sudo pacman-key --populate archlinux archlinuxcn
sudo pacman-key --refresh-keys
```

## pacman/yaourt 常用命令

| pacman 命令 | yaourt 命令              | 命令的功能 |
| ----------- | ------------------------ | ---------- |
| pacman -S   | yaourt -S                | 安装       |
| pacman -Ss  | yaourt -Ss               | 查询       |
| pacman -R   | yaourt -R                | 删除       |
| pacman -Rs  | 删除包和其依赖           |
| pacman -Syu | 升级软件包               |
| pacman -Ss  | 在仓库中搜索含关键字的包 |
| pacman -Qs  | 搜索已安装的包           |
| pacman -Qi  | 查看有关包的详尽信息     |

## 删除内核

```shell
pacman -Q | grep linux  # 查看所安装的内核
pacman -R xxx
```
