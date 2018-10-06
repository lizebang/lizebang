---
title: '怎样使用 pprof'
slug: how-to-use-pprof
date: 2018-08-20
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
  - tool
tags:
  - go
  - tool
  - pprof
keywords:
  - go
  - tool
  - pprof
---

go 自带了非常好用的分析工具 -- pprof，使用它我们可以很轻松地获取到程序运行时 CPU、内存的信息。

<!--more-->

原文 [official blog](https://blog.golang.org/profiling-go-programs)

## 准备工作

安装 [graphviz](https://www.graphviz.org/)

```shell
# macOS
brew install graphviz
```

拉取测试用例

```shell
git clone git@github.com:rsc/benchgraffiti.git $GOPATH/benchgraffiti
cd $GOPATH/benchgraffiti/havlak
```

## 获取运行时详细信息方法

查看运行时详细信息的方法有：

- 使用 [net/http/pprof](https://golang.org/pkg/net/http/pprof/) 和 [runtime/pprof](https://golang.org/pkg/runtime/pprof/) 两个包都可以得到可用信息。
- 使用 [go test](https://golang.org/cmd/go/#hdr-Test_packages) 加上相应参数可以直接得到相应的测试信息，例如：`go test -cpuprofile cpu.prof -memprofile mem.prof -bench .`。

### net/http/pprof 使用简介

导入 net/http/pprof 包

```shell
import _ "net/http/pprof"
```

运行下面函数将获取到的信息展现出来

```shell
go func() {
	log.Println(http.ListenAndServe("localhost:6060", nil))
}()
```

执行后可以在浏览器中打开 http://localhost:6060/debug/pprof/ ，或者其他使用方法查看官网 [net/http/pprof](https://golang.org/pkg/net/http/pprof/)。

### runtime/pprof 使用简介

在文件中加入一部分代码，改写成下面形式：

```go
var cpuprofile = flag.String("cpuprofile", "", "write cpu profile to `file`")
var memprofile = flag.String("memprofile", "", "write memory profile to `file`")

func main() {
    flag.Parse()
    if *cpuprofile != "" {
        f, err := os.Create(*cpuprofile)
        if err != nil {
            log.Fatal("could not create CPU profile: ", err)
        }
        if err := pprof.StartCPUProfile(f); err != nil {
            log.Fatal("could not start CPU profile: ", err)
        }
        defer pprof.StopCPUProfile()
    }

    // ... rest of the program ...

    if *memprofile != "" {
        f, err := os.Create(*memprofile)
        if err != nil {
            log.Fatal("could not create memory profile: ", err)
        }
        runtime.GC() // get up-to-date statistics
        if err := pprof.WriteHeapProfile(f); err != nil {
            log.Fatal("could not write memory profile: ", err)
        }
        f.Close()
    }
}
```

运行

```shell
go build -o xxx xxx.go
./xxx -cpuprofile=cpuprofile.prof -memprofile=memprofile.prof
```

然后使用 [go tool prof](https://golang.org/doc/diagnostics.html#profiling) 调试。

我在这里都使用 runtime/pprof 进行测试优化。

## 编译 havlak1、测试并优化

编译、测试：

```shell
go build havlak1.go
time ./havlak1
```

结果：

```shell
# of loops: 76000 (including 1 artificial root node)
./havlak1  35.84s user 0.59s system 128% cpu 28.438 total
```

程序运行了 36.43s。

获取 cpu 信息

```shell
go build -o havlak1 havlak1.go
./havlak1 -cpuprofile=cpuprofile1.prof
```

查看信息

```shell
go tool pprof havlak1 cpuprofile1.prof
File: havlak1
Type: cpu
Time: Aug 21, 2018 at 10:45am (CST)
Duration: 27.29s, Total samples = 32.59s (119.42%)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top10
Showing nodes accounting for 22310ms, 68.46% of 32590ms total
Dropped 122 nodes (cum <= 162.95ms)
Showing top 10 nodes out of 89
      flat  flat%   sum%        cum   cum%
    4260ms 13.07% 13.07%     8280ms 25.41%  runtime.scanobject
    3350ms 10.28% 23.35%     3730ms 11.45%  runtime.mapaccess1_fast64
    2920ms  8.96% 32.31%    17700ms 54.31%  main.FindLoops
    2440ms  7.49% 39.80%     6150ms 18.87%  runtime.mallocgc
    2390ms  7.33% 47.13%     2390ms  7.33%  runtime.heapBitsForObject
    1820ms  5.58% 52.72%     2100ms  6.44%  runtime.greyobject
    1800ms  5.52% 58.24%     4170ms 12.80%  main.DFS
    1420ms  4.36% 62.60%     3780ms 11.60%  runtime.mapassign_fast64ptr
     980ms  3.01% 65.60%     1250ms  3.84%  runtime.evacuate_fast64
     930ms  2.85% 68.46%      930ms  2.85%  runtime.memmove
```

topN 是 pprof 中比较常用也比较实用的命令之一。每一行代表的是一个函数的调用信息，这六列分别表示

- flat 函数运行的时间
- flat% 函数运行的时间占总运行时间的比例
- sum% 前 n 项 flat% 之和
- cum 函数从调用到退出的时间，包括函数中调用其他函数的时间
- cum% 函数从调用到退出的时间占总运行时间的比例
- 函数名

如果想按第四、五列信息排序，加上 `-cum` 参数即可。

```shell
(pprof) top5 -cum
Showing nodes accounting for 2.98s, 9.14% of 32.59s total
Dropped 122 nodes (cum <= 0.16s)
Showing top 5 nodes out of 89
      flat  flat%   sum%        cum   cum%
         0     0%     0%     17.88s 54.86%  main.main
         0     0%     0%     17.88s 54.86%  runtime.main
         0     0%     0%     17.70s 54.31%  main.FindHavlakLoops
     2.92s  8.96%  8.96%     17.70s 54.31%  main.FindLoops
     0.06s  0.18%  9.14%     12.86s 39.46%  runtime.systemstack
```

我们还可以使用 `web` 命令将数据绘成一张 SVG 格式的图片然后在浏览器中打开。

```shell
(pprof) web
```

[the full graph](images/cpuprofile1.svg)

![cpuprofile1](/images/2018/08/cpuprofile1.svg)

图中每个框对应一个函数，框的大小根据函数运行的时间决定。一个框 x 指向另一个框 y 代表，函数 x 调用函数 y，连线上的数字代表执行时间。

从这个局部可以看出，整个程序在 map 操作上花费的时间非常长，可以用 `(pprof) web map` 查看 map 相关操作。

我们也可以查看 runtime.mapaccess1_fast64 函数的局部信息。

```shell
(pprof) web runtime.mapaccess1_fast64
```

![cpuprofile1 mapaccess1_fast64](/images/2018/08/cpuprofile1-mapaccess1_fast64.svg)

我们可以看到 main.FindLoops 和 main.DFS 对 runtime.mapaccess1_fast64 的调用。

我们可以先看一下 main.DFS，它是一个比较短的函数。

用 `list main.DFS` 可以展示那一部分代码片段，其实 list 是通过正则匹配到所有包含 `DFS` 的函数。

```shell
         .          .    236:// DFS - Depth-First-Search and node numbering.
         .          .    237://
         .          .    238:func DFS(currentNode *BasicBlock, nodes []*UnionFindNode, number map[*BasicBlock]int, last []int, current int) int {
         .          .    239:   nodes[current].Init(currentNode, current)
      40ms      230ms    240:   number[currentNode] = current
         .          .    241:
         .          .    242:   lastid := current
     940ms      940ms    243:   for _, target := range currentNode.OutEdges {
     220ms      1.76s    244:           if number[target] == unvisited {
      50ms      4.17s    245:                   lastid = DFS(target, nodes, number, last, lastid+1)
         .          .    246:           }
         .          .    247:   }
     280ms      910ms    248:   last[number[currentNode]] = lastid
      20ms       20ms    249:   return lastid
         .          .    250:}
```

前三列分别代表

- 运行该行所需要的时间
- 运行该行及其调用的函数所用的时间
- 文件中的行号

我们可以使用 `disasm` 显示出函数的反汇编代码，这可以帮助您查看哪些指令很开销很大。同时，`weblist` 可以在浏览器中显示想查看的函数及其反汇编代码。

我们可以看到 245 行 DFS 函数花费对时间比较长，因为这是一个递归遍历。除了递归，240、244、248 行访问 map 的时间也比较长。对于特定查找，map 并不是一个很好的选择。由于创建时分配给它们唯一的序号，我们可以使用由序号索引的切片来代替 map。当数组或者切片也能完成任务时就没有理由去使用 map。

## 编译 havlak2、测试

编译、测试：

```shell
go build -o havlak2 havlak2.go
time ./havlak2
```

结果：

```shell
# of loops: 76000 (including 1 artificial root node)
./havlak2  23.21s user 0.45s system 134% cpu 17.595 total
```

我们可以看到时间缩短到了 23.66s。

[havlak2 和 havlak1 的不同](https://github.com/rsc/benchgraffiti/commit/58ac27bcac3ffb553c29d0b3fb64745c91c95948)

使用 pprof 获取详细信息

```shell
go build -o havlak2 havlak2.go
./havlak2 -cpuprofile=cpuprofile2.prof
```

查看 top10

```shell
(pprof) top10
Showing nodes accounting for 16330ms, 68.82% of 23730ms total
Dropped 99 nodes (cum <= 118.65ms)
Showing top 10 nodes out of 88
      flat  flat%   sum%        cum   cum%
    4090ms 17.24% 17.24%     7560ms 31.86%  runtime.scanobject
    2560ms 10.79% 28.02%     6000ms 25.28%  runtime.mallocgc
    2430ms 10.24% 38.26%    13170ms 55.50%  main.FindLoops
    1980ms  8.34% 46.61%     1980ms  8.34%  runtime.heapBitsForObject
    1430ms  6.03% 52.63%     1790ms  7.54%  runtime.greyobject
     910ms  3.83% 56.47%      910ms  3.83%  runtime.heapBitsSetType
     790ms  3.33% 59.80%      790ms  3.33%  main.DFS
     770ms  3.24% 63.04%      770ms  3.24%  runtime.memmove
     710ms  2.99% 66.03%      920ms  3.88%  runtime.mapiternext
     660ms  2.78% 68.82%     2640ms 11.13%  runtime.mapiterinit
```

可以看到 main.DFS 所耗的时间要短很多，而 runtime.mapaccess1_fast64 已经不在了。现在程序大部分时间花费在分配内存和垃圾回收上（runtime.mallocgc 执行分配内存和垃圾回收的任务）。为了找出为什么垃圾回收如此频繁，我们需要分配内存的原因。

## 编译 havlak3、测试并优化

在 havlak3 中，我们添加了 `pprof.WriteHeapProfile` 来搜集内存分配的信息。

[havlak3 和 havlak2 的不同](https://github.com/rsc/benchgraffiti/commit/b78dac106bea1eb3be6bb3ca5dba57c130268232)

```shell
(pprof) top10
Showing nodes accounting for 35.42MB, 100% of 35.42MB total
      flat  flat%   sum%        cum   cum%
   15.63MB 44.13% 44.13%    15.63MB 44.13%  main.FindLoops
   13.79MB 38.93% 83.06%    13.79MB 38.93%  main.(*CFG).CreateNode
       6MB 16.94%   100%    19.79MB 55.87%  main.NewBasicBlockEdge
         0     0%   100%    15.63MB 44.13%  main.FindHavlakLoops
         0     0%   100%    18.79MB 53.05%  main.buildBaseLoop
         0     0%   100%     9.29MB 26.23%  main.buildConnect
         0     0%   100%    10.50MB 29.65%  main.buildDiamond
         0     0%   100%     6.79MB 19.17%  main.buildStraight
         0     0%   100%    35.42MB   100%  main.main
         0     0%   100%    35.42MB   100%  runtime.main
```

我们可以看到 main.FindLoops 和 main.(\*CFG).CreateNode 分别分配了 44.13% 和 38.93% 的内存。

使用 `(pprof) list main.FindLoops` 查看具体信息。

```shell
   15.63MB    15.63MB (flat, cum) 44.13% of Total
         .          .    261:           return
         .          .    262:   }
         .          .    263:
         .          .    264:   size := cfgraph.NumNodes()
         .          .    265:
    1.97MB     1.97MB    266:   nonBackPreds := make([]map[int]bool, size)
    5.77MB     5.77MB    267:   backPreds := make([][]int, size)
         .          .    268:
    1.97MB     1.97MB    269:   number := make([]int, size)
    1.97MB     1.97MB    270:   header := make([]int, size, size)
    1.97MB     1.97MB    271:   types := make([]int, size, size)
    1.97MB     1.97MB    272:   last := make([]int, size, size)
         .          .    273:   nodes := make([]*UnionFindNode, size, size)
         .          .    274:
         .          .    275:   for i := 0; i < size; i++ {
         .          .    276:           nodes[i] = new(UnionFindNode)
         .          .    277:   }
```

## Reference

- [pprof package](https://golang.org/pkg/net/http/pprof/)
- [Profiling Go Programs](https://blog.golang.org/profiling-go-programs)
