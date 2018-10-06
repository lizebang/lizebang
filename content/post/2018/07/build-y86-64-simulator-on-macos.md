---
title: 'macOS 上编译 Y86-64 模拟器'
slug: build-y86-64-simulator-on-macos
date: 2018-07-30
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - mac
tags:
  - tool
  - y86-64
  - build
keywords:
  - mac
  - csapp
  - y86-64
  - build
---

在阅读《深入理解计算机（第三版）》第四章的时候，和它配套的有一个辅助的工具需要自己编译 -- Y86-64 模拟器（Y86-64 Simulator）。当我在网上搜索相关教程时，只找到了在 Ubuntu 编译 Y86-64 模拟器的教程没有 macOS 下编译的教程，所以遇到了不少坑，下面一步步填坑的过程。

<!--more-->

## 下载源码

在《深入理解计算机（第三版）》的官网就可以找到所有章节所需要的资料：http://csapp.cs.cmu.edu/3e/students.html 源码下载：[sim.tar](http://csapp.cs.cmu.edu/3e/sim.tar)

我已经将在 macOS 上编译时需要的变量修改过并打包  放到了 GitHub 上，地址：https://github.com/lizebang/Y86-Simulator-macOS

GitHub 上下载的直接编译即可，下面讲讲从官网上下载的怎样编译。

解压 sim.tar

```shell
tar -xf sim.tar
```

## 阅读文档

阅读文档非常重要，你可用在文档中找到很多有用的东西。打开文件夹 sim 中的 README 文件。

### 文档大意

这个文件夹包含了学生分发版的 Y86-64 工具。

Y86-64 模拟器编译成 `终端` 和 `图形界面` 两种。

### 终端

编译成终端比较简单，直接 `GUIMODE=-DHAS_GUI`、`TKLIBS=-L/usr/lib -ltk -ltcl` 以及 `TKINC=-isystem /usr/include/tcl8.5` 注释掉然后编译。

注释不需要的变量

| ![makefile](/images/2018/07/makefile.png) | ![makefile tty](/images/2018/07/makefile-tty.png) |
| :---------------------------------------: | :-----------------------------------------------: |
| 修改前                                    | 修改后                                            |

编译

```shell
make clean; make
```

### 图形界面

最后我们来编译 Y86-64 模拟器。

在 `sim` 目录下执行 `make clean; make` 进行编译

#### 修改 Makefile 并编译

把 `TKINC` 值设为 `TKINC=-isystem /System/Library/Frameworks/Tk.framework/Versions/8.5/Headers`。

| ![makefile](/images/2018/07/makefile.png) | ![makefile gui](/images/2018/07/makefile-gui.png) |
| :---------------------------------------: | :-----------------------------------------------: |
| 修改前                                    | 修改后                                            |

#### 错误 ld: library not found for -lfl

具体报错信息如下：

```shell
gcc -O2 -c yas-grammar.c
gcc -Wall -O2 yas-grammar.o yas.o isa.o -lfl -o yas
ld: library not found for -lfl
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[1]: *** [yas] Error 1
make: *** [all] Error 2
```

这是因为我们找不到 `libfl.a` 文件，Mac OS X 上并没有 `libfl.a`，我们使用 `libl.a` 来代替。

创建软链接：

`sudo ln -s /usr/lib/libl.a /usr/lib/libfl.a`

#### 错误 'X11/Xlib.h' file not found

具体报错信息如下：

```shell
/usr/include/tk.h:78:11: fatal error: 'X11/Xlib.h' file not found
#       include <X11/Xlib.h>
                ^~~~~~~~~~~~
1 error generated.
```

忘记修改 `TKINC` 值，只需把 `Makefile` 中的 `TKINC` 值设为 `TKINC=-isystem /System/Library/Frameworks/Tk.framework/Versions/8.5/Headers`。

# Reference

- http://linux-digest.blogspot.com/2013/01/using-flex-on-os-x.html
