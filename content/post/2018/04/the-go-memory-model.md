---
title: "The Go Memory Model"
slug: the-go-memory-model
date: 2018-04-19
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- go
tags:
- go
- concurrent
- memory model
keywords:
- go
- concurrent
- memory model
---

Go 内存模型指出，在何时，能确保一个 goroutine 获取到被另一个 goroutine 修改后的同一变量的值。

<!--more-->

原文来自：https://golang.org/ref/mem

## 建议

程序中修改有多个 goroutine 同时访问的数据时必须序列化改访问。

要实现序列化访问，可以用 channel 操作或者使用 sync 和 sync/atomic 中的同步原语保护数据。

如果你必须通过阅读文档的剩余部分去理解你所写程序的行为，你真的太聪明了。

不要太聪明。

### 事件发生顺序

在单个 goroutine 中，读写操作的顺序必须表现得好像按照程序指定的那样。也就是说，只有在重新排序不改变语言规范定义的 goroutine 内的行为时，编译器和处理器才会重新排列这个 goroutine 中读写操作的执行顺序。由于这种重新排序，一个 goroutine 观察到的执行顺序可能与另一个 goroutine 所感知的顺序不同。例如，一个 goroutine 执行了 a = 1; b = 2;，另一个 goroutine 可能观察到 b 值的修改先于 a 值的修改。

为了指定读写操作的必要条件，我们定义了事件发生顺序，它表示一个 Go 程序中内存操作执行的偏序。如果事件 e1 发生在 事件 e2 之前，我们称 e2 发生在 e1 后。如果 e1 不先于 e2 发生也不在 e2 后发生，我们称 e1 和 e2 是并发的。

在单个 goroutine 中，事件发生顺序是程序所期望的顺序。

如果下面两条同时满足，

A read r of a variable v is allowed to observe a write w to v if both of the following hold:

r does not happen before w.
There is no other write w' to v that happens after w but before r.
To guarantee that a read r of a variable v observes a particular write w to v, ensure that w is the only write r is allowed to observe. That is, r is guaranteed to observe w if both of the following hold:

w happens before r.
Any other write to the shared variable v either happens before w or after r.
This pair of conditions is stronger than the first pair; it requires that there are no other writes happening concurrently with w or r.

Within a single goroutine, there is no concurrency, so the two definitions are equivalent: a read r observes the value written by the most recent write w to v. When multiple goroutines access a shared variable v, they must use synchronization events to establish happens-before conditions that ensure reads observe the desired writes.

The initialization of variable v with the zero value for v's type behaves as a write in the memory model.

Reads and writes of values larger than a single machine word behave as multiple machine-word-sized operations in an unspecified order.

Synchronization
Initialization
Program initialization runs in a single goroutine, but that goroutine may create other goroutines, which run concurrently.

If a package p imports package q, the completion of q's init functions happens before the start of any of p's.

The start of the function main.main happens after all init functions have finished.

Goroutine creation
The go statement that starts a new goroutine happens before the goroutine's execution begins.

For example, in this program:

var a string

func f() {
print(a)
}

func hello() {
a = "hello, world"
go f()
}
calling hello will print "hello, world" at some point in the future (perhaps after hello has returned).

Goroutine destruction
The exit of a goroutine is not guaranteed to happen before any event in the program. For example, in this program:

var a string

func hello() {
go func() { a = "hello" }()
print(a)
}
the assignment to a is not followed by any synchronization event, so it is not guaranteed to be observed by any other goroutine. In fact, an aggressive compiler might delete the entire go statement.

If the effects of a goroutine must be observed by another goroutine, use a synchronization mechanism such as a lock or channel communication to establish a relative ordering.
