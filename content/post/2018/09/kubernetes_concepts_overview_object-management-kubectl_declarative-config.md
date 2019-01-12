---
title: '使用配置文件对 Kubernetes 对象的声明式管理'
slug: kubernetes_concepts_overview_object-management-kubectl_declarative-config
date: 2018-09-03
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

原文：https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/

Kubernetes 对象可以通过在目录中存储多个对象配置文件来创建、更新和删除，并使用 `kubectl apply` 按需递归创建和更新这些对象。此方法保留对实时对象所做的写入操作, 而不将更改合并回对象配置文件中。

<!--more-->

## 权衡利弊

`kubectl` 工具支持三种对象管理的方式：

- 命令式指令
- 命令式对象配置
- 声明式对象配置

在 [Kubernetes 对象管理](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/) 中讨论了每一种对象管理方式的优缺点。

## 开始前

声明式对象配置要求对 Kubernetes 对象定义和配置有深刻对理解。如果没有，请先完整阅读下面对文档：

- [使用命令式指令管理 Kubernetes 对象](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-command/)
- [使用配置文件对 Kubernetes 对象的命令式管理](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/)

以下是本文中使用对术语对定义：

- 对象配置文件/配置文件：定义 Kubernetes 配置对文件。本文演示了任何将配置文件传递给 `kubectl apply`。配置文件通常存储在源码控制软件中，如：Git。
- 实时对象配置/实时配置：由 Kubernetes 集群观察到的对象的实时配置值。这些保存在 Kubernetes 群集存储中，通常是 etcd。
- 声明式配置编辑器/声明式编辑器：对实时对象更新的人或软件组件。本文提到的实时编辑器对配置文件进行修改并运行 `kubectl apply` 写入更改。

## 如何创建对象

使用 `kubectl apply` 创建所有指定文件夹中定义在配置文件中的对象，除了一些已经存在的对象：

```shell
kubectl apply -f <directory>/
```

这会在每个对象上设置注解 `kubectl.kubernetes.io/last-applied-configuration: '{...}'`。该注解包含用于创建对象的对象配置文件的内容。

> 注意：添加 `-R` 标志可以递归处理目录。

这是一个对象配置文件的例子：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

使用 `kubectl apply` 创建对象：

`kubectl apply -f https://k8s.io/examples/application/simple_deployment.yaml`

使用 `kubectl get` 打印实时配置：

```shell
kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml
```

输出结果表明注解 `kubectl.kubernetes.io/last-applied-configuration` 被写入到实时配置，并且它与配置文件匹配：

```yaml
kind: Deployment
metadata:
  annotations:
    # ...
    # This is the json representation of simple_deployment.yaml
    # It was written by kubectl apply when the object was created
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"minReadySeconds":5,"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.7.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
  # ...
spec:
  # ...
  minReadySeconds: 5
  selector:
    matchLabels:
      # ...
      app: nginx
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.7.9
          # ...
          name: nginx
          ports:
            - containerPort: 80
            # ...
        # ...
    # ...
  # ...
```

## 如何更新对象

你也可以使用 `kubectl apply` 更新所有定义在文件夹中的对象，即使这些对象应存在了。此方法完成以下操作：

1.设置出现配置文件中的字段到实时配置中。

2.从实时配置中清除配置文件中移除的字段。

`kubectl apply -f <directory>/`

> 注意：添加 `-R` 标志可以递归处理目录。

这是一个配置文件的例子：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

使用 `kubectl apply` 创建对象：

`kubectl apply -f https://k8s.io/examples/application/simple_deployment.yaml`

> 注意：为说明起见，前面的命令指的是单个配置文件而不是目录。

使用 `kubectl get` 打印实时对象：

`kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml`

输出结果表明注解 `kubectl.kubernetes.io/last-applied-configuration` 被写入到实时配置，并且它与配置文件匹配：

