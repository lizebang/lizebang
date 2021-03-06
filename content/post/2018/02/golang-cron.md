---
title: "Golang 定时任务"
slug: golang-cron
date: 2018-02-25
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - golang
tags:
  - golang
  - library
keywords:
  - golang
  - library
  - cron
---

如何在 Golang 中添加或设置定时任务?

<!--more-->

这里有一个非常不错的第三方库 : [robfig/cron](https://github.com/robfig/cron)

那么如何使用它呢?

作者的说明 : [doc.go](https://github.com/robfig/cron/blob/master/doc.go)

# cron 使用方式

1.AddFunc

```go
package main

import (
    "fmt"
    "time"

    "github.com/robfig/cron"
)

func main() {
    c := cron.New()
    c.AddFunc("2 * * * * *", func() { fmt.Println(time.Now()) })
    c.Run()
}
```

2.AddJob

```go
package main

import (
    "fmt"
    "time"

    "github.com/robfig/cron"
)

type worker struct{}

func (w *worker) Run() {
    fmt.Println(time.Now())
}

func main() {
    c := cron.New()
    c.AddJob("2 * * * * *", &worker{})
    c.Run()
}
```

# cron 表达格式

cron 表达式表示一组时间，使用 6 个空格分隔的字段。

```go
* * * * * * 分别对应 秒 分 时 日 月 周
```

每个字段的规则 :

| 字段  | 是否必须 |     允许值      | 允许的特殊符号 |
| :---: | :------: | :-------------: | :------------: |
|  秒   |   必须   |      0-59       |    \* / , -    |
|  分   |   必须   |      0-59       |    \* / , -    |
|  时   |   必须   |      0-23       |    \* / , -    |
|  日   |   必须   |      1-31       |   \* / , - ?   |
|  月   |   必须   | 1-12 or JAN-DEC |    \* / , -    |
|  周   |   必须   | 0-6 or SUN-SAT  |   \* / , - ?   |

每一个特殊符号的用法 :

| 特殊符号 |                   用法                   |
| :------: | :--------------------------------------: |
|    \*    | 任意值，匹配字段的所有值，适用于所有字段 |
|    /     |            用于描述范围的间隔            |
|    ,     |           用于分隔列表中的项目           |
|    -     |               用于定义范围               |
|    ?     |  任意值，只用于 日 或 周 ，等同于 "\*"   |

## 三种表示法

1.cron 表达式

|       达式        |                                  描述                                  |
| :---------------: | :--------------------------------------------------------------------: |
| `*/2 */3 * * * *` |     每三分钟中的第一分钟间隔两秒执行一次 (分钟数=3n，秒数=2n，n=N)     |
| `*/3 * * * JAN *` | 每年一月 1 ～ 31 号间隔三秒执行一次 (月份数=1，分钟数=3n，秒数=2，n=N) |

2.预设表

|         目         |               描述               |    相当于     |
| :----------------: | :------------------------------: | :-----------: |
| yearly / @annually | 每年 1 月 1 日凌晨 0:00 执行一次 | `0 0 0 1 1 *` |
|      monthly       |   每月 1 日凌晨 0:00 执行一次    | `0 0 0 1 * *` |
|       weekly       |    每周周日凌晨 0:00 执行一次    | `0 0 0 * * 0` |
| daily / @midnight  |      每日凌晨 0:00 执行一次      | `0 0 0 * * *` |
|       hourly       |         每时开始执行一次         | `0 0 * * * *` |

3.间隔时间

```go
@every <duration>
```

string `<duration>` 能被 time.ParseDuration 解析，有效的时间单位有 "ns", "us" (or "µs"), "ms", "s", "m", "h"

推荐两个 Linux crontab 计算器，虽然和 go cron 不一样，但是也可以帮助理解记忆 crontab 表达式的规则。

- http://www.atool.org/crontab.php
- https://tool.lu/crontab/
