---
title: "安装 DOSBox 及配置"
slug: dosbox-in-mac
date: 2018-10-24
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - tool
tags:
  - mac
  - dosbox
keywords:
  - mac
  - dosbox
---

由于今年开设了《IBM-PC 汇编语言程序设计》这门课，所以安装了 DOSBox，下面介绍一下安装的过程及我的配置。

<!--more-->

## 使用 Homebrew 安装

使用 `brew` 一条命令完成安装

```shell
brew cask install dosbox
```

## 安装 MASM611 和 DEBUGX

1.先介绍简便安装方法，直接下载我打包好的 MASM611 和 DEBUGX 应用程序集合。[Download](/file/MASM.ZIP)

下载好了直接解压，我将其放在了 `HOME` 目录下，即其路径为 `~/MASM`。

2.现在，再介绍自己手动安装的过程。

下载 [MASM611](http://web.cecs.pdx.edu/~bjorn/masm/masm.zip) 和 [DEBUGX](https://sites.google.com/site/pcdosretro/enhdebug/DEBUGX.ZIP?attredirects=0)。

DEBUGX.ZIP 直接解压就可以使用。

masm.zip 解压后需要到 DOSBox 中进行安装才可以使用。

在 HOME 下新建一个 MASM 目录，然后将 DEBUGX 和 masm 放进去，将 masm 改名为 SETUP。

```shell
$ tree -L 1 ~/MASM
/Users/lizebang/MASM
├── DEBUGX  # DEBUGX.ZIP
└── SETUP   # masm.zip

2 directories, 0 files
```

打开 DOSBox 安装 MASM。

```shell
将 ~/MASM 挂载为 C 盘
Z:\>MOUNT C: ~/MASM
切换到 C 盘
Z:\>C:
切换到 SETUP 目录下
C:\>CD SETUP
运行安装程序
C:\SETUP>.\SETUP.EXE
```

安装过程中一直按住回车即可。

## DOSBox 配置

最终的目录大概是下面的样子。

```shell
$ tree -L 1 ~/MASM
/Users/lizebang/MASM
├── DEBUGX
├── MASM611
├── SRC
└── TMP

4 directories, 0 files
```

将下面的内容添加到配置文件 `~/Library/Preferences/DOSBox\ 0.74-2\ Preferences` 中。

```config
MOUNT C: ~/vscode/masm
SET PATH=C:\MASM611\BIN;C:\MASM611\BINR;C:\DEBUGX;%PATH%
SET LIB=C:\MASM611\LIB;%LIB%
SET INCLUDE=C:\MASM611\INCLUDE;%INCLUDE%
SET INIT=C:\MASM611\INIT;%INIT%
SET HELPFILES=C:\MASM611\HELP\*.HLP;%HELPFILES%
SET TMP=C:\TMP
C:
CD SRC
```

至此，DOSBox 可以使用了。
