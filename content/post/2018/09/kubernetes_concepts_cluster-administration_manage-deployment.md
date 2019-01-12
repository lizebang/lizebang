---
title: 'Kubernetes 管理资源'
slug: kubernetes_concepts_cluster-administration_manage-deployment
date: 2018-09-05
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

原文：https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/

你已经部署了你的应用程序并通过服务暴露它。现在干什么呢？Kubernetes 提供了许多工具帮助你管理应用程序的部署，包括缩放和升级。我们将更深入地讨论的功能包括 [配置文件](https://kubernetes.io/docs/concepts/configuration/overview/) 和 [标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)。

<!--more-->

## 组织资源配置

许多应用程序需要创建多个资源，例如，Deployment 和 Service。多资源的管理可以通过将它们组合在同一个文件中（在 YAML 中使用 `---` 分隔）来简化。例如：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
  labels:
    app: nginx
spec:
  replicas: 3
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
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

可以使用与单个资源相同的方式创建多个资源：

```shell
$ kubectl create -f https://k8s.io/examples/application/nginx-app.yaml
service/my-nginx-svc created
deployment.apps/my-nginx created
```

资源将按照它们在文件中出现的顺序创建。因此，最好首先指定服务，这将确保调度器可以扩展与服务关联的 pod，因为它们是由控制器创建的，例如 Deployment。

`kubectl create` 还可以接受多 `-f` 参数：

```shell
$ kubectl create -f https://k8s.io/examples/application/nginx/nginx-svc.yaml -f https://k8s.io/examples/application/nginx/nginx-deployment.yaml
```

并且可以指定目录而不是单个文件：

```shell
$ kubectl create -f https://k8s.io/examples/application/nginx/
```

`kubectl` 可以读取任何后缀为 `.yaml`、`.yml` 或 `.json` 的文件。

建议的做法是将与同一微服务或应用程序层相关的资源放入同一文件中，并将与应用程序关联的所有文件分组到同一目录中。如果应用程序层使用 DNS 相互绑定, 则可以简单地部署堆栈中的所有组件。

URL 也可以被指定为配置源，这使得直接从 github 选中配置文件进行部署变得非常简单：

```shell
$ kubectl create -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx/nginx-deployment.yaml
deployment.apps/my-nginx created
```

## kubectl 中的批量操作

资源创建不是 `kubectl` 唯一的批量操作。它还可以从配置文件中提取资源名以执行其他操作，尤其是删除您创建的相同资源：

```shell
$ kubectl delete -f https://k8s.io/examples/application/nginx-app.yaml
deployment "my-nginx" deleted
service "my-nginx-svc" deleted
```

在仅有两个资源的情况下，使用 `resource/name` 语法在命令行上同时指定它们也很容易：

```shell
$ kubectl delete deployments/my-nginx services/my-nginx-svc
```

对于大量资源，你会发现使用 `-l` 或 `--selector`指定选择器按标签过滤资源更加容易：

```shell
$ kubectl delete deployment,services -l app=nginx
deployment.apps "my-nginx" deleted
service "my-nginx-svc" deleted
```

因为 `kubectl` 输出资源名与它接受的语法相同，使用 `$()` 或 `xargs` 很容易完成链接操作。

```shell
$ kubectl get $(kubectl create -f docs/concepts/cluster-administration/nginx/ -o name | grep service)
NAME           TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)      AGE
my-nginx-svc   LoadBalancer   10.0.0.208   <pending>     80/TCP       0s
```

使用上述命令，我们首先创建 `examples/application/nginx/` 下的资源并使用 `-o name` 格式化输出创建的资源（按照 resource/name 的格式打印每个资源）。然后，我们用 `grep` 筛选出 `服务`，并使用 `kubectl get` 打印它。

如果你碰巧在特定目录中的多个子目录中组织资源，则还可以通过在 `--filename,-f` 后指定 `--recursive` 或 `-R` 递归地对子目录执行操作。

例如，假设有一个目录 `project/k8s/development` 包含开发环境所需的所有清单，并将它们按资源类型组织起来：

```shell
project/k8s/development
├── configmap
│   └── my-configmap.yaml
├── deployment
│   └── my-deployment.yaml
└── pvc
    └── my-pvc.yaml
```

默认情况下，执行批量操作 `project/k8s/development` 将停止在目录的第一级，而不是处理所有子目录。如果我们尝试使用以下命令在此目录中创建资源，我们将遇到错误：

```shell
$ kubectl create -f project/k8s/development
error: you must provide one or more resources by argument or filename (.json|.yaml|.yml|stdin)
```

相反，使用 `--filename,-f` 时加上 `--recursive` 或 `-R` 标志，如下所示：

```shell
$ kubectl create -f project/k8s/development --recursive
configmap "my-config" created
deployment "my-deployment" created
persistentvolumeclaim "my-pvc" created
```

`--recursive` 标志适用于任何接受 `--filename,-f` 的标志，例如：`kubectl {create,get,delete,describe,rollout}` 等。

`--recursive` 标志当 `-f` 提供多个参数时，该标志也有效：

```shell
$ kubectl create -f project/k8s/namespaces -f project/k8s/development --recursive
namespace "development" created
namespace "staging" created
configmap "my-config" created
deployment "my-deployment" created
persistentvolumeclaim "my-pvc" created
```

如果你有兴趣了解更多信息 `kubectl`，请继续阅读 [kubectl 概述](https://kubernetes.io/docs/reference/kubectl/overview/)。

## 有效使用标签

到目前为止我们使用的示例最多只将一个标签应用于资源。在许多情况下，应使用多个标签来区分集合。

例如，不同应用程序 `app` 标签使用不同的值，但是多层应用程序（例如，[留言簿示例](https://github.com/kubernetes/examples/tree/master/guestbook/)）还需要区分每个层。前端可以带有以下标签：

```shell
     labels:
        app: guestbook
        tier: frontend
```

而 Redis 的主从节点有不同的 `tier` 标签，并且可能还有一个额外的 `role` 标签：

```shell
     labels:
        app: guestbook
        tier: backend
        role: master
```

和

```shell
     labels:
        app: guestbook
        tier: backend
        role: slave
```

标签允许我们沿着标签指定的任何维度切割资源：

```shell
$ kubectl create -f examples/guestbook/all-in-one/guestbook-all-in-one.yaml
$ kubectl get pods -Lapp -Ltier -Lrole
NAME                           READY     STATUS    RESTARTS   AGE       APP         TIER       ROLE
guestbook-fe-4nlpb             1/1       Running   0          1m        guestbook   frontend   <none>
guestbook-fe-ght6d             1/1       Running   0          1m        guestbook   frontend   <none>
guestbook-fe-jpy62             1/1       Running   0          1m        guestbook   frontend   <none>
guestbook-redis-master-5pg3b   1/1       Running   0          1m        guestbook   backend    master
guestbook-redis-slave-2q2yf    1/1       Running   0          1m        guestbook   backend    slave
guestbook-redis-slave-qgazl    1/1       Running   0          1m        guestbook   backend    slave
my-nginx-divi2                 1/1       Running   0          29m       nginx       <none>     <none>
my-nginx-o0ef1                 1/1       Running   0          29m       nginx       <none>     <none>
$ kubectl get pods -lapp=guestbook,role=slave
NAME                          READY     STATUS    RESTARTS   AGE
guestbook-redis-slave-2q2yf   1/1       Running   0          3m
guestbook-redis-slave-qgazl   1/1       Running   0          3m
```

## 金丝雀部署

需要多个标签的另一种情况是区分不同版本的部署或同一组件的配置。通常的做法是将新应用程序版本的 canary（通过 Pod 模板中的图像标志指定）与先前版本并排部署，以便新版本可以在完全推出之前接收实时生产流量。

例如，你可以使用 `track` 标签区分不同的版本。

主要的稳定版本的 `track` 标签值为 `stable`：

```yaml
     name: frontend
     replicas: 3
     ...
     labels:
        app: guestbook
        tier: frontend
        track: stable
     ...
     image: gb-frontend:v3
```

然后你可以创建 `track` 标签带有不同值（如 `canary`）的留言簿前端新版本，这样两组 Pod 就不会重复：

```yaml
     name: frontend-canary
     replicas: 1
     ...
     labels:
        app: guestbook
        tier: frontend
        track: canary
     ...
     image: gb-frontend:v4
```

前端服务将通过选择其标签的公共子集（即省略 `track` 标签）来跨越两组副本，以便将流量重定向到两个应用程序：

```yaml
selector:
  app: guestbook
  tier: frontend
```

你可以调整 stable 和 canary 版本的副本数量，以确定将接收实时产生流量的每个版本的比例（在本例中为 3:1）。一旦你有信心，就可以将新的应用程序版本更新为 stable track，并移除 canary track。

更多具体的示例，请点击 [Ghost 部署教程](https://github.com/kelseyhightower/talks/tree/master/kubecon-eu-2016/demo#deploy-a-canary)。

## 更新标签

在创建新资源之前，有时需要重新标记现有的 Pod 和其他资源。这可以使用 `kubectl label` 来完成。例如，如果要将所有 nginx pods 标记为前端层，只需运行：

```shell
$ kubectl label pods -l app=nginx tier=fe
pod/my-nginx-2035384211-j5fhi labeled
pod/my-nginx-2035384211-u2c7e labeled
pod/my-nginx-2035384211-u3t6x labeled
```

首先过滤标签为 "app=nginx" 的所有 pod，然后使用 "tier=fe" 标记它们。要查看刚刚标记的 pod，请运行：

```shell
$ kubectl get pods -l app=nginx -L tier
NAME                        READY     STATUS    RESTARTS   AGE       TIER
my-nginx-2035384211-j5fhi   1/1       Running   0          23m       fe
my-nginx-2035384211-u2c7e   1/1       Running   0          23m       fe
my-nginx-2035384211-u3t6x   1/1       Running   0          23m       fe
```

这将输出所有 "app=nginx" 的 Pod，并 Pod 包含 tier 附加标签列（使用 `-L` 或 `--label-columns`）。

有关更多信息，请参考 [标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) 和 [kubectl 标签](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#label)。

## 更新注解

有时你会想要将注解附加到资源上。注解是用于 API 客户端（例如，工具、库等）检索的任意非标识元数据。这可以通过 `kubectl annotate` 完成 。例如：

```shell
$ kubectl annotate pods my-nginx-v4-9gw19 description='my frontend running nginx'
$ kubectl get pods my-nginx-v4-9gw19 -o yaml
apiversion: v1
kind: pod
metadata:
  annotations:
    description: my frontend running nginx
...
```

有关更多信息，请参考 [注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) 和 [kubectl 注释](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#annotate) 的文档。

## 缩放应用程序

当要增大或缩小应用程序的负载时，可以使用 `kubectl` 轻松完成缩放。例如，要将 `nginx` 副本的数量从 3 减少到 1，请执行以下操作：

```shell
$ kubectl scale deployment/my-nginx --replicas=1
deployment.extensions/my-nginx scaled
```

现在，你只有一个由部署管理的 pod。

```shell
$ kubectl get pods -l app=nginx
NAME                        READY     STATUS    RESTARTS   AGE
my-nginx-2035384211-j5fhi   1/1       Running   0          30m
```

要让系统根据需要自动选择 nginx 副本的数量，范围从 1 到 3，请执行以下操作：

```shell
$ kubectl autoscale deployment/my-nginx --min=1 --max=3
horizontalpodautoscaler.autoscaling/my-nginx autoscaled
```

现在, 你的 nginx 副本可以根据需要自动缩放。

更多信息，请查看 [kubectl scale](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#scale)、[kubectl autoscale](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#autoscale) 和 [horizontal Pod autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) 的文档。

## 就地更新资源

有时需要对您创建的资源进行简单，无中断的更新。

### kubectl apply

建议在源码管理系统中维护一组配置文件（请看 [配置即代码](http://martinfowler.com/bliki/InfrastructureAsCode.html)），以便可以对它们配置资源的代码进行维护和版本化。然后，你可以使用 [kubectl](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#apply) 将配置更改推送到集群。

此命令将比较正在推送的配置版本与先前版本，并应用你所做的更改，而不会覆盖对尚未指定的属性的任何自动更改。

```shell
$ kubectl apply -f https://k8s.io/examples/application/nginx/nginx-deployment.yaml
deployment.apps/my-nginx configured
```

请注意，`kubectl apply` 将注释附加到资源，以确定自上次调用以来对配置的更改。调用它时，`kubectl apply` 在资源的先前配置、提供的输入和当前配置之间进行比较，以确定如何修改资源。

目前，在没有注释的情况下创建资源，第一次调用 `kubectl apply` 将所提供的输入和资源的当前配置之间进行比较。在第一次调用期间，它无法检测创建资源时属性集的删除。因此，它不会删除它们。

后续调用的所有 `kubectl apply` 和修改配置的其他命令（如 `kubectl replace` 和 `kubectl edit`）将更新注解。它们允许后续调用 `kubectl apply` 使用三个配置差异检测和执行删除。

> 注意：要使用 apply，请使用 `kubectl apply` 或 `kubectl create --save-config` 创建资源。

### kubectl edit

或者，也可以使用 `kubectl edit` 更新资源：

```shell
$ kubectl edit deployment/my-nginx
```

这相当于首先 `get` 资源，在文本编辑器中编辑它，然后 `apply` 更新版本后的资源：

```shell
$ kubectl get deployment my-nginx -o yaml > /tmp/nginx.yaml
$ vi /tmp/nginx.yaml
# do some edit, and then save the file
$ kubectl apply -f /tmp/nginx.yaml
deployment.apps/my-nginx configured
$ rm /tmp/nginx.yaml
```

这使你可以进行重要的更改更简单。请注意，你可以在环境变量中使用 `EDITOR` 和 `KUBE_EDITOR` 指定编辑器。

### kubectl patch

你可以使用 `kubectl patch` 更新 API 对象。此命令支持 JSON 补丁、JSON 合并补丁和战略合并补丁。请看 [使用 kubectl patch 更新 API 对象](https://kubernetes.io/docs/tasks/run-application/update-api-object-kubectl-patch/) 和 [kubectl patch](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands/#patch)。

## 破坏性更新

在某些情况下，你可能需要更新在初始化后无法更新的资源字段，或者你可能只是希望立即进行递归更改，例如修复由 Deployment 创建的损坏的 pod。若要更改此类字段，请使用 `replace --force`，删除并重新创建资源。在这种情况下，你只需修改原始配置文件即可：

```shell
$ kubectl replace -f https://k8s.io/examples/application/nginx/nginx-deployment.yaml --force
deployment.apps/my-nginx deleted
deployment.apps/my-nginx replaced
```

## 在不中断服务的情况下更新应用程序

在某些时候，你最终需要更新已部署的应用程序，通常是通过指定新的图像或图像标记，就像上面的金丝雀部署方案一样。`kubectl` 支持多种更新操作，每种操作都适用于不同的场景。

我们将指导你如何使用 Deployments 创建和更新应用程序。如果部署的应用程序由 Replication Controllers 管理，则应阅读 [如何使用 `kubectl rolling-update`](https://kubernetes.io/docs/tasks/run-application/rolling-update-replication-controller/)。

假设你运行 1.7.9 版本的 nginx：

```shell
$ kubectl run my-nginx --image=nginx:1.7.9 --replicas=3
deployment.apps/my-nginx created
```

要升级到 1.9.1 版本，简单地将 `.spec.template.spec.containers[0].image` 从 `nginx:1.7.9` 改为 `nginx:1.9.1` 并运行我们在上面学到的 kubectl 命令。

```shell
$ kubectl edit deployment/my-nginx
```

就是这样！Deployment 将以声明方式逐步更新已部署的 nginx 应用程序。它确保在更新时只有一定数量的旧副本可能会关闭，并且在所需数量的 Pod 之上只能创建一定数量的新副本。要了解有关它的更多详细信息，请访问 [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)。
