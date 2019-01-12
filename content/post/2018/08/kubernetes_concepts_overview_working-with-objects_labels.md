---
title: 'Kubernetes 标签和选择器'
slug: kubernetes_concepts_overview_working-with-objects_labels
date: 2018-08-31
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

原文：https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

Labels 是关联到像 Pod 这样对象上的键值对。标签旨在用于指定对用户有意义且相关对象的标识属性，但不对核心系统直接使用隐含语义。标签可用于组织和选择对象的子集。标签可以在创建时关联到对象上，也可以在之后的任何时间添加和修改。每个对象都可以定义一组键值标签。每个对象标签的 key 必须唯一。

<!--more-->

```json
"metadata": {
  "labels": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```

Labels 允许高效的查询和监视，非常适合在 UIs 和 CLIs 中使用。记录非识别性的信息时应使用[注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)。

## 动机

标签使用户能够以松散耦合的方式将自己的组织结构映射到系统对象，而无需客户端存储这些映射。

服务部署和批处理流水线通常是多维实体（例如，多个分区或部署、多个发布轨道、多个层、每层多个微服务）。管理通常需要交叉操作，这打破了严格的层次表示的封装，特别是由基础设施而不是用户确定的严格的层次结构。

标签示例：

- `"release" : "stable"`, `"release" : "canary"`
- `"environment" : "dev"`, `"environment" : "qa"`, `"environment" : "production"`
- `"tier" : "frontend"`, `"tier" : "backend"`, `"tier" : "cache"`
- `"partition" : "customerA"`, `"partition" : "customerB"`
- `"track" : "daily"`, `"track" : "weekly"`

这些只是常用标签的例子，你可以自由地定制自己的规范。记住标签的 key 对于给定对象必须是唯一的。

## 语法和字符集

**Labels** 是键值对。有效的标签 key 有两个部分：可选的前缀和名称，它们用斜杠分隔 `/` 。名称部分是必须的，并且必须在 63 个字符以内，开始和结尾的字符必须是字母（大小写都可以）或数字，中间还可以使用破折号、下划线和句点（即 `^[:alnum:][\w-.]{0,61}[:alnum:]$`）。前缀是可选的。如果指定的话，前缀必须是 DNS 子域：一系列由点 `.` 分隔的 DNS 标签，总长度不超过 253 个字符，后面跟着一个斜线 `/`。如果省略了前缀，这个标签的 key 会被推断为用户私有。自动化系统组件（例如，`kube-scheduler`、`kube-controller-manager`、`kube-apiserver`、`kubectl` 或第三方自动化组件），它们添加到最终用户对象上的标签必须指定前缀。`kubernetes.io/` 和 `k8s.io/` 前缀是为 Kubernetes 核心组件预留的。

有效的标签 value 必须在 63 个字符以内，值可以为空，也可以是字符串，字符串开始和结尾的字符是字母（大小写都可以）或数字，中间还可以使用破折号、下划线和句点。

## 标签选择器

