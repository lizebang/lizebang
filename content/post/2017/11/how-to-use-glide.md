---
title: '怎样使用 glide'
slug: how-to-use-glide
date: 2017-11-22
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
tags:
  - go
  - glide
keywords:
  - go
  - glide
---

glide 是很常用的 go 包管理工具，让我们看看然后使用它。

<!--more-->

## 基本使用

常用命令

1.`glide init` 初始化，创建 glide.yaml 文件。

2.`glide install` 安装项目依赖库。

3.`glide get xxx` 安装一个或多个库并添加依赖到 glide.yaml。

4.`glide update` 升级项目依赖库。

使用方法

在项目根目录使用 `glide init` 生成 glide.yaml 文件后，修改 glide.yaml 后，使用 `glide install` 安装依赖库。安装新的库使用 `glide get xxx` 命令，使用 `glide update` 升级项目依赖库。

## [glide.yaml](https://glide.readthedocs.io/en/latest/glide.yaml/)

例子：

```yaml
package: github.com/Masterminds/glide
homepage: https://masterminds.github.io/glide
license: MIT
owners:
  - name: Matt Butcher
    email: technosophos@gmail.com
    homepage: http://technosophos.com
  - name: Matt Farina
    email: matt@mattfarina.com
    homepage: https://www.mattfarina.com
ignore:
  - appengine
excludeDirs:
  - node_modules
import:
  - package: gopkg.in/yaml.v2
  - package: github.com/Masterminds/vcs
    version: ^1.2.0
    repo: git@github.com:Masterminds/vcs
    vcs: git
  - package: github.com/codegangsta/cli
    version: f89effe81c1ece9c5b0fda359ebd9cf65f169a51
  - package: github.com/Masterminds/semver
    version: ^1.0.0
testImport:
  - package: github.com/arschles/assert
```

这些字段的含义是：

- package 此库相对 GOPATH 的位置
- homepage 项目主页
- license 许可证类型
- owners 项目的所有者信息
- ignore 忽略导入的包列表
- excludeDirs 不进行扫码的目录列表
- import 导入的包列表
  - package 导入包的名称
    - 映射到 VCS 远程位置的程序包名称以 .git，.bzr，.hg 或 .svn 结尾，例如 `example.com/foo/pkg.git/subpkg`
    - GitHub，BitBucket，Launchpad，IBM Bluemix Services 和 Go on Google Source 是不需要 VCS 扩展的特殊情况
  - version 要使用的版本
  - repo 指定导入包的位置
  - vcs 要使用的 VCS，例如 git，hg，bzr 或 svn
  - subpackages 库中使用的包的记录
  - os 用于过滤的操作系统列表
  - arch 用于过滤的体系结构列表
- testImport 未在列表中列出的测试中使用的软件包列表

## 对于 golang.org/x/... 之类的解决方法

虽然可以通过 `glide mirror set` 的方式设置镜像库，但是对于我来说失败率奇高，所以我在这里介绍另外一种方法 -- 修改 glide.yaml 文件指定导入包的位置。例如：

```yaml
package: github.com/lizebang/xxx
import:
  - package: golang.org/x/net
    repo: git@github.com:golang/net.git
    vcs: git
```

像上面一样设置过后，我们可以直接使用 `glide install` 完成安装并且不会出错。
