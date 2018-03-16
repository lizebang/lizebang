---
title: "go get 出现 x509: certificate signed by unknown authority 错误"
date: 2018-03-12
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- go
tags:
- go
- ssl
keywords:
- go
- ssl
---

``` shell
$ go get golang.org/x/tour
package golang.org/x/tour: unrecognized import path "golang.org/x/tour" (https fetch: Get https://golang.org/x/tour?go-get=1: x509: certificate signed by unknown authority)
```

怎么回事? 为什么会出现 x509: certificate signed by unknown authority ? 应该怎么解决?

<!--more-->