```yaml
kind: Deployment
metadata:
  annotations:
    # ...
    # This is the json representation of simple_deployment.yaml
    # It was written by kubectl apply when the object was created
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"minReadySeconds":5,"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.7.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
  # ...
spec:
  # ...
  minReadySeconds: 5
  selector:
    matchLabels:
      # ...
      app: nginx
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.7.9
          # ...
          name: nginx
          ports:
            - containerPort: 80
            # ...
        # ...
    # ...
  # ...
```

使用 `kubectl scale` 直接更新实时配置中的 `replicas` 字段。这时不使用 `kubectl apply`：

`kubectl scale deployment/nginx-deployment --replicas=2`

使用 `kubectl get` 打印实时对象：

`kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml`

输出结果表明 `replicas` 字段已经被设置为 2，并且注解 `last-applied-configuration` 不包含 `replicas` 字段：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    # ...
    # note that the annotation does not contain replicas
    # because it was not updated through apply
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"minReadySeconds":5,"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.7.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
  # ...
spec:
  replicas: 2 # written by scale
  # ...
  minReadySeconds: 5
  selector:
    matchLabels:
      # ...
      app: nginx
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.7.9
          # ...
          name: nginx
          ports:
            - containerPort: 80
        # ...
```

更改 `simple_deployment.yaml` 配置文件，将镜像从 `nginx:1.7.9` 更改为 `nginx:1.11.9` 并删除 `minReadySeconds` 字段：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.11.9 # update the image
          ports:
            - containerPort: 80
```

应用对配置文件所做的更改：

`kubectl apply -f https://k8s.io/examples/application/update_deployment.yam`

使用 `kubectl get` 打印实时对象：

`kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml`

输出结果显示对实时配置有以下更改：

- `replicas` 字段保留由 `kubectl scale` 设置的值 2。这是可能的，因为它是配置文件中省略的。
- `image` 字段从 `nginx:1.7.9` 更新到 `nginx:1.11.9`。
- `last-applied-configuration` 注解已被更新为新的镜像。
- `minReadySeconds` 字段已被清除。
- `last-applied-configuration` 注解不再包含 `minReadySeconds` 字段。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    # ...
    # The annotation contains the updated image to nginx 1.11.9,
    # but does not contain the updated replicas to 2
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.11.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
    # ...
spec:
  replicas: 2 # Set by `kubectl scale`.  Ignored by `kubectl apply`.
  # minReadySeconds cleared by `kubectl apply`
  # ...
  selector:
    matchLabels:
      # ...
      app: nginx
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.11.9 # Set by `kubectl apply`
          # ...
          name: nginx
          ports:
            - containerPort: 80
            # ...
        # ...
    # ...
  # ...
