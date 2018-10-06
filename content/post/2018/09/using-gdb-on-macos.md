---
title: 'gdb on macOS'
slug: using-gdb-on-macos
date: 2018-09-20
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - mac
tags:
  - mac
  - gdb
  - install
keywords:
  - mac
  - gdb
  - install
---

gdb 无法在 macOS Mojave 上正常使用。

最近在 mac 上使用 gdb 调试程序的时候，突然发现 gdb 不能很好的运行。下面是我遇到的一些坑。

<!--more-->

## 环境

- macOS High Sierra 10.13.6
- Homebrew 1.7.5

## 安装 gdb

1.使用 Homebrew 安装 `gdb 8.0.1`。

```shell
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/9ec9fb27a33698fc7636afce5c1c16787e9ce3f3/Formula/gdb.rb
```

2.禁止 gdb 更新。

```shell
brew pin gdb
```

3.如果未禁用 SIP，请运行下面命令。

```shell
echo  "set startup-with-shell off"  >>〜/ .gdbinit
```

**注意：**最新的 gdb 版本为 8.1，但是 gdb 8.1 似乎并不支持 macOS 10.13，因此需要安装 gdb 8.0.1。下面是运行 gdb 8.1 会遇到的错误：

```shell
During startup program terminated with signal SIGTRAP, Trace/breakpoint trap.
```

## 签名

不进行签名，gdb 运行 run 命令时会出现以下错误。

```shell
(gdb) break main
Breakpoint 1 at 0x100000f56: file inform.c, line 4.
(gdb) run
Starting program: inform
Unable to find Mach task port for process-id 8442: (os/kern) failure (0x5).
 (please check gdb is codesigned - see taskgated(8))
```

1.打开系统工具 Keychain Access

```shell
open /Applications/Utilities/Keychain\ Access.app
```

2.创建证书

![Create Certificate](images/2018/09/create-certificate.png)

3.输入证书名、身份类型、证书类型，并勾选默认覆盖。

![Step Three](images/2018/09/create-certificate-step-one.png)

4.一直确认完成创建。

5.将 Login 中刚刚创建的证书导出。

![Step Five](images/2018/09/create-certificate-step-two.png)

6.将导出的证书导入到 System 中。

![Step Six](images/2018/09/create-certificate-step-three.png)

7.信任证书，选择 "Always Trust"。

![Step Seven](images/2018/09/create-certificate-step-four.png)

8.将证书授予 gdb。

```shell
sudo codesign $(which gdb) -s gdb-cert
```

9.验证 gdb，没有输出即授权成功。

```shell
codesign -v $(which gdb)
```

至此，gdb 就可以正常使用了。

**注意**

1.将 Login 和 System 的 All Iterms 中所有相关的项目都删除然后再重试。

2.杀死 taskgated 程序。

```shell
ps -e | grep taskgated
sudo kill -9 xxx
```
