---
title: 'Kubernetes API'
slug: kubernetes-concepts-api
date: 2018-08-28
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

原文：https://kubernetes.io/docs/concepts/overview/kubernetes-api/

Kubernetes 本身被分解为多个组件，这些组件通过其 API 进行交互。

<!--more-->

[API 约定文档](https://git.k8s.io/community/contributors/devel/api-conventions.md) 中描述了总体 API 约定。

[API 参考](https://kubernetes.io/docs/reference) 中描述了 API 端点，资源类型和示例。

[控制 API 访问文档](https://kubernetes.io/docs/reference/access-authn-authz/controlling-access/) 中讨论了对 API 的远程访问。

Kubernetes API 还可以作为系统声明性配置架构的基础。 [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) 命令行工具可用于创建、更新、删除和获取 API 对象。

Kubernetes 还可以根据 API 资源存储其序列化状态（当前在 [etcd](https://coreos.com/docs/distributed-configuration/getting-started-with-etcd/) 中）。

## API 的更新

根据经验，任何成功的系统都需要随着新的使用场景出现或现有的使用场景发生变化的情况下进行相应的发展和调整。因此，我们希望 Kubernetes API 能够不断变化和发展。同时，我们也希望在较长一段时间内不破坏与现有客户端的兼容性。一般情况下，添加新的 API 资源和资源字段不会发生兼容性问题。但是删除现有资源或字段将必须遵循 [API 弃用流程](https://kubernetes.io/docs/reference/using-api/deprecation-policy/)。

[API 更新文档](https://git.k8s.io/community/contributors/devel/api_changes.md) 详细说明了兼容性变更的要素以及如何变更 API 的流程。

## OpenAPI 和 Swagger 定义

Kubernetes 使用使用 [Swagger v1.2](http://swagger.io/) 和 [OpenAPI](https://www.openapis.org/) 记录完整的 API 详细信息。Kubernetes apiserver（即 “master”）提供了一个 API 接口用于获取 Swagger 1.2 Kubernetes API 规范，路径为 `/swaggerapi`。

从 Kubernetes 1.10 开始，OpenAPI 规范仅由 `/openapi/v2` 提供。格式分隔（`/swagger.json`、`/swagger-2.0.0.json`、`/swagger-2.0.0.pb-v1` 和 `/swagger-2.0.0.pb-v1.gz`）已弃用，并将在 Kubernetes 1.14 中被删除。

通过设置 HTTP 头信息指定请求的格式：

| 头信息            | 可能值                                                                                                                                                        |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Accept`          | `application/json`、`application/com.github.proto-openapi.spec.v2@v1.0+protobuf`（对于 `*/*` 默认的 content-type 为 `application/json` 或者不添加这条头信息） |
| `Accept-Encoding` | `gzip` （不添加这条头信息是可以接受的）                                                                                                                       |

**获取 OpenAPI 规范的示例：**

| 1.10 版本之前                 | 从 Kubernetes 1.10 开始                                                                                    |
| :---------------------------- | :--------------------------------------------------------------------------------------------------------- |
| `GET /swagger.json`           | `GET /openapi/v2 Accept: application/json`                                                                 |
| `GET /swagger-2.0.0.pb-v1`    | `GET /openapi/v2 Accept: application/com.github.proto-openapi.spec.v2@v1.0+protobuf`                       |
| `GET /swagger-2.0.0.pb-v1.gz` | `GET /openapi/v2 Accept: application/com.github.proto-openapi.spec.v2@v1.0+protobuf Accept-Encoding: gzip` |

Kubernetes 实现了另一种基于 Protobuf 的序列化格式，该格式主要用于集群内通信，并在[设计方案](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/api-machinery/protobuf.md) 中进行了说明，每个模式的 IDL 文件位于定义 API 对象的 Go 软件包中。

## API 版本

为了使删除字段或者重构资源表示更加容易，Kubernetes 支持多个 API 版本。每一个版本都在不同 API 路径下，例如 `/api/v1` 或者 `/apis/extensions/v1beta1`。

我们选择在 API 级别进行版本化，而不是在资源或字段级别进行版本化，以确保 API 提供清晰，一致的系统资源和行为视图，并控制对已废止的 API 和/或 实验性 API 的访问。JSON 和 Protobuf 序列化模式遵循架构更改的相同准则 -- 下面的所有描述都同时适用于这两种格式。

请注意，API 版本控制和软件版本控制只有间接相关性。[API 和发行版本建议](https://git.k8s.io/community/contributors/design-proposals/release/versioning.md) 描述了 API 版本与软件版本之间的关系。

不同的 API 版本名称意味着不同级别的软件稳定性和支持程度。每个级别的标准在 [API 更新文档](https://git.k8s.io/community/contributors/devel/api_changes.md#alpha-beta-and-stable-versions) 中有更详细的描述。 内容主要概括如下：

- Alpha 测试版本：

  - 版本名称包含了 `alpha`（例如：`v1alpha1`）。
  - 可能是有缺陷的。启用该功能可能会带来隐含的问题，默认情况是关闭的。
  - 支持的功能可能在没有通知的情况下随时删除。
  - API 的更改可能会带来兼容性问题，但是在后续的软件发布中不会有任何通知。
  - 由于 bugs 风险的增加和缺乏长期的支持，推荐在短暂的集群测试中使用。

- Beta 测试版本：

  - 版本名称包含了 `beta`（例如：`v2beta3`）。
  - 代码已经测试过。启用该功能被认为是安全的，功能默认已启用。
  - 所有已支持的功能不会被删除，细节可能会发生变化。
  - 对象的模式和/或语义可能会在后续的 beta 测试版或稳定版中以不兼容的方式进行更改。 发生这种情况时，我们将提供迁移到下一个版本的说明。 这可能需要删除、编辑和重新创建 API 对象。执行编辑操作时需要谨慎行事，这可能需要停用依赖该功能的应用程序。
  - 建议仅用于非业务关键型用途，因为后续版本中可能存在不兼容的更改。 如果您有多个可以独立升级的集群，则可以放宽此限制。
  - **请尝试我们的 beta 版本功能并且给出反馈！一旦他们退出 beta 测试版，我们可能不会做出更多的改变。**

- 稳定版本：

  - 版本名称是 `vX`，其中 `X` 是整数。
  - 功能的稳定版本将出现在许多后续版本的发行软件中。

## API 组

为了更容易地扩展 Kubernetes API，我们实现了 [API 组](https://git.k8s.io/community/contributors/design-proposals/api-machinery/api-group.md)。API 组在 REST 路径和序列化对象的 `apiVersion` 字段中指定。

目前有几个 API 组正在使用中：

1. 核心组，通常被称为遗留组，位于 REST 路径 `/api/v1` 并使用 `apiVersion: v1`。
2. 命名组，位于 REST 路径 `/apis/$GROUP_NAME/$VERSION`，并使用 `apiVersion: $GROUP_NAME/$VERSION`（例如 `apiVersion: batch/v1`）。在 [Kubernetes API 参考](https://kubernetes.io/docs/reference/) 中可以看到支持的 API 组的完整列表。

有以下两种方式来提供 [自定义资源](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) 对 API 进行扩展：

1. [CustomResourceDefinition](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/) 适用于具有非常基本的 CRUD 需求的用户。
2. 需要完整 Kubernetes API 语义的用户可以实现自己的 apiserver，并使用 [聚合器](https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/) 为客户端提供无缝的服务。

## 启用 API 组

某些资源和 API 组在默认情况下处于启用状态。它们可以通过在 apiserver 上设置 `--runtime-config` 来启用或禁用它们。 `--runtime-config` 接受逗号分隔的值。例如：设置 `--runtime-config=batch/v1=false` 可以禁用 batch/v1，设置 `--runtime-config=batch/v2alpha1` 可以启用 batch/v2alpha1。该标志接受用来描述 apiserver 运行时配置的用逗号分隔的一组键值对。

重要：启用或禁用组或资源需要重新启动 apiserver 和 controller-manager 使得 `--runtime-config` 的更改生效。

## 启用组中资源

DaemonSets、Deployments、HorizontalPodAutoscalers、Ingress、Jobs 和 ReplicaSets 是默认启用的。其他扩展资源可以通过在 apiserver 上设置 `--runtime-config` 来启用。`--runtime-config` 接受逗号分隔的值。例如：要禁用 deployments 和 ingress，可以设置：

```shell
--runtime-config=extensions/v1beta1/deployments=false,extensions/v1beta1/ingress=false
```