```

> 警告：不支持 `kubectl apply` 和强制对象配置文件指令 `create` 和 `replace` 混用。这是因为 `create` 和 `replace` 不保留 `kubectl apply` 用于更新需要的 `kubectl.kubernetes.io/last-applied-configuration` 字段。

## 如何删除对象

两种方法删除由 `kubectl apply` 管理的对象。

### 推荐方法 `kubectl delete -f <filename>`

建议的方法是使用强制命令手动删除对象，因为它更加明确地说明正在删除的内容，而不太可能导致用户无意中删除某些内容：

`kubectl delete -f <filename>`

### 替代方法 `kubectl apply -f <directory/> --prune -l your=label`

只有当你知道你在做什么时才使用此命令。

> 警告：`kubectl apply --prune` 为 alpha 版本，并且可能在后续的版本中引入向后不兼容的更改。

> 警告：使用此命令时必须小心, 以免无意中删除对象。

作为 `kubectl delete` 的替代方法，你可以使用 `kubectl apply` 指定从目录中删除配置文件后要删除的对象。使用 `--prune` 向 API 服务器查询到满足标签的所有对象，并尝试将返回的实时对象配置与对象配置文件匹配。如果对象与查询匹配，并且目录中没有它的配置文件同时具有 `last-applied-configuration`，则会将其删除。

`kubectl apply -f <directory/> --prune -l <labels>`

> 警告：只应对包含对象配置文件的根目录运行 `prune`。如果对象被指定的标签选择器 `-l <labels>` 查询到并返回，且子目录中没有它的配置文件，则对子目录运行此命令会导致无意中删除这些对象。

## 如何查看对象

你可以使用 `kubectl get` 加 `-o yaml` 来查看实时对象的配置。

`kubectl get -f <filename|url> -o yaml`

## 如何使用 `apply` 计算差异并合并更改

> 注意：**patch** 是一个更新操作，它是作用域是对象的特定字段，而不是整个对象。这样可以仅更新对象上的特定字段集，而不需要先读取对象。

当 `kubectl apply` 更新对象的实时配置，它通过向 API 服务器发送一个补丁请求完成操作。该补丁将更新范围定义为实时对象配置的特定字段。`kubectl apply` 命令使用配置文件、实时配置以及储存在实时配置中的 `last-applied-configuration` 注解计算出此补丁请求。

### 合并补丁的计算

`kubectl apply` 命令将配置文件的内容写入 `kubectl.kubernetes.io/last-applied-configuration` 注解。这用于标识已从配置文件中删除的字段和需要从实时配置中清除的字段。以下是用于计算应删除或设置哪些字段的步骤：

1.计算应删除的字段。这些字段出现在 `last-applied-configuration` 中但在配置文件中不存在。

2.计算应添加或设置的字段。这些字段出现在配置文件中但值于实时配置不匹配。

下面是一个例子。假设这是一个 Deployment 对象的配置文件：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.11.9 # update the image
          ports:
            - containerPort: 80
```

另外，假设这是此 Deployment 对象的实时配置：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    # ...
    # note that the annotation does not contain replicas
    # because it was not updated through apply
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"minReadySeconds":5,"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.7.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
  # ...
spec:
  replicas: 2 # written by scale
  # ...
  minReadySeconds: 5
  selector:
    matchLabels:
      # ...
      app: nginx
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.7.9
          # ...
          name: nginx
          ports:
            - containerPort: 80
        # ...
```

下面是将由 `kubectl apply` 执行的合并计算。

1.通过读取值 `last-applied-configuration` 并将它们与配置文件中的值进行比较来计算要删除的字段。清除在本地对象配置文件中显式设置为 null 的字段，无论它是否出现在 `last-applied-configuration` 中。在此例中，`minReadySeconds` 出现在注解 `last-applied-configuration` 中，但是没有出现在配置文件中。**操作：**从实时配置中清除 `minReadySeconds`。

2.通过读取配置文件中的值并与实时配置中的值进行比较计算出要设置的字段。在此例中，配置文件中 `image` 的值和实时配置中的值不匹配。**操作：**设置实时配置中 `image` 的值。

3.设置 `last-applied-configuration` 注解以匹配配置文件中的值。

4.将 1、2、3 的结果合并到 API 服务器单个补丁请求中。

下面实时配置是合并后的结果：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    # ...
    # The annotation contains the updated image to nginx 1.11.9,
    # but does not contain the updated replicas to 2
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment",
      "metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},
      "spec":{"selector":{"matchLabels":{"app":nginx}},"template":{"metadata":{"labels":{"app":"nginx"}},
      "spec":{"containers":[{"image":"nginx:1.11.9","name":"nginx",
      "ports":[{"containerPort":80}]}]}}}}
    # ...
spec:
  selector:
    matchLabels:
      # ...
      app: nginx
  replicas: 2 # Set by `kubectl scale`.  Ignored by `kubectl apply`.
  # minReadySeconds cleared by `kubectl apply`
  # ...
  template:
    metadata:
      # ...
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.11.9 # Set by `kubectl apply`
          # ...
          name: nginx
          ports:
            - containerPort: 80
            # ...
        # ...
    # ...
  # ...
```

### 如何合并不同类型的字段

如何将配置文件中的特定字段与实时配置合并，取决于字段的类型。有下面几种类型的字段：

