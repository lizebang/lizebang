---
title: "Kubernetes 镜像"
slug: kubernetes_concepts_containers_images
date: 2018-09-08
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

原文：https://kubernetes.io/docs/concepts/containers/images/

你可以构建 docker 镜像并将它推到仓库中，以供之后 Kubernetes Pod 使用。

`image` 容器的属性支持与 `docker` 命令相同的语法，包括私有仓库和标记。

<!--more-->

## 更新图像

默认的拉起策略是 `IfNotPresent`，它使 kubelet 在镜像存在时跳过拉取步骤。如果你想总是强制拉取，你可以执行下列操作之一：

- 容器的 `imagePullPolicy` 设置为 `Always`。
- 使用 `:latest` 作为镜像使用的标签。
- 开启 [AlwaysPullImages](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) admission 控制器。

如果你没有指定镜像的标签，则将其视为 `:latest`，相应的镜像拉取策略为 `Always`。

注意，你应该避免使用 `:latest` 标签，请查看 [配置最佳实践](https://k8smeetup.github.io/docs/concepts/configuration/overview/#container-images) 获取更多信息。

## 使用私有仓库

私有仓库可能需要密钥才能从中读取镜像。凭证可以通过下面几种方式提供：

- 使用 Google 容器仓库（GCR）
  - 每个集群都可以配置
  - 在 GCE（Google 计算引擎）或者 GKE（Google Kubernetes 引擎）上自动配置
  - 所有 Pod 可以读取项目的私有仓库
- 使用 AWS EC2 容器仓库（ECR）
  - 使用 IAM 角色和政策去控制对 ECR 仓库对访问
  - 自动刷新 ECR 登陆凭证
- 使用 Azure 容器仓库（ACR）
- 使用 IBM Cloud 容器仓库
- 配置节点对私有仓库进行身份验证
  - 所有 Pod 可以读取任何配置好的私有仓库
  - 要求通过集群管理员配置节点
- 预先拉取镜像
  - 所有 Pod 可以使用缓存在节点上的所有镜像
  - 要求以 root 权限访问所有节点完成设置
- 在 Pod 中指定 ImagePullSecrets
  - 只有提供了自己密钥的 Pod 才能访问私有仓库

下面将详细介绍每个选项。

### 使用 Google 容器仓库

当运行在 Google 计算引擎（GCE）上时，Kubernetes 原生支持 Google 容器仓库（GCR）。如果你的集群运行在 Google 计算引擎或 Google Kubernetes 引擎上时，只需简单的使用完整镜像名（例如 `gcr.io/my_project/image:tag`）。

集群中所有的 Pod 都可以读取此仓库中的镜像。

kubelet 将通过实例的 Google 服务帐户对 GCR 进行身份验证。实例上的服务帐户有一个 `https://www.googleapis.com/auth/devstorage.read_only`，所以它可以从项目的 GCR 拉取，但是不能推送。

### 使用 AWS EC2 容器仓库

当运行在 AWS EC2 实例上时，Kubernetes 原生支持 [AWS EC2 容器仓库](https://aws.amazon.com/ecr/)。

只需在 Pod 定义中使用完整的图像名称（例如 `ACCOUNT.dkr.ecr.REGION.amazonaws.com/imagename:tag`）。

集群中所有能够创建 Pod 的用户都能够运行使用 ECR 仓库中任何镜像的 Pod。

kubelet 将获取并定期刷新 ECR 凭证。它需要以下权限才能执行此操作：

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:GetRepositoryPolicy`
- `ecr:DescribeRepositories`
- `ecr:ListImages`
- `ecr:BatchGetImage`

需求：

- 你必须使用 `v1.2.0` 或更新版本的 kubelet。（例如，运行 `/usr/bin/kubelet --version=true`）
- 如果你的节点在区域 A 并且你的仓库在不同的区域 B，你需要 `v1.3.0` 或更新的版本。
- ECR 必须在你的区域提供

故障排查：

- 验证是否上面所有要求。
- 在工作组上获取 \$REGION（如 `us-west-2`）凭证。通过 SSH 进入主机，并使用这些凭证手动运行 docker。它能运行吗？
- 确定 kubelet 是用 `--cloud-provider=aws` 运行的。
- 查看 kubelet 日志（例如 `journalctl -u kubelet`）中类似下面这样的日志行：
  - `plugins.go:56] Registering credential provider: aws-ecr-key`
  - `provider.go:91] Refreshing cache for provider: *aws_credentials.ecrProvider`

### 使用 Azure 容器仓库

使用 [Azure 容器仓库](https://azure.microsoft.com/en-us/services/container-registry/) 你可以使用管理员或服务主体进行身份验证。任何情况下，认证都是通过标准的 docker 认证完成的。这些指令假定为 [azure-cli](https://github.com/azure/azure-cli) 命令行工具。

你首先需要创建仓库并生成凭证，有关这方面的完整文档可以在 [Azure 容器仓库文档](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli) 中找到。

创建容器仓库后，你将使用下面这些凭证去登录：

- `DOCKER_USER`：服务主体或管理员用户名
- `DOCKER_PASSWORD`：服务主体密码或管理员用户密码
- `DOCKER_REGISTRY_SERVER`：`${some-registry-name}.azurecr.io`
- `DOCKER_EMAIL`：`${some-email-address}`

填好了这些变量之后，你就可以 [配置 Kubernetes Secret 并使用它部署 Pod]

### 使用 IBM Cloud 容器仓库

IBM Cloud 容器仓库提供了一个多租户私有镜像仓库，你可以使用它来安全地存储和共享 docker 镜像。默认情况下，私有仓库的镜像被集成的检测安全问题和潜在漏洞的漏洞顾问扫描过。在你的 IBM Cloud 账户中的用户可以访问你的镜像，也可以创建一个令牌来授予对仓库命名空间的访问权限。

要安装 IBM Cloud Container Registry CLI 插件并为镜像创建命名空间，请参阅 [IBM Cloud 容器仓库入门](https://console.bluemix.net/docs/services/Registry/index.html#index)。

你可以使用 IBM Cloud 容器仓库通过 [IBM Cloud 公共镜像](https://console.bluemix.net/docs/services/RegistryImages/index.html#ibm_images) 和你的私有镜像部署容器到你 IBM Cloud Kubernetes Service 集群的 `default` 命名空间。要将容器部署到其他名称空间，或使用来自其他 IBM Cloud Container Registry 区域或 IBM Cloud 帐户的映像，请创建 Kubernetes `imagePullSecret`。更多信息请参阅 [使用镜像构建容器](https://console.bluemix.net/docs/containers/cs_images.html#images)。

### 配置节点对私有仓库进行身份验证

> 注意：如果你在 Google Kubernetes 引擎上运行，每个节点上已经存在一个 `.dockercfg`，它具有 Google 容器仓库的凭证。因此，你不能使用此方法。
> 注意：如果你在 AWS EC2 上运行并且使用 EC2 容器仓库（ECR），每个节点上的 kubelet 将管理和更新 ECR 登录凭证。因此，你不能使用此方法。
> 注意：如果可以控制节点配置，此方法非常适合。它无法可靠地在 GCE 和任何其他云服务提供商上进行自动节点替换。

docker 将私有仓库的密钥存储在文件 `$HOME/.dockercfg` 中或 `$HOME/.docker/config.json` 中。如果你在下面的搜索路径列表中放置了相同的文件，kubelet 会在拉取镜像时将其用作凭证提供程序。

- `{--root-dir:-/var/lib/kubelet}/config.json`
- `{cwd of kubelet}/config.json`
- `${HOME}/.docker/config.json`
- `/.docker/config.json`
- `{--root-dir:-/var/lib/kubelet}/.dockercfg`
- `{cwd of kubelet}/.dockercfg`
- `${HOME}/.dockercfg`
- `/.dockercfg`

> 注意：你可能需要在环境文件中明确地为 kubelet 设置 `HOME=/root`。

下面是配置节点使用私有仓库的建议步骤。在此示例中，在台式机/笔记本电脑上运行这些：

1.运行 `docker login [server]` 以使用的每组凭据，它更新 `$HOME/.docker/config.json`。

2.在不进去中查看 `$HOME/.docker/config.json` 确保它只包含想使用的凭证。

3.获取节点列表，例如：

> 1.如果你想要这些名字：

```shell
nodes=$(kubectl get nodes -o jsonpath='{range.items[*].metadata}{.name} {end}')
```

> 2.如果你想要这些 IP：

```shell
nodes=$(kubectl get nodes -o jsonpath='{range .items[*].status.addresses[?(@.type=="ExternalIP")]}{.address} {end}')
```

4.复制本地 `.docker/config.json` 到上面的搜索路径列表之一，例如：

```shell
for n in $nodes; do scp ~/.docker/config.json root@$n:/var/lib/kubelet/config.json; done
```

通过创建使用私有镜像的 Pod 进行验证，例如：

```shell
kubectl create -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: private-image-test-1
spec:
  containers:
    - name: uses-private-image
      image: $PRIVATE_IMAGE_NAME
      imagePullPolicy: Always
      command: [ "echo", "SUCCESS" ]
