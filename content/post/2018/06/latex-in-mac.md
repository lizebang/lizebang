---
title: 'LaTeX in Mac'
slug: latex-in-mac
date: 2018-06-27
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - mac
tags:
  - mac
  - latex
  - vscode
keywords:
  - mac
  - latex
  - vscode
---

LaTeX 是一个高质量的排版系统，它包含为生产技术和科学文档而设计的功能。LaTeX 是科学文件通讯和出版的事实标准。

<!--more-->

macOS 上使用的是 MacTex，TUG 推荐完整的 MacTeX。完整的 MacTex 虽然包含的组件比较完整，但是相较与基础版的大太多占用也多太多。这里介绍基础版的安装和配置过程。

## BasicTeX

[BasicTex](http://www.tug.org/mactex/morepackages.html) 的网站，点击 [Download](http://tug.org/cgi-bin/mactex-download/BasicTeX.pkg) 可直接下载，和其他 Apple 软件包一样安装即可。

或者，使用 HomeBrew 进行安装。

```shell
brew cask install basictex
```

## vscode

我使用 vscode 作为我的编辑器，我选择的插件是 [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)，你可用点击链接，也可用通过在 vscode 中按住 `command + p` 然后输入 `ext install latex workshop` 进行安装。

## 安装缺少的组件

### 更新

```shell
sudo tlmgr update --self
```

### 缺少 latexindent

1.编译报错，提示在 PATH 中找不到 `latexindent`

```shell
Can not find latexindent in PATH!
```

解决方法

```shell
sudo tlmgr install latexindent
```

2.安装好后再次编译，此时 `vscode output latex-workshop` 仍然提示找不到 `latexindent`

解决方法

打开 vscode 的 settings 将 `latex-workshop.latexindent.path` 设置成绝对路径，例如: `"latex-workshop.latexindent.path": "/usr/local/texlive/2018basic/bin/x86_64-darwin/latexindent"`

### 缺少 perl 的模块

接着编译，又有报错，需要安装 Log::Log4perl 模块（根据之后的几次报错还需安装其他几个模块）

```shell
Can't locate Log/Log4perl.pm in @INC (you may need to install the Log::Log4perl module)
(@INC contains: ...
```

解决方法

```shell
cpan Log::Log4perl
cpan Log::Dispatch::File
cpan YAML::Tiny
cpan File::HomeDir
cpan Unicode::GCString
```

### 缺少模版

我使用的时候缺少了几个模版以下是安装过程。

编译时的报错

```shell
...
! LaTeX Error: File `xifthen.sty' not found.
...
```

解决方法

```shell
sudo tlmgr install xifthen
sudo tlmgr install ifmtarg
sudo tlmgr install progressbar
sudo tlmgr install titlesec
sudo tlmgr install enumitem
sudo tlmgr install genmisc
```

这上面包含 了 xifthen.sty, ifmtarg.sty, progressbar.sty, titlesec.sty, enumitem, nth.sty，注意 nth.sty 缺失是安装 genmisc 解决的。

至此，你就可以愉快地在 macOS 上使用 LaTeX 了。

### 问题补充

（2019 年 1 月 1 日）出现问题 -- `LaTeX fatal error: spawn xelatex ENOENT, . Does the executable exist?`

解决方法

```shell
brew install expect
```

## 后续

1.推荐一款 macOS 上非常友好的 app -- [Texpad](https://www.texpad.com/)。

2.使用 `brew cask install mactex-no-gui` 代替 `brew cask install basictex`。

## Reference

- [install latexindent](https://tex.stackexchange.com/questions/390433/how-can-i-install-latexindent-on-macos)
- [metacpan Log::Log4perl](https://metacpan.org/pod/release/MSCHILLI/Log-Log4perl-1.21/lib/Log/Log4perl.pm#INSTALLATION)
- [install Log::Log4perl](https://stackoverflow.com/questions/14471128/how-to-install-and-use-log4perl)
- [install nth.sty](https://tex.stackexchange.com/questions/135402/package-nth-is-in-ctan-but-tlmgr-doesnt-find-it)
