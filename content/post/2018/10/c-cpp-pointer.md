---
title: 'C/CPP Pointer'
slug: c-cpp-pointer
date: 2018-10-05
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - c/cpp
tags:
  - c/cpp
  - pointer
keywords:
  - c/cpp
  - pointer
---

本文介绍了 C/CPP 指针的规则。

<!--more-->

## 数组与指针

下面有一些声明的示例。

```c
int * risks[10];    // 声明一个内含 10 个元素的数组，每个元素都是一个指向 int 的指针
int (* rusks)[10];  // 声明一个指向数组的指针，该数组内含 10 个 int 类型的值
int * oof[3][4];    // 声明一个 3x4 的二维数组，每个元素都是指向 int 的指针
int (* uuf)[3][4];  // 声明一个指向 3x4 二维数组的指针，该数组中内含 int 类型值
int (* uof[3])[4];  // 声明一个内含 3 个指针元素的数组，其中每个指针都指向一个内含 4 个 int 类型元素的数组
```

要看懂和理解这些声明，需要理解 \*、() 和 [] 的优先级。

1.数组名后面的 [] 和函数名后面的 () 具有相同的优先级，它们比解引用运算符 \* 的优先级高。

2.[] 和 () 的优先级相同，由于都是从左往右结合。

了解这些之后，我们就比较容易理解上面的那些声明了。

risks 先和 [10] 结合，所以它是一个指针数组，而不是指向数组的指针。

rusks 中 () 让 rusks 和 \* 先结合，所以 rusks 是一个指针，它指向一个内含 10 个 int 类型元素的数组。

oof 先和 [3][4] 结合，所以它是一个指针数组，而不是指向数组的指针。

uuf 中 () 让 uuf 和 \* 先结合，所以 uuf 是一个指针，它指向一个 3x4 二维数组。

uof 先和 [3] 结合，表明它是一个数组，这个数组内含 3 个指针元素，而每个指针元素又指向一个 内含 4 个 int 类型元素的数组。

## 函数与指针

要声明一个指向特定类型函数的指针，可以先声明一个该类型的函数，然后把函数名替换成 (\*pf) 形式的表达式。然后，pf 就成为指向该类型函数的指针。

看下面的示例。

我们有这样一个函数

```c
int comp(int x, int y);
```

我们将 comp 替换成 (\*pf) 就可以声明一个指向该类型函数的指针

```c
int (*pf) (int x, int y);
pf = comp;
```

调用 pf 的方法有两种，推荐使用第一种方法。

```c
(*pf)(a, b);
pf(a, b);
```

## 顶层 const

指针本身是一个对象，而它又可以指向另外一个对象。因此，指针本身是不是常量以及指针所指的是不是一个常量就是两个相互独立的问题。

名词 **顶层 const** 表示指针本身是个常量，而名词 **底层 const** 表示指针所指的对象是一个常量。位于 \* 右边底是 **顶层 const**，位于 \* 左边底是 **底层 const**。

```cpp
int i = 0;
int *const p1 = &i;       // 不能改变 p1 的值，这是一个顶层 const
const int ci = 42;        // 不能改变 ci 的值，这是一个顶层 const
const int *p2 = &ci;      // 允许改变 p2 的值，这是一个底层 const
const int *const p3 = p2; // 第一个 const 是底层 const，第二个 const 是顶层 const
const int &r = ci;        // C++ 用于声明引用的 const 都是底层 const
```

当执行对象的拷贝操作时，常量是顶层 const 还是底层 const 区别明显。其中，顶层 const 不受什么影响。但是，底层 const 的限制却不能忽视。当执行对象的拷贝操作时，拷入和拷出的对象必须具有相同的底层 const 资格，或者两个对象的数据类型必须能够转换。一般来说，非常量可以转换成常量，反之则不行：

```cpp
int *p = p3;       // 错误：p3 包含底层 const 的定义，而 p 没有
p2 = &i;           // 正确：int* 能转换成 const int*
int &r = ci;       // 错误：普通的 int& 不能绑定到 int 常量上
const int &r2 = i; // 正确：const int& 可以绑定到一个普通的 int 上
```
