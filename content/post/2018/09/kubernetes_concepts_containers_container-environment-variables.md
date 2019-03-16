---
title: "Kubernetes 容器环境变量"
slug: kubernetes_concepts_containers_container-environment-variables
date: 2018-09-09
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

原文：https://kubernetes.io/docs/concepts/containers/container-environment-variables/

本文介绍了容器环境中对容器可用的资源。

<!--more-->

## 容器环境

Kubernetes 容器环境为容器提供了几类重要的资源：

- 一个文件系统，其中包含一个 [镜像](https://kubernetes.io/docs/concepts/containers/images/) 和一个或多个 [卷](https://kubernetes.io/docs/concepts/storage/volumes/)。
- 容器本身相关的信息。
- 集群中其他对象相关的信息。

#### 容器信息

容器的 hostname 是容器所在的 Pod 名称。它可以通过 `hostname` 命令或调用 libc 中的 [gethostname](http://man7.org/linux/man-pages/man2/gethostname.2.html) 函数来获取。

Pod 的名称和命名空间可以通过 [downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/) 作为环境变量使用。

与 docker 镜像中任何静态指定的环境变量一样，Pod 中用户定义的环境变量也可用于容器。

#### 集群信息

创建容器时运行的所有服务的列表可作为环境变量用于该容器。这些环境变量与 docker 链接的语法相匹配。

对于名为 foo，映射到名为 bar 的容器的服务，会定义下面的变量：

```shell
FOO_SERVICE_HOST=<the host the service is running on>
FOO_SERVICE_PORT=<the port the service is running on>
```

服务具有专用的 IP 地址，如果开启了 [DNS 插件](http://releases.k8s.io/master/cluster/addons/dns/)，可以通过 DNS 访问容器。