- **primitive**：字符串、整数或布尔值的字段。例如，`image` 和 `replicas` 都是原始字段。**操作：**替换。
- **map**，也被称为 **object**：map 类型的字段或包含子字段的复杂类型。例如，`labels`、`annotations`、`spec` 和 `metadata` 都是 map。**操作：**合并元素或子字段。
- **list**：包含可以是基本类型或 map 的项目列表的字段。例如，`containers`、`ports` 和 `args` 都是列表。**操作：**改变。

当 `kubectl apply` 更新 map 或列表字段，它通常不会替换整个字段，而是更新个别子元素。例如，当合并 `spec` 到 Deployment 时，这个 `spec` 不会被替换掉。而是比较、合并类似 `replicas` 这样的 `spec` 子字段。

### 合并对原始字段的更改

原始字段被替换或清除。

> 注意：'-' 表示 **不适用**，因为不使用该值。

| 对象配置文件中的字段 | 实时对象配置中的字段 | `last-applied-configuration` 中的字段 | 操作                         |
| :------------------- | :------------------- | :------------------------------------ | :--------------------------- |
| Yes                  | Yes                  | -                                     | 将实时配置值设置为配置文件值 |
| Yes                  | No                   | -                                     | 将实时配置设置为本地配置     |
| No                   | -                    | Yes                                   | 从实时配置中清除             |
| No                   | -                    | No                                    | 不做操作，保持实时配置值     |

### 合并对 map 字段的更改

通过比较 map 的每个子域或元素来合并 map 字段：

> 注意：'-' 表示 **不适用**，因为不使用该值。

| 对象配置文件中的 key | 实时对象配置中的 key | `last-applied-configuration` 中的字段 | 操作                     |
| :------------------- | :------------------- | :------------------------------------ | :----------------------- |
| Yes                  | Yes                  | -                                     | 比较子字段值             |
| Yes                  | No                   | -                                     | 将实时配置设置为本地配置 |
| No                   | -                    | Yes                                   | 从实时配置中删除         |
| No                   | -                    | No                                    | 不做操作，保持实时配置值 |

### 合并对列表字段的更改

合并更改到列表可以使用下面三种策略的一种：

- 替换列表。
- 合并复杂元素列表中的个别元素。
- 合并原始元素列表。

策略的选择是以每个字段为基础的。

#### 替换列表

将列表视为原始字段。替换或删除整个列表。这会保留顺序。

**示例：**使用 `kubectl apply` 更新 Pod 中容器的 `args` 字段。这将实时配置中的 `args` 值是在为配置文件中的值。以前添加到实时配置中的任何 `args` 元素都将丢失。定义在配置文件中的参数元素的顺序将保留在实时配置中。

```yaml
# last-applied-configuration value
    args: ["a", "b"]

# configuration file value
    args: ["a", "c"]

# live configuration
    args: ["a", "b", "d"]

# result after merge
    args: ["a", "c"]
```

**说明：**合并使用配置文件的值作为新的列表值。

#### 合并复杂元素列表中的个别元素

将列表视为 map，并且将每个元素的特定字段作视为 key。添加、删除或更新单个元素。这不会保留顺序。