不像 [名称和 UIDs](https://kubernetes.io/docs/user-guide/identifiers)，标签不保证唯一性。通常情况下，我们希望很多对象携带相同的标签。

通过标签选择器，客户端/用户可以指定一个对象集合。标签选择器是 Kubernetes 中的核心分组原语。

目前 API 支持两种类型的选择器：**基于等式** 和 **基于集合**。标签选择器可以由多个逗号分隔的需求组成。在多个需求的情况下，所有需要都要被满足。逗号分隔符的作用与逻辑与 `&&` 一样。

一个空的标签选择器（即，零个需求）会选择集合中的每个对象。

一个空标签的选择器（仅可用于可选选择器字段）不选择任何对象。

> 注意：两个控制器的标签选择器不得在命名空间内重复，否则它们将相互竞争。

## 基于等式需求

基于相等或不等的需求允许通过标签的 keys 和 values 进行过滤。匹配的对象必须满足所有指定标签的约束，尽管它们可能具有其他标签。有三种可以使用的运算符：`=`、`==` 和 `!=`。前两个代表等于（它们是同义词），后者代表不等于。例如：

```shell
environment = production
tier != frontend
```

前一个需求所有 key 等于 `environment` 并且 value 等于 `production` 的资源。后一个需求所有 key 等于 `tier` 并且 value 不为 `frontend` 或不存在 key 等于 `tier` 的所有资源。要选择生产环境中除前端外的资源可以使用逗号分隔：`environment=production,tier!=frontend`。

基于等式的标签需求的一种使用场景是 Pods 选择节点。例如，下面的示例 Pod 选择带有标签 `accelerator=nvidia-tesla-p100` 的节点。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: 'k8s.gcr.io/cuda-vector-add:v0.1'
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:
    accelerator: nvidia-tesla-p100
```

### 基于集合需求

基于集合的需求允许 key 根据一组 values 过滤。有三种可以使用的运算符，`in`、`notin` 和 `exists`（仅 key 标识符）。例如：

```shell
environment in (production, qa)
tier notin (frontend, backend)
partition
!partition
```

第一个例子需求所有 key 等于 `environment` 并且 value 等于 `production` 或 `qa` 的资源。第二个例子需求所有 key 等于 `tier` 并且 value 不为 `frontend` 和 `backend` 或不存在 key 等于 `tier` 的资源。第三个例子需求所有包含标签 key 为 `partition` 的资源，不检查值。第四个例子需求所有不存在标签 key 为 `partition` 的资源，不检查值。类似地，逗号分隔符充当 `&&` 运算符。因此，要选择有分区并且不在 qa 环境的所有资源可以使用：`partition,environment notin (qa)`。基于集合的标签是等式的一般形式，因为 `environment=production` 等同于 `environment in (production)`，类似地 `!=` 相当于 `notin`。

基于集合的需求可以与基于等式的需求相结合，例如：`partition in (customerA, customerB),environment!=qa`。

## API

### LIST 和 WATCH 过滤

LIST 和 WATCH 操作使用查询参数可以指定标签选择器过滤对象集。两种类型的选择器都是被允许的（这里显示的是当它们出现 URL 查询字符串中的形式）：

- 基于等式需求：
  `?labelSelector=environment%3Dproduction,tier%3Dfrontend`

- 基于集合需求：
  `?labelSelector=environment+in+%28production%2Cqa%29%2Ctier+in+%28frontend%29`

两种标签选择器的样式都能被用来通过一个 REST 客户端列出或者监视资源。例如，针对使用 `kubectl` 操作 `apiserver` 和使用基于等式的标签需求可以这样写：

```shell
$ kubectl get pods -l environment=production,tier=frontend
```

或者使用基于集合的标签需求：

```shell
$ kubectl get pods -l 'environment in (production),tier in (frontend)'
```

正如之前所提到的，基于集合的需求语句更具表现力。例如，他们可以在值上实现 `||` 运算符：

```shell
$ kubectl get pods -l 'environment in (production, qa)'
```

或通过存在运算符限制负匹配：

```shell
$ kubectl get pods -l 'environment,environment notin (frontend)'
```

### 设置 API 对象的参考

某些 Kubernetes 对象，例如 [services](https://kubernetes.io/docs/user-guide/services) 和 [replicationcontrollers](https://kubernetes.io/docs/user-guide/replication-controller)，它们也可以使用标签选择器去指定其他资源的集合，例如 [pods](https://kubernetes.io/docs/user-guide/pods)。

#### Service 和 ReplicationController

`service` 通过标签选择器定义作为目标的一组 Pods。类似地，`replicationcontroller` 应该管理的 Pod 的数量也使用标签选择器定义。

标签选择器对于 `service` 和 `replicationcontroller` 这两个对象使用 json 或者 yaml 文件映射的方式来被定义，并且只支持基于等式的需求选择器：

```json
"selector": {
    "component" : "redis",
}
```

或者

```yaml
selector:
  component: redis
```

这个选择器（分别为 json 和 yaml 格式）与 `component=redis` 或 `component in (redis)` 相等。

#### 支持基于集合的需求的资源

Kubernetes 较新的资源，例如 [Job](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/)、[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)、[Replica Set](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) 和 [Daemon Set](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)，也支持基于集合的需求。

```yaml
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - { key: tier, operator: In, values: [cache] }
    - { key: environment, operator: NotIn, values: [dev] }
```

`matchLabels` 是 `{key,value}` 键值对的映射。在 `matchLabels` 映射里的单独的 `{key,value}` 键值对是等价于一个 `matchExpressions` 的元素，它的字段 `key` 是 ：“key”，`operator` 是 “In”，`values` 数组仅包含 “value”。`matchExpressions` 是一个 `pod` 选择器需求的列表。有效的操作符包括 In、NotIn、Exists 和 DoesNotExist。当操作符为 In 或 NotIn 时，值必须不为空。所有的这些 `matchLabels` 和 `matchExpressions` 中的需求都用 `&&` 连接到一起，它们必须都被满足才能匹配。

#### 选择节点的集合

一个通过标签选择的使用场景是约束 Pod 可以调度的节点集。更多信息请看文档 -- [node selection](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)。
