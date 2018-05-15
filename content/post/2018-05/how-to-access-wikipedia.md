---
title: "如何访问维基百科"
slug: "how-to-access-wikipedia"
date: 2018-05-15
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- wikipedia
tags:
- wikipedia
keywords:
- access wikipedia
---

维基百科目前被 GFW 通过 DNS 污染的方式封锁，怎样可以正常访问呢？

<!--more-->

我们通过修正域名解析的方式可以恢复对维基百科对正常访问。

## hosts 文件 <- 推荐

1.hosts 路径

`Windows`: `C:\Windows\System32\drivers\etc\hosts`

`类 Unix`: `/etc/hosts`

2.修改 hosts

在桌面设备上可以只添加下文的前半部分，在移动设备上可以只添加下文的后半部分。

```hosts
198.35.26.96 zh.wikipedia.org #中文维基百科
198.35.26.96 zh-yue.wikipedia.org #粤文维基百科
198.35.26.96 wuu.wikipedia.org #吴语维基百科
198.35.26.96 ug.wikipedia.org #维吾尔文维基百科
198.35.26.96 ja.wikipedia.org #日文维基百科
198.35.26.96 zh.wikinews.org #中文维基新闻
198.35.26.96 zh.m.wikipedia.org #中文维基百科移动版
198.35.26.96 zh-yue.m.wikipedia.org #粤文维基百科移动版
198.35.26.96 wuu.m.wikipedia.org #吴语维基百科移动版
198.35.26.96 ug.m.wikipedia.org #维吾尔文维基百科移动版
198.35.26.96 ja.m.wikipedia.org #日文维基百科移动版
198.35.26.96 zh.m.wikinews.org #中文维基新闻移动版
```

3.保存文件

* 重新启动设备
* 执行下列命令
  * Windows: `ipconfig /flushdns`
  * macOS: `lookupd -flushcache` 或 `dscacheutil -flushcache`
  * Linux: `service nscd restart`
    * Ubuntu: `sudo /etc/init.d/dns-clean start`
  * Android: `开启再关闭飞行模式`

## DNS 设置

| 服务提供者 | 首选IP地址 | 备选IP地址 |
| :---: | :---: | :---: |
| [AIXYZ DNS](https://aixyz.com/) | 115.159.146.99（南方） | 123.206.21.48（北方） |
| [中国科学技术大学](https://zh.wikipedia.org/wiki/中国科学技术大学) DNS | 202.38.93.153（教育网） | 202.141.162.123 （中国电信） |

## 代理服务器

* 翻墙软件
* HTTP 代理
* VPN
* Shadowsocks
* Tor
* 网页代理

## 镜像网站

[维基百科拷贝网站](https://zh.wikipedia.org/wiki/Wikipedia:维基百科拷贝网站)