此合并策略在每个称为 `patchMergeKey` 的字段上使用特殊标志。`patchMergeKey` 是为 Kubernetes 源代码 [types.go](https://git.k8s.io/api/core/v1/types.go#L2565) 中的每个字段定义的。当合并 map 列表时，对于给定的元素指定为 `patchMergeKey` 的字段被用做该元素 map 的 key。

**示例：**使用 `kubectl apply` 更新 PodSpec 的 `containers` 字段。它会像元素以 `name` 为 key 的 map 合并列表。

```yaml
# last-applied-configuration value
    containers:
    - name: nginx
      image: nginx:1.10
    - name: nginx-helper-a # key: nginx-helper-a; will be deleted in result
      image: helper:1.3
    - name: nginx-helper-b # key: nginx-helper-b; will be retained
      image: helper:1.3

# configuration file value
    containers:
    - name: nginx
      image: nginx:1.10
    - name: nginx-helper-b
      image: helper:1.3
    - name: nginx-helper-c # key: nginx-helper-c; will be added in result
      image: helper:1.3

# live configuration
    containers:
    - name: nginx
      image: nginx:1.10
    - name: nginx-helper-a
      image: helper:1.3
    - name: nginx-helper-b
      image: helper:1.3
      args: ["run"] # Field will be retained
    - name: nginx-helper-d # key: nginx-helper-d; will be retained
      image: helper:1.3

# result after merge
    containers:
    - name: nginx
      image: nginx:1.10
      # Element nginx-helper-a was deleted
    - name: nginx-helper-b
      image: helper:1.3
      args: ["run"] # Field was retained
    - name: nginx-helper-c # Element was added
      image: helper:1.3
    - name: nginx-helper-d # Element was ignored
      image: helper:1.3
```

**说明：**

- 名为 "nginx-helper-a" 的容器被删除，因为没有名为 "nginx-helper-a" 的容器出现在配置文件中。
- 名为 "nginx-helper-b" 的容器保留实时配置中对 `args` 对更改。`kubectl apply` 能够识别实时配置中 "nginx-helper-b" 于配置文件中对 "nginx-helper-b" 相同，即使它们对字段具有不同对值（配置文件中没有 `args`）。这是因为 `patchMergeKey` 字段值（name）是相同的。
- 名为 "nginx-helper-c" 的容器被添加，因为实时配置中没有出现具有该名称的容器，但配置文件中出现具有该名称的容器。
- 名为 "nginx-helper-d" 的容器被保留，因为 `the last-applied-configuration` 中没有出现具有此名称的元素。

#### 合并原始元素列表

从 Kubernetes 1.5 版本开始，不支持合并原始元素列表。

> 注意：给定字段由 [types.go](https://git.k8s.io/api/core/v1/types.go#L2565) 中的 `patchStrategy` 标志控制时应该选择上述策略的哪一种。如果没有为类型列表指定 `patchStrategy`，则替换该列表。

## 默认字段值

如果在创建对象时未指定它们，则 API 服务器会将实时配置中的某些字段设置为默认值。

下面是一个 Deployment 的配置文件。文件没有指定 `strategy`：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

使用 `kubectl apply` 创建对象：

`kubectl apply -f https://k8s.io/examples/application/simple_deployment.yaml`

使用 `kubectl get` 打印实时配置：

`kubectl get -f https://k8s.io/examples/application/simple_deployment.yaml -o yaml`

输出结果显示 API 服务器将实时配置中的多个字段设置为默认值。配置文件中没有指定这些字段。

```yaml
apiVersion: apps/v1
kind: Deployment
# ...
spec:
  selector:
    matchLabels:
      app: nginx
  minReadySeconds: 5
  replicas: 1 # defaulted by apiserver
  strategy:
    rollingUpdate: # defaulted by apiserver - derived from strategy.type
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate # defaulted apiserver
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.7.9
          imagePullPolicy: IfNotPresent # defaulted by apiserver
          name: nginx
          ports:
            - containerPort: 80
              protocol: TCP # defaulted by apiserver
          resources: {} # defaulted by apiserver
          terminationMessagePath: /dev/termination-log # defaulted by apiserver
      dnsPolicy: ClusterFirst # defaulted by apiserver
      restartPolicy: Always # defaulted by apiserver
      securityContext: {} # defaulted by apiserver
      terminationGracePeriodSeconds: 30 # defaulted by apiserver
# ...
```

在补丁请求，默认字段不会被重新设置为默认值，除非它们作为修补程序请求的一部分被明确清除。这可能会导致默认值基于其他字段的字段出现意外的行为。当其他字段改变后，基于它们的默认值不会被更新，除非此默认值被明确地清除。

因此，建议在配置文件中显式地定义服务器默认设置的某些字段，即使所需的值与服务器的默认设置相同。这使得识别不被服务器重新设置为默认值以致于导致冲突的值变得更容易。

示例：

```yaml
# last-applied-configuration
spec:
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80

# configuration file
spec:
  strategy:
    type: Recreate # updated value
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80

# live configuration
spec:
  strategy:
    type: RollingUpdate # defaulted value
    rollingUpdate: # defaulted value derived from type
      maxSurge : 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80

# result after merge - ERROR!
spec:
  strategy:
    type: Recreate # updated value: incompatible with rollingUpdate
    rollingUpdate: # defaulted value: incompatible with "type: Recreate"
      maxSurge : 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

**说明：**

1.用户创建一个没有定义 `strategy.type` 的 Deployment。

2.服务器将 `strategy.type` 为默认值 `RollingUpdate` 并默认地设置 `strategy.rollingUpdate` 的值。

3.用户将 `strategy.type` 设置为 `Recreate`。`strategy.rollingUpdate` 的值保留它们的默认值，但是服务器希望它们被清除。如果 `strategy.rollingUpdate` 的值最初是在配置文件中定义的，那么它们需要被删除将更加清楚。

4.执行失败因为 `strategy.rollingUpdate` 没有被清除。`strategy.rollingUpdate` 字段与 `strategy.type` 为 `Recreate` 冲突。

推荐：这些字段应该被显式地定义在对象配置文件中。

- 工作负载上的 Selectors 和 PodTemplate 标签，例如，Deployment、StatefulSet、Job、DaemonSet、ReplicaSet 和 ReplicationController
- 部署推出策略

### 如何清除由其他修改者设置的服务器默认字段或字段集

可以通过将值设置为 `null` 然后应用配置文件来清除配置文件中未显示的字段。对于服务器默认的字段，此触发器会重新设置其为默认值。

## 如何更改配置文件和直接命令式编辑之间字段的所有权

只有这些方法可以用来改变单个对象的字段：

- 使用 `kubectl apply`
- 直接写入实时配置，而不修改配置文件：例如，使用 `kubectl scale`。

### 将所有者从直接命令式编辑改为配置文件

添加字段到配置文件。对于字段，停止直接更新实时配置而不使用 `kubectl apply`。

### 将所有者从配置文件改为直接命令式编辑

从 Kubernetes 1.5 版本开始，将字段所有权从配置文件改为命令式编辑需要手动执行：

- 从配置文件中输出该字段。
- 从实时对象的注解 `kubectl.kubernetes.io/last-applied-configuration` 中移除该字段。

## 更改管理方法

Kubernetes 对象在同一时间只应该使用一种方法管理。从一种方法切换到另一种方法是可行的，但是需要手动操作。

> 注意：在声明式管理中使用强制删除是可以的。

### 从命令式指令管理迁移到声明式对象配置

从命令式指令管理迁移到声明式对象配置涉及到下面的几个手动步骤：

1.从实时对象导出到本地配置文件：

`kubectl get <kind>/<name> -o yaml --export > <kind>_<name>.yaml`

2.从配置文件中手动地移除 `status` 字段。

> 注意：这一步是可选的，因为即使配置文件中存在状态字段 `kubectl apply` 也不会更新它。

3.为对象设置 `kubectl.kubernetes.io/last-applied-configuration` 注解：

`kubectl replace --save-config -f <kind>_<name>.yaml`

4.将进程更改为仅使用 `kubectl apply` 管理对象。

### 从命令式对象配置迁移到声明式对象配置

1.为对象设置 `kubectl.kubernetes.io/last-applied-configuration` 注解：

`kubectl replace --save-config -f <kind>_<name>.yaml`

2.将进程更改为仅使用 `kubectl apply` 管理对象。

## 定义控制器选择器和 PodTemplate 标签

> 警告：强烈建议不要更新控制器上的选择器。

建议的方法是定义一个单独的、不可变的 PodTemplate 标签，它仅由控制器选择器使用并且没有其他语意。

示例：

```yaml
selector:
  matchLabels:
    controller-selector: 'extensions/v1beta1/deployment/nginx'
template:
  metadata:
    labels:
      controller-selector: 'extensions/v1beta1/deployment/nginx'
```
