---
title: 'defer 在做什么'
slug: what-is-defer-doing
date: 2018-08-05
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
tags:
  - go
  - defer
keywords:
  - go
  - defer
---

和其他编程语言一样，Go 具有 if, for, switch, goto 这些常见的控制流机制，而且 Go 还具有一种不太常见的方式 -- defer

<!--more-->

defer 语句将函数调用推送到列表，在外部函数返回后保存在列表中的函数被执行。即使外部函数发生 panic，defer 也能保证列表中的函数被执行。

## 简单了解 defer 的执行过程

让我们看调用下面的例子，会得到怎样的输出。[Play](https://play.golang.org/p/Evkyekwcam_w)

```go
func example() {
    for i := 0; i < 5; i++ {
        defer fmt.Print(i)
    }
}
```

输出：

```shell
43210
```

其实，上面的代码执行顺序等价于：

```go
func example() {
    for i := 0; i < 5; i++ {
        defer fmt.Print(i) ------+
    }                            |
    return                       |
    [                            |
        fmt.Print(5) <-----------+
        fmt.Print(4) <-----------+
        fmt.Print(3) <-----------+
        fmt.Print(2) <-----------+
        fmt.Print(1) <-----------+
    ]
}
```

看下面的图，defer 先将 Print 函数放到一个列表中，等到 example 返回时按照后进先出的规则依次执行。

![defer simple example](/images/2018/08/defer-simple-example.svg)

## 以函数返回值做 defer 函数的参数时

我们依然以一个例子入手。[Play](https://play.golang.org/p/zNyHxwLr7_1)

```go
func example() {
    defer fmt.Println("defer", getZore())
    fmt.Println("example")
}

func getZore() int {
    fmt.Println("getZore")
    return 0
}
```

这次将 `fmt.Println("defer", getZore())` 这个函数放到 defer 列表中让它在 example 返回后输出。但是，它 Println 中调用了 getZore()，那么 getZore() 什么时候被调呢？ 它会和 Println 一样在 example 返回后调用吗？

事实上并不是这样的，他会在设置 defer 的时候就被调用。defer 会将 Println 及它的直接参数放到 defer 列表中。

## defer 时函数的参数

### 闭包传参才会拷贝参数

### 参数拷贝不是深度拷贝

看下面的例子。[Play](https://play.golang.org/p/CdH2ii320Xn)

```go
type obj struct {
    str *string
}

func (o obj) String() string {
    return *o.str
}

func example() {
    s := "1"
    o := obj{str: &s}

    defer func(o obj) {
        fmt.Printf("defer2: obj %v, obj address %p; obj.str %p, obj.str address %p\n", o, &o, o.str, &o.str)
    }(o)

    defer fmt.Printf("defer1: obj %v, obj address %p; obj.str %p, obj.str address %p\n", o, &o, o.str, &o.str)

    s = "2"
    fmt.Printf("example: obj %v, obj address %p; obj.str %p, obj.str address %p\n", o, &o, o.str, &o.str)

    s2 := "3"
    o.str = &s2
    fmt.Printf("example: obj %v, obj address %p; obj.str %p, obj.str address %p\n", o, &o, o.str, &o.str)
}
```

输出：

```shell
example: obj 2, obj address 0x1040c130; obj.str 0x1040c128, obj.str address 0x1040c130
defer1: obj 2, obj address 0x1040c130; obj.str 0x1040c128, obj.str address 0x1040c130
defer2: obj 2, obj address 0x1040c140; obj.str 0x1040c128, obj.str address 0x1040c140
```

从输出来看，defer1 的 obj 地址和 example 的 obj 地址一样，得出 defer1 Printf 并没有拷贝 obj。

而 defer2 闭包函数的 obj 地址和 example 的 obj 不同发生了参数拷贝，并且 obj.str 的 address 也不相同发生了拷贝，但是 defer2 的 obj.str  仅仅拷贝了 example 的 obj.str 的指针值，并不是深度拷贝，所以他们只想同一个 string -- s。当 s 的值发生改变，defer2 也同样会发生改变。

## Reference

- [The Go Blog -- Defer, Panic, and Recover](https://blog.golang.org/defer-panic-and-recover)
- [Go Defer Simplified with Practical Visuals](https://blog.learngoprogramming.com/golang-defer-simplified-77d3b2b817ff)
- [5 More Gotchas of Defer in Go — Part II](https://blog.learngoprogramming.com/5-gotchas-of-defer-in-go-golang-part-ii-cc550f6ad9aa)