EOF
pod/private-image-test-1 created
```

如果一切正常，那么过一会儿，你应该看到：

```shell
kubectl logs private-image-test-1
SUCCESS
```

如果失败，你将看到：

```shell
kubectl describe pods/private-image-test-1 | grep "Failed"
  Fri, 26 Jun 2015 15:36:13 -0700    Fri, 26 Jun 2015 15:39:13 -0700    19    {kubelet node-i2hq}    spec.containers{uses-private-image}    failed        Failed to pull image "user/privaterepo:v1": Error: image user/privaterepo:v1 not found
```

你必须确保群集中的所有节点都具有相同的 `.docker/config.json`。否则，pod 将在某些节点上运行而无法在其他节点上运行。例如，如果使用节点自动缩放，则每个实例模板都需要包含 `.docker/config.json` 或装载包含它的驱动器。

一旦将私有仓库密钥添加到 `.docker/config.json`，所有 Pod 都可以读取私有仓库中的任何镜像。

### 预先拉取镜像

> 注意：如果你运行在 Google Kubernetes 引擎上，每个节点上已经存在一个带有 Google 容器仓库凭证的文件 `.dockercfg`。因此，你不能使用此方法。
> 注意：如果可以控制节点配置，此方法非常适合。它无法可靠地在 GCE 和任何其他云服务提供商上进行自动节点替换。

默认情况下，kubelet 将尝试从指定的仓库中提取每个镜像。然而，如果容器的 `imagePullPolicy` 属性设置为 `IfNotPresent` 或 `Never`，则使用本地镜像（优先地、专门地、各自地）

如果你希望依赖预先拉取镜像代替仓库身份验证，则必须确保集群中的所有节点预先拉取了相同的镜像。

这可以用于预先加载某些镜像以提高速度，或者作为对私有仓库进行身份验证的替代方法。

所有 Pod 都可以读取任何预先拉取的镜像。

### 在 Pod 中指定 ImagePullSecrets

> 注意：此方法目前时 Google Kubernetes 引擎、Google 计算引擎和所有云提供商推荐的方法。

Kubernetes 支持 Pod 中指定仓库密钥。

#### 使用 docker 配置创建 Secret

运行以下命令，替换相应的大写值：

```shell
kubectl create secret docker-registry myregistrykey --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=DOCKER_EMAIL
secret/myregistrykey created.
```

如果你需要访问多个仓库，则可以为每个仓库创建一个 secret。当为 Pod 拉取镜像时，kubelet 将合并所有的 `imagePullSecrets` 到一个虚拟的 `.docker/config.json`。

Pod 只能在自己的命名空间使用拉取镜像用的 secrets，因此每个命名空间都需要执行一次此过程。

#### 绕过 kubectl 创建 secrets

如果由于某种原因你需要多个项在同一个 `.docker/config.json` 中，或者需要上面命令没有提供的控制，那么你可以 [使用 json 或 yaml 创建 secret](https://kubernetes.io/docs/user-guide/secrets/#creating-a-secret-manually)。

请确保：

- 将数据项的名称设置为 `.dockerconfigjson`
- 使用 base64 对 docker 文件进行编码，粘贴生成的字符串，将其作为字段 `data[".dockerconfigjson"]` 的值
- 将 `type` 设置为 `kubernetes.io/dockerconfigjson`

例子：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myregistrykey
  namespace: awesomeapps
data:
  .dockerconfigjson: UmVhbGx5IHJlYWxseSByZWVlZWVlZWVlZWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGx5eXl5eXl5eXl5eXl5eXl5eXl5eSBsbGxsbGxsbGxsbGxsbG9vb29vb29vb29vb29vb29vb29vb29vb29vb25ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubmdnZ2dnZ2dnZ2dnZ2dnZ2dnZ2cgYXV0aCBrZXlzCg==
type: kubernetes.io/dockerconfigjson
```

