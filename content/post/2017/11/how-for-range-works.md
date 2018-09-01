---
title: 'for range 的使用'
slug: how-for-range-works
date: 2017-11-05
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
tags:
  - go
keywords:
  - go
---

for range 是一个非常常用的遍历数组切片的方法，但是它有一些比较奇怪的特性，让我们了解一下。

<!--more-->

## 基础用法

for range 的使用场景有下面四种，分别是 array、slice、map 和 channel：

```go
    // array
    for idx, val := range array {
        // do something
    }

    // slice
    for idx, val := range slice {
        // do something
    }

    // map
    for key, val := range mp {
        // do something
    }

    // channel
    for val := range ch {
        // do something
    }
```

## 陷阱一

看下面这段代码，猜猜它的输出是什么？[Play](https://play.golang.org/p/uK7nYTROGTx)

```go
func example() {
    slice := []int{1, 2, 3, 4, 5, 6}

    fmt.Printf("before\t%v\n", slice)

    for _, val := range slice {
        val++
    }

    fmt.Printf("after\t%v\n", slice)
}
```

输出：

```shell
before	[1 2 3 4 5 6]
after	[1 2 3 4 5 6]
```

为什么切片中的值没有加一呢？然后再看看下面这段代码一探究竟。[Play](https://play.golang.org/p/lh7CKGrJAZD)

```go
func example() {
    slice := []int{1, 2, 3, 4, 5, 6}

    for idx := 0; idx < len(slice); idx++ {
        fmt.Printf("index %d value %d address %p\n", idx, slice[idx], &slice[idx])
    }

    fmt.Printf("before\t%v\n", slice)

    for idx, val := range slice {
        fmt.Printf("index %d value %d address %p\n", idx, val, &val)
        val++
    }

    fmt.Printf("after\t%v\n", slice)
}
```

我们将切片值的地址都打印出来了，发现 for range 中 val 的地址和它们不同也并没有发生变化。val 是对 slice 值对拷贝，所以改变 val 的值并不会改变 slice 的值。

```shell
index 0 value 1 address 0x10458000
index 1 value 2 address 0x10458004
index 2 value 3 address 0x10458008
index 3 value 4 address 0x1045800c
index 4 value 5 address 0x10458010
index 5 value 6 address 0x10458014
before	[1 2 3 4 5 6]
index 0 value 1 address 0x10414080
index 1 value 2 address 0x10414080
index 2 value 3 address 0x10414080
index 3 value 4 address 0x10414080
index 4 value 5 address 0x10414080
index 5 value 6 address 0x10414080
after	[1 2 3 4 5 6]
```

## 陷阱二

再看看下面这段代码，也猜猜它的输出是什么？[Play](https://play.golang.org/p/uK7nYTROGTx)

```go
func example() {
    slice := []int{1, 2, 3, 4, 5, 6}

    for key, val := range slice {
        go func() {
            fmt.Printf("%d %d %d\n", key, val, slice[key])
            fmt.Printf("%p %p %p\n", &key, &val, &slice[key])
        }()
    }

    time.Sleep(time.Second)
}
```

输出：

```shell
5 6 6
0x10414020 0x10414024 0x10458014
5 6 6
0x10414020 0x10414024 0x10458014
5 6 6
0x10414020 0x10414024 0x10458014
5 6 6
0x10414020 0x10414024 0x10458014
5 6 6
0x10414020 0x10414024 0x10458014
5 6 6
0x10414020 0x10414024 0x10458014
```

为什么如此奇怪，输出的值全是一样的？这是由多个因素共同导致的。

1.goroutine 中使用的 key 和 val 是外部的 key 和 val，所有 goroutine 共用一组值。

2.调度器锁定在 main，所以在 for range 执行完之前并没有调度执行 goroutine。

3.for range 一直在更新 key 和 val 直到更新到最后一个。

看下面的例子。[Play](https://play.golang.org/p/_S0RCLsaGVo)

```go
func example() {
    slice := []int{1, 2, 3, 4, 5, 6}

    for key, val := range slice {
        go func(key, val int) {
            fmt.Printf("%d %d %d\n", key, val, slice[key])
            fmt.Printf("%p %p %p\n", &key, &val, &slice[key])
        }(key, val)
    }

    time.Sleep(time.Second)
}
```

由于将 key 和 val 当作参数传入，goroutine 拷贝了一份 key 和 val 的值，所以它们能输出期望的值。从输出的地址看，很明显 goroutine 中的 val 的地址和 slice 对应值的地址不同，这里是 for range 的 val 值的拷贝。

```shell
0 1 1
0x10414020 0x10414024 0x10458000
1 2 2
0x10414038 0x1041403c 0x10458004
2 3 3
0x1041405c 0x10414060 0x10458008
3 4 4
0x10414070 0x10414074 0x1045800c
4 5 5
0x10414084 0x10414088 0x10458010
5 6 6
0x10414098 0x1041409c 0x10458014
```

再看第二例子。[Play](https://play.golang.org/p/oViP_IBySQu)

```go
func example() {
    slice := []int{1, 2, 3, 4, 5, 6}

    for key, val := range slice {
        go func() {
            fmt.Printf("%d %d %d\n", key, val, slice[key])
            fmt.Printf("%p %p %p\n", &key, &val, &slice[key])
        }()
        time.Sleep(time.Second)
    }

    time.Sleep(time.Second)
}
```

由于每起一个 goroutine 都让 main goroutine 去 sleep 1s，这时就可以调度到其他 goroutine 上，所以他们也能输出期望的值。从输出的地址看，很明显 goroutine 中的 val 的地址都相同，为 for range 到 val。

```shell
0 1 1
0x10414020 0x10414024 0x10458000
1 2 2
0x10414020 0x10414024 0x10458004
2 3 3
0x10414020 0x10414024 0x10458008
3 4 4
0x10414020 0x10414024 0x1045800c
4 5 5
0x10414020 0x10414024 0x10458010
5 6 6
0x10414020 0x10414024 0x10458014
```

## 题外话

其实，第二个陷阱发生了数据竞争（Data Race），在运行（`go run`）、编译（`go build`）或测试（`go test`）时加上 `-race` 参数，在出现数据竞争时就会发出警报。具体参见 [Data Race in Go](/2018/04/data-race-in-go/)
