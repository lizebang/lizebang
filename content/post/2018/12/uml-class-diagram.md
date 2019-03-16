---
title: "UML 类图中的关系"
slug: uml-class-diagram
date: 2018-12-05
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - skill
tags:
  - skill
  - uml
keywords:
  - skill
  - uml
---

看和画 UML 图是程序员必备的技能之一，看图、画图有助于理解、分析程序的逻辑，大大提高学习和工作的效率。今天只简单总结一下类图中的关系。

<!--more-->

按照关系的性质可以分为 4 种，分别是依赖关系、泛化关系、关联关系和实现关系。

## 依赖关系

依赖关系表示两个或多个模型元素之间语义上的关系，客户元素以某种形式依赖于提供者元素。

![Dependency](/images/2018/12/dependency.svg)

依赖关系可以细分为四大类，即使用依赖、抽象依赖、授权依赖和绑定依赖。

1.使用依赖

- 使用 -- use
- 调用 -- call
- 参数 -- parameter
- 发送 -- send
- 实例化 -- instantiate

  2.抽象依赖

- 跟踪 -- trace
- 精化 -- refine
- 派生 -- derive

  3.授权依赖

- 访问 -- access
- 导入 -- import
- 友元 -- friend

  4.绑定依赖

- 绑定 -- bind

## 泛化关系

泛化关系表示从特殊元素到一般元素的分类关系，其模型元素可以是类、用例以及其他。

![Generalization](/images/2018/12/generalization.svg)

## 关联关系

关联关系是较高层次的关系，它具体包含聚合关系和组合关系。

1.聚合关系是整体与部分的关系，且部分可以离开整体而单独存在。

![Aggregation](/images/2018/12/aggregation.svg)

2.组合关系是整体与部分的关系，但部分不能离开整体而单独存在。

![Composition](/images/2018/12/composition.svg)

3.单向关联与双向关联，单向关联有一个箭头，双向关联可以有两个箭头或者没有箭头。

![Association](/images/2018/12/association.svg)

## 实现关系

实现关系表示类与被类实现的接口、协作与被协作实现的用例之间的关系。

![Realization](/images/2018/12/realization.svg)
