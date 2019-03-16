---
title: "flag 中的 Go 函数指针"
slug: function-pointer-in-flag
date: 2019-01-31
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - golang
tags:
  - golang
  - function-pointer
keywords:
  - golang
  - standard-library
  - flag
---

在阅读 flag 包的代码时，看到一处对函数指针的精妙用法。在这里想和大家分享一下。

<!--more-->

## 引出问题

废话不多说，我们直接上代码。

```go
var CommandLine = NewFlagSet(os.Args[0], ExitOnError)

func init() {
	CommandLine.Usage = commandLineUsage
}

func commandLineUsage() {
	Usage()
}

var Usage = func() {
	fmt.Fprintf(CommandLine.Output(), "Usage of %s:\n", os.Args[0])
	PrintDefaults()
}
```

如果上面的代码不清楚含义，请阅读之前讲解 flag 包的文章。

咋一看还真不知道，干了些啥，更不明白为什么要将 Usage() 包一层。

那我们先来看一下下面这段代码。尝试运行一下。删除上面一条语句的注释并注释下面一条语句，再运行一下并对比不同。

```go
package main

import "fmt"

type printer struct {
	print func()
}

var p = &printer{}

var printA = func() {
	println("A")
}

func wrapper() {
	printA()
	fmt.Printf("wrapper printA %p, &printA %p\n", printA, &printA)
}

func init() {
	// p.print = printA
	p.print = wrapper
}

func printB() {
	println("B")
}

func main() {
	fmt.Printf("printA  %p, &printA  %p\n", printA, &printA)
	fmt.Printf("printB  %p\n", printB)
	fmt.Printf("p.print %p, &p.print %p\n", p.print, &p.print)
	fmt.Printf("wrapper %p\n", wrapper)

	printA()
	fmt.Printf("printA  %p, &printA  %p\n", printA, &printA)
	p.print()
	fmt.Printf("p.print %p, &p.print %p\n", p.print, &p.print)

	printA = printB
	printA()
	fmt.Printf("printA  %p, &printA  %p\n", printA, &printA)
	p.print()
	fmt.Printf("p.print %p, &p.print %p\n", p.print, &p.print)
}
```

现在我们好好对比一下两者到不同。

## 带有包装

带有包装时的输出如下：

```shell
printA  0x1093490, &printA  0x115fd78       # here
printB  0x1092fa0
p.print 0x1092e80, &p.print 0x11666c8
wrapper 0x1092e80                           # here
A
printA  0x1093490, &printA  0x115fd78       # here
A
wrapper printA 0x1093490, &printA 0x115fd78 # here
p.print 0x1092e80, &p.print 0x11666c8
B
printA  0x1092fa0, &printA  0x115fd78       # here
B
wrapper printA 0x1092fa0, &printA 0x115fd78 # here
p.print 0x1092e80, &p.print 0x11666c8
```

修改 printA 前，printA 变量的地址为 0x115fd78，printA 中所存当函数地址为 0x1093490。

修改 printA 后，printA 中所存当函数地址变成 0x1092fa0。wrapper 中 printA 发生同样当变化。

所以可以得出，wrapper 中所存的是 printA 变量的地址。

![print with wrapper](/images/2019/01/print-with-wrapper.png)

## 不带包装

不带包装时的输出如下：

```shell
printA  0x1093480, &printA  0x115fd78 # here
printB  0x1092f90
p.print 0x1093480, &p.print 0x11666c8 # here
wrapper 0x1092e80
A
printA  0x1093480, &printA  0x115fd78 # here
A
p.print 0x1093480, &p.print 0x11666c8 # here
B
printA  0x1092f90, &printA  0x115fd78 # here
A
p.print 0x1093480, &p.print 0x11666c8 # here
```

由输出可以得出，p.print 中的存是函数当地址。这也符合 "=" 的本意。将 printA 中的值赋给 p.print。

![print without wrapper](/images/2019/01/print-without-wrapper.png)

## 作业

讲了这么多，那关于 flag 包中的代码片段就留给大家自己思考了。
