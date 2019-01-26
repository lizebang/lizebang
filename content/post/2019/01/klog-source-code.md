---
title: 'klog 源码分析'
slug: klog
date: 2019-01-10
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
keywords:
  - glog
  - klog
---

Kubernetes 中使用的 klog 其实就是 [glog](https://github.com/golang/glog)。这里简要地介绍一下它的功能及实现。

<!--more-->

[Code Path](https://github.com/kubernetes/kubernetes/tree/release-1.13/vendor/k8s.io/klog)

## 功能简介

klog 包是一个提供了 INFO/ERROR/V 日志记录的模块。它提供了函数 Info、Warning、Error、Fatel，以及诸如 Infof 的格式化版本。它还提供了由 -v 和 -vmodule=file=2 标志控制的 V-style 日志。

日志先写到缓冲区中，并且周期性的使用 Flush 写入到文件中。程序在退出之前会调用 Flush 以保证写入所有日志。

日志分 INFO、WARNING、ERROR 和 FATAL 这四个等级，它们的严重等级依次递增，默认等级为 ERROR。写入到高严重等级日志文件的消息也会被写入到所有严重等级比它低的日志文件中。

## 执行过程

1.主要结构 loggingT

klog 使用了一个全局的 loggingT 变量 logging。

![klog-1](/images/2019/01/klog-1.svg)

**freeList**：是一个缓冲区链表，日志会先写入到这里面，加上日志头拼接好，然后写入到 syncBuffer 的 \*bufio.Writer。

**file**：是用于储存日志的文件，syncBuffer 是真正有用的结构。\*bufio.Writer 用于缓存日志数据，缓冲区大小初始 256k。缓冲区每隔 30 秒向文件写入一次。文件大小最大 1800M，超过 1800M 会创建新的文件。

2.文件同步过程

![klog-2](/images/2019/01/klog-2.svg)

**flushDaemon**：init() 函数会设置默认的日志严重等级以及 V-log 等级，然后启动 flushDaemon。每间隔 30s 刷新所有日志并尝试将其数据同步到磁盘。日志会按照严重等级递减的顺序来刷新和同步，此做法是为了保证出现错误尽量小地影响严重等级高的日志。

3.写入日志过程

![klog-3](/images/2019/01/klog-3.svg)

**l.getBuffer() 与 buf.Write(...)**：从 `l.freeList` 中获取到 buf 后，会按顺序写入日志头以及日志信息。日志格式如下：

```go
0         1         2         |3         4
012345678901234567890123456789|01234567890
Lmmdd hh:mm:ss.uuuuuu _______ |file:line] msg...
                      threadid

前 29 字节固定，file 和 line 不定长。
L                表示日志级别，有 "IWEF"（例如，"I" 表示 INFO）
mm               月份（零填充，例如五月是 "05"）
dd               日期（零填充）
hh:mm:ss.uuuuuu  以小时、分钟、微秒表示的时间
threadid         本应该为线程 ID，但只能获取到进程 ID
file             文件名
line             行号（零填充）
msg              用户提供的信息
```

**syncBuffer.Write(data)**：将日志从 buf 写入到 syncBuffer 的 buffer 中。日志等级为 fatal 时，刷新并同步（超时时间 10s）所有日志并退出。

**l.putBuffer(buf)**：将 buf 放回 `l.freeList`，如果 buf 中的 bytes.Buffer 大小超过 256 字节，就等待 GC 回收。

## 部分代码细节

1.freeList 的操作

```go
func (l *loggingT) getBuffer() *buffer {
	l.freeListMu.Lock()
	b := l.freeList
	if b != nil {
		l.freeList = b.next
	}
	l.freeListMu.Unlock()
	if b == nil {
		b = new(buffer)
	} else {
		b.next = nil
		b.Reset()
	}
	return b
}

func (l *loggingT) putBuffer(b *buffer) {
	if b.Len() >= 256 {
		return
	}
	l.freeListMu.Lock()
	b.next = l.freeList
	l.freeList = b
	l.freeListMu.Unlock()
}
```

2.高严重等级的日志也将写入到低严重等级的日志文件中。

```go
		switch s {
		case fatalLog:
			l.file[fatalLog].Write(data)
			fallthrough
		case errorLog:
			l.file[errorLog].Write(data)
			fallthrough
		case warningLog:
			l.file[warningLog].Write(data)
			fallthrough
		case infoLog:
			l.file[infoLog].Write(data)
		}
```

3.rotateFile 创建新文件时使用符号链接（`klog_file.go`）

```go
	for _, dir := range logDirs {
		fname := filepath.Join(dir, name)
		f, err := os.Create(fname)
		if err == nil {
			symlink := filepath.Join(dir, link)
			os.Remove(symlink)
			os.Symlink(name, symlink)
			return f, fname, nil
		}
		lastErr = err
	}
```