如果你收到错误信息 `error: no objects passed to create`，这可能意味着 base64 编码的字符串无效。如果你收到的类似 `Secret "myregistrykey" is invalid: data[.dockerconfigjson]: invalid value ...` 错误信息，这意味着数据已成功地编码为 un-base64，但无法解析为一个 `.docker/config.json` 文件。

#### 在 Pod 中引用 imagePullSecrets

现在，你可以通过添加 `imagePullSecrets` 部分到 Pod 定义中来创建引用 secret 到 Pod。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
  namespace: awesomeapps
spec:
  containers:
    - name: foo
      image: janedoe/awesomeapp:v1
  imagePullSecrets:
    - name: myregistrykey
```

这需要对每个使用私有仓库的 Pod 进行操作。

但是，通过在 [serviceAccount](https://kubernetes.io/docs/user-guide/service-accounts) 资源中设置 imagePullSecrets，可以自动设置此字段。

你可以将其与每个节点的 `.docker/config.json` 结合使用。凭证将会被合并。这种方法适用于 Google Kubernetes 引擎。

##### 应用场景

有许多配置私有仓库的解决方案。以下是一些常见的应用场景和建议的解决方案。

1.集群只运行非专有镜像（例如，开源的）。不需要隐藏镜像。

使用 docker hub 上使用公共镜像

- 不需要配置。
- 在 GCE 或 GKE 上，自动使用本地镜像以提高速度和可用性。

  2.集群运行一些专有镜像，这些镜像应该对公司以外用户进行隐藏，但对所有集群用户都是可见的。

- 使用托管的私有 [docker 仓库](https://docs.docker.com/registry/)。
  - 它可能被托管在 [docker hub](https://hub.docker.com/signup/) 上，或其他地方。
  - 像上面描述的那样在每个节点上手动配置 .docker/config.json。
- 或者，在防火墙后面运行内部私有仓库，并打开读取访问权限。
  - 不需要 Kubernetes 配置。
- 或者，在 GCE 或 GKE 上，使用项目的 Google 容器仓库。
- 或者，在更改节点配置不方便的集群上，使用 `imagePullSecrets`。

  3.拥有专有镜像的集群，其中一些需要更严格的访问控制。

- 确保 [AlwaysPullImages admission 控制器](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) 打开。否则，所有 Pod 都可能访问所有镜像。
- 将敏感数据移动到 "Secret" 资源中，而不是将其打包在镜像中。

  4.多租户集群，每个租户都需要自己的私有仓库。

- 确保 [AlwaysPullImages admission 控制器](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) 打开。否则，所有 Pod 都可能访问所有镜像。
- 运行需要授权的私有仓库。
- 为每个租户生成仓库凭证，将其放到 secret 中，并将 secret 填充到每个租户命名空间。
- 租户将 secret 添加到每个命名空间的 imagePullSecrets 中。
