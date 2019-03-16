---
title: "go temporary address"
slug: go-temporary-address
date: 2019-01-18
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - golang
tags:
  - golang
  - temporary-address
keywords:
  - golang
  - temporary-address
---

在很久之前遇到过一个很奇怪的问题，最近忆起终得答案，特记录于此。

<!--more-->

让我们先看一段代码。

```go
package main

type people struct{}

func (p *people) hello() {
	print("hello")
}

func main() {
	// wrong
	(people{}).hello()

	// right
	p := people{}
	p.hello()
}
```

初看到代码，可能会很好奇，上下这两种发式为什么会一对一错呢？

```go
(people{}).hello()
```

因为 `people{}` 只是一个临时变量，不能取到它的地址，所以无法调用 `(p *people) hello()`。然而，`p.hello()` 中 `p` 的地址是事实存在的，使用可以调用 `(p *people) hello()`。

## Reference

- https://reading.developerlearning.cn/reading/20180321/readme/
- https://stackoverflow.com/questions/10535743/address-of-a-temporary-in-go
- https://stackoverflow.com/questions/40926479/take-the-address-of-a-character-in-string
- https://golang.org/ref/spec#Address_operators
