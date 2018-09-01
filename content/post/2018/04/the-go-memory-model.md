---
title: 'The Go Memory Model'
slug: the-go-memory-model
date: 2018-04-19
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

原文来自 [official blog](https://golang.org/ref/mem)

## 建议

程序中修改被多个 goroutine 同时访问的数据时必须序列化改访问。

要实现序列化访问，可以用通道操作或者使用 sync 和 sync/atomic 中的同步原语保护数据。

如果你必须通过阅读文档的剩余部分去理解你所写程序的行为，你一定很聪明了。

别自作聪明。

## 事件发生顺序

在单个 goroutine 中，读写操作表现出的顺序必须就像按照程序指定的那样。也就是说，在编程语言规范定义内，重排读写操作不改变此 goroutine 的行为，编译器和处理器才会重新排列此 goroutine 中的这些读写操作的执行顺序。由于这种重新排序，goroutine 内监测到的执行顺序可能与另一个 goroutine 监测到的顺序不同。例如，一个 goroutine 执行了 `a = 1; b = 2;`，另一个 goroutine 可能监测到 b 值的更新先于 a 值的更新。

为了指定读写操作的必要条件，我们定义了 **事件发生顺序** -- Go 程序中内存操作执行的偏序关系。如果事件 e1 发生在事件 e2 之前，我们称 e2 发生在 e1 后。如果 e1 不先于 e2 发生也不在 e2 后发生，我们称 e1 和 e2 是并发的。

在单个 goroutine 中，**事件发生顺序** 是程序所期望的顺序。

存在变量 v，读取 v 的操作 r 和写入 v 的操作 w。

如果满足下面条件，r 被允许去监测 w：

1.r 不会先于 w 发生。

2.不存在其他的写入 v 操作 w' 发生在 w 之后 r 之前。

为了保证 r 监测到特定的 w，需要确保 w 是唯一允许被 r 监测的写入操作。也就是说，如果满足下面条件，r 被保证监测到 w：

1.w 发生在 r 之前。

2.任何对共享变量 r 的写入操作要么发生在 w 之前要么发生在 r 之后。

这对条件要强于第一对，它要求不存在其他写入操作与 w 或 r 并发。

在单个 goroutine 中不存在并发，所以这两组条件是等价的：r 能监测到最近的 w。当多个 goroutines 访问一个共享变量 v 时，他们必须使用同步事件达到 **事件发生顺序** 的条件来确保读取操作监测到想要的写入操作。

初始化变量 v 为 v 类型的零值的行为在内存模型中被视为写入操作。（例如，int 的零值为 0，bool 的零值为 false）

读写值大于一个机器字的操作，其行为表现为未指定顺序地对多个机器字大小的值进行操作。

## 同步

### 初始化

程序的初始化运行在单个 goroutine 中，但那个 goroutine 可能会创建其他并发运行的 goroutines。

如果一个包 p 导入包 q，包 q 的 init 函数结束发生在任何 p 的函数之前。

main.main 函数发生在所有的 init 函数结束之后。

### goroutine 的创建

创建新 goroutine 的 go 语句发生在新 goroutine 执行之前。

举个例子，看下面程序：

```go
var a string

func f() {
    print(a)
}

func hello() {
    a = "hello, world"
    go f()
}
```

调用 hello 将在未来的某个时刻打印 "hello, world"。（可能发生在 hello 返回之后）

### goroutine 的销毁

在程序中，goroutine 的退出不保证发生在任何事件之前。

举个例子，看下面程序：

```go
var a string

func hello() {
    go func() { a = "hello" }()
    print(a)
}
```

对 a 赋值没有使用任何同步事件，所以它不能保证被任何其他的 goroutine 监测到。事实上，一个积极的编译器可能会删除整个 go 语句。

如果一个 goroutine 的作用必须被另一个 goroutine 监测到，使用像锁或者通道通信之类的同步机制来建立顺序关系。

### 通道通信

通道通信是 goroutines 之间同步的主要方法。在特定的通道，每次发送操作都有相应的接收操作与之匹配，这通常发生在不同的 goroutines 间。

**向通道发送数据在相应接收数据完成之前发生。**

看下面程序：

```go
var c = make(chan int, 10)
var a string

func f() {
    a = "hello, world"
    c <- 0
}

func main() {
    go f()
    <-c
    print(a)
}
```

这个程序保证了 "hello, world" 会输出。对 a 的写入操作发生在向 c 发送数据之前，也就保证了在从 c 接收到数据之前，最终就保证了在打印操作执行之前。

**在通道关闭后从通道中接收数据，接收方会收到该通道返回的零值。**

在上一个例子中，用 `close(c)` 代替 `c <- 0` 程序能保证同样的行为。

**从不带缓冲的通道接收数据要在发送数据完成之前发生。**

注意：一个说发送在接收完成前发生，一个说接收在发送完成前发生，这两者不是自相矛盾吗？其实两句话并不矛盾。看上面的程序，当 main goroutine 执行到 `<-c` 时无法从通道中接收到数据，所以会等待发送数据的发生。再看下面的程序，当 main goroutine 执行到 `c <- 0` 时由于通道没有缓冲无法向通道发送数据，所以会等待接收数据的发生。

此程序和上面的相同，但是交换了发送和接收的语句并，且使用了一个不带缓冲的通道。

```go
var c = make(chan int)
var a string

func f() {
    a = "hello, world"
    <-c
}
```

```go
func main() {
    go f()
    c <- 0
    print(a)
}
```

这个程序也保证了 "hello, world" 会输出。对 a 的写入操作在从 c 接收数据之前，也就保证了在向 c 发送数据之前，最终就保证了在打印操作执行之前。

如果此通道是带缓冲的（例子 `var c = make(chan int, 1)`），这个程序不能保证 "hello, world" 会输出。（程序可能输出空字符串，崩溃，或者做其他的事情）

**从缓存容量为 C 的通道第 k 次接收数据在第 k+C 次发送数据完成前发生。**

这条规则可以将上一条规则也涵盖到带缓冲的情况中。它允许用带缓冲的通道来模拟一个技术信号量：通道中的对象数对应活跃使用次数，通道缓冲容量对应最大同时使用次数，发送一个对象获取信号量，接收一个对象释放信号量。这是一个惯用的用来限制并发的方式。

这个程序为工作列表中的每一个对象启动了一个 goroutine，但是 goroutine 使用有限制的通道进行协调，以确保同一时间最多只有三个正在运行的个函数。

```go
var limit = make(chan int, 3)

func main() {
    for _, w := range work {
        go func(w func()) {
            limit <- 1
            w()
            <-limit
        }(w)
    }
    select{}
}
```

### 锁

sync 这个包实现了两种类型的锁，sync.Mutex（互斥锁）和 sync.RWMutex（读写锁）。

**对于任意 sync.Mutex 或 sync.RWMutex 变量，如果 n < m，第 n 次调用 l.Unlock() 在第 m 次调用 l.Lock() 返回之前发生。**

看下面程序：

```go
var l sync.Mutex
var a string

func f() {
    a = "hello, world"
    l.Unlock()
}

func main() {
    l.Lock()
    go f()
    l.Lock()
    print(a)
}
```

这个程序保证了 "hello, world" 会输出。第一次调用 l.Unlock()（在 f 中）在第二次调用 l.Lock()（在 main 中）之前发生，也就保证了在打印操作执行之前。

**对于任何 sync.RWMutex 类型的变量 l 调用 l.RLock ，存在一个这样的 n，使得 l.RLock 在对 l.Unlock 的第 n 次调用返回之后发生，且与其相匹配的 l.RUnlock 在对 l.Lock 的第 n+1 次调用之前发生。**

### 执行一次

sync 包通过 Once 类型为存在多个 goroutine 的初始化提供了安全的机制。多个线程可为特定的 f 执行 once.Do(f)，但只有一个会运行 f()，而其它调用会一直阻塞，直到 f() 返回。

**通过 once.Do(f) 对 f() 的单次调用在对任何其它的 once.Do(f) 调用返回之前发生（返回）。**

看下面程序：

```go
var a string
var once sync.Once

func setup() {
    a = "hello, world"
}

func doprint() {
    once.Do(setup)
    print(a)
}

func twoprint() {
    go doprint()
    go doprint()
}
```

在此程序中，调用 twoprint 会打印两次 "hello, world"。第一次对 twoprint 的调用会运行一次 setup。

### 错误的同步

情况一

```go
var a, b int

func f() {
    a = 1
    b = 2
}

func g() {
    print(b)
    print(a)
}

func main() {
    go f()
    g()
}
```

情况二

```go
var a string
var done bool

func setup() {
    a = "hello, world"
    done = true
}

func doprint() {
    if !done {
        once.Do(setup)
    }
    print(a)
}

func twoprint() {
    go doprint()
    go doprint()
}
```

情况三

```go
var a string
var done bool

func setup() {
    a = "hello, world"
    done = true
}

func main() {
    go setup()
    for !done {
    }
    print(a)
}
```

情况四

```go
type T struct {
    msg string
}

var g *T

func setup() {
    t := new(T)
    t.msg = "hello, world"
    g = t
}

func main() {
    go setup()
    for g == nil {
    }
    print(g.msg)
}
```
