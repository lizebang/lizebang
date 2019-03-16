---
title: "耦合与解耦"
slug: couple-and-decouple
date: 2018-03-16
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - design
tags:
  - design
keywords:
  - design
---

最近维护以前写过的代码时，由于设计不合理，大量模块紧密耦合在一起导致项目维护起来十分困难。今天我们来讲一讲代码的耦合。

<!--more-->

## 耦合

耦合性（英语：Coupling，dependency，或称耦合力或耦合度）是一种软件度量，是指一程序中，模块及模块之间信息或参数依赖的程度。

紧密耦合的缺点：

- 一个模块的修改会产生[涟漪效应](https://zh.wikipedia.org/wiki/涟漪效应)，其他模块也需随之修改
- 由于模块之间的相依性，模块的组合会需要更多的精力及时间
- 由于一个模块有许多的相依模块，模块的可复用性低

## 逻辑解耦

以我所写的项目为例，它是一个爬虫的项目，定时爬取几个网站的数据并存到数据库，项目看起来非常简单，实际要做的事情也不复杂。

![crawler](/images/2018/03/crawler.svg)

将读取配置（config）和控制定时执行（crontab）的模块作为插件独立出来，不同的客户端向 Client Set 注册之后，分别爬取自己的数据，最后统一存入数据库。这一切的一切都看起来非常的美好。crontab 以及数据的存储都与具体爬取信息的客户端分离开了，各个客户端之间也分离开了。但是，这之中有一个巨大的缺陷。每个客户端中包所有的爬取逻辑和控制逻辑，只有爬取到 URL 后才能去爬取具体到数据。当爬取逻辑出现问题需要修改时，可能会影响到控制逻辑，需要对控制逻辑进行修改。这时维护到成本非常到高，所以我们需要将这部分到耦合解开。

![better crawler](/images/2018/03/better-crawler.svg)

改进之后，将任务划分封装成小任务，然后通过 Collecter 搜集起来，再由 Filter 分发到每个更小的模块，每一个小模块只专注于处理自己的业务，最终实现逻辑上的耦合。Search、Crawlers 会向 Collecter 发送任务。

## 数据解耦

这一部分是在很久之后才补写的。

我将任务封装成一个 Task 接口，它带有一个 `Do(ctx *context.Context) error` 方法，调度时传入需要的 Task 任务和任务所需要的 context 就可以了。当任务失败时，我需要重新调度任务，这是我就抽象出了一个 RetryTask 结构方便复用，代码如下：

这部分 scheduler 的代码请看 [TechCatsLab](https://github.com/TechCatsLab/scheduler)

```go
type RetryTask struct {
    task Task
}

func (rt *RetryTask) Do(ctx *context.Context) error {
    if err := rt.task.Do(ctx); err == nil {
        return nil
    }

    // get some value from ctx
    // retry times and scheduler

    if times > 0 {
        scheduler.Schedule(NewRetryTask(rt.task), NewRetryTaskContext(ctx, times-1))
        return nil
    }

    return err
}
```

这种封装看起来完全没有然后问题，也可以很好的工作。不过，这里还是有一个数据耦合的问题。RetryTask 使用的 ctx 和它内部的 task 使用的 ctx 是同一个 context 这里出现了一个很不明显的耦合问题。task 完全不应该访问的到 RetryTask 的 context，而 RetryTask 的 context 也不应该和 task 的放在一起，应该分开使用。

```go
type RetryTask struct {
    task Task
    ctx *context.Context
}

func (rt *RetryTask) Do(ctx *context.Context) error {
    if err := rt.task.Do(rt.ctx); err == nil {
        return nil
    }

    ...
}
```

只是简单的将 内部 task 的 context 存下来，到该使用的时候使用就能够实现数据上的解耦。

## Reference

- [耦合性 (计算机科学)](<https://zh.wikipedia.org/wiki/耦合性_(計算機科學)>)
