---
title: "使用 deb 包在 manjaro 上安装 mongodb-compass"
date: 2018-03-06
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- linux
tags:
- linux
- arch
- install
keywords:
- linux
- arch
- install
- mongodb-compass
---

今天在 manjaro 上安装 mongodb-compass 时发现 yaourt mongodb-compass 搜到的两个库都已经无法使用了, 下面我介绍一种安装方法.

<!--more-->

逐条以下命令执行

```shell
curl https://downloads.mongodb.com/compass/mongodb-compass_1.12.0_amd64.deb -o mongodb-compass.deb \
&& bsdtar -xf mongodb-compass.deb \
&& bsdtar -xJf data.tar.xz -C / \
&& sudo chmod 755 /usr
```

其中, `https://downloads.mongodb.com/compass/mongodb-compass_1.12.0_amd64.deb` 为你要安装的版本下载链接