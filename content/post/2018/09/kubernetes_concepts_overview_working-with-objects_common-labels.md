---
title: 'Kubernetes 推荐标签'
slug: kubernetes_concepts_overview_working-with-objects_common-labels
date: 2018-09-01
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
  - concepts
keywords:
  - kubernetes
  - concepts
---

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/

你可以使用除了 kubectl 和 dashboard 之外的更多工具可视化和管理 Kubernetes 对象。一组以所有工具都能理解的方式描述对象的通用标签允许工具相互工作。

<!--more-->

除了支持工具之外，推荐标签还以可查询的方式描述应用程序。

- [标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels)
- [应用和应用实例](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#applications-and-instances-of-applications)
- [例子](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#examples)

元数据围绕应用程序的概念进行组织。Kubernetes 不是一个服务平台（PaaS），没有也不限定应用程序的范围。相反，应用程序是任意的并用元数据进行描述。应用程序所包含内容的定义是宽松的。

> 注意：这些只是推荐标签。它们使管理应用程序变得更容易，但对于任何核心工具来说并不是必需的。

共享标签和注释使用一个共同的前缀：`app.kubernetes.io`。没有前缀的标签对用户是私有的。共享前缀可确保共享标签不会干扰自定义用户标签。

## 标签

为了充分利用这些标签，应将它们应用于每个资源对象。

| 键                             | 描述                                               | 例子               | 类型   |
| :----------------------------- | :------------------------------------------------- | :----------------- | :----- |
| `app.kubernetes.io/name`       | 应用程序的名称                                     | `mysql`            | string |
| `app.kubernetes.io/instance`   | 标识应用程序实例的唯一名称                         | `wordpress-abcxzy` | string |
| `app.kubernetes.io/version`    | 应用程序的当前版本（例如，语义版本、修订版哈希等） | `5.7.21`           | string |
| `app.kubernetes.io/component`  | 架构中的组件                                       | `database`         | string |
| `app.kubernetes.io/part-of`    | 所属的更高级的应用程序的名称                       | `wordpress`        | string |
| `app.kubernetes.io/managed-by` | 用于管理应用程序操作的工具                         | `helm`             | string |

要说明这些标签的运行情况，请参考 StatefulSet 对象：

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: '5.7.21'
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/managed-by: helm
```

## 应用和应用实例

应用程序可以安装一次或多次到 Kubernetes 集群中，在某些情况下，可以安装在同一命名空间中。例如，wordpress 不止安装一次，不同的网站使用 wordpress 的不同安装。

应用程序的名称和实例名称应分别记录。例如，WordPress 有值为 `wordpress` 的 `app.kubernetes.io/name` 标签，同时它还有一个值为 `wordpress-abcxzy` 的 `app.kubernetes.io/instance` 实例名标签。这使应用程序的应用程序和实例可以被识别。应用程序的每个实例都必须具有唯一的名称。

## 例子

为了说明使用这些标签的不同方式，请看下面具有不同复杂性的示例。

### 简单的无状态服务

考虑使用 `Deployment` 和 `Service` 对象部署简单的无状态服务的情况。下面两个代码片段展示了如何以最简单的形式使用标签。

此 `Deployment` 用于监视运行应用程序本身的 pod。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: myservice
    app.kubernetes.io/instance: myservice-abcxzy
......
```

此 `Service` 用于暴露该应用程序。

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: myservice
    app.kubernetes.io/instance: myservice-abcxzy
......
```

### 使用数据库的 Web 应用程序

考虑一个稍微复杂的应用程序：使用 Helm 安装的使用数据库（MySQL）的 Web 应用程序（WordPress）。下面的代码片段展示了部署此应用程序所使用对象的开始部分。

下面 `Deployment` 的开始部分用于 WordPress：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
......
```

此 `Service` 用于暴露 WordPress：

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: wordpress
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/version: "4.9.4"
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: server
    app.kubernetes.io/part-of: wordpress
......
```

MySQL 暴露为 `StatefulSet`，其中包含它和它所属的更高级的应用程序的元数据：

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/version: "5.7.21"
......
```

此 `Service` 用于将 MySQL 作为 WordPress 的一部分公开：

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: wordpress-abcxzy
    app.kubernetes.io/managed-by: helm
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/version: "5.7.21"
......
```

使用 MySQL 的 `StatefulSet` 和 `Service`，你会注意到有关 MySQL 和 Wordpress 的信息，也包括其他的应用。
