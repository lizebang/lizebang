---
title: "使用 docker registry 解决 kubernetes pull 镜像 pull 不下来的问题"
date: 2018-02-07
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- kubernetes
tags:
- kubernetes
keywords:
- kubernetes
- pull error
- docker registry
---

kubernetes 默认会去 gcr.io 上拉取镜像, 由于 GFW 的原因, kubernetes 拉取镜像会失败. 这时, 我们可以让其拉取 docker registry 中的镜像来解决这个问题.

<!--more-->

我使用的是 [阿里云](https://cr.console.aliyun.com/) 的 docker registry.

# 登陆阿里云
点击上面链接注册登陆即可.

![login](/images/2018-02/aliyun-01.png)

# 创建仓库
登陆后直接点击创建仓库, 然后按要求填好即可.

![create](/images/2018-02/aliyun-02.png)

# 登录阿里云 docker registry

创建好之后点击管理, 使用命令行登陆 docker login.

```shell
docker login --username=**** registry.cn-qingdao.aliyuncs.com
```

# 将镜像推送到 registry

```shell
docker pull [ImageId]
docker tag [ImageId] registry.cn-qingdao.aliyuncs.com/abang/k8s:[镜像版本号]
docker push registry.cn-qingdao.aliyuncs.com/abang/k8s:[镜像版本号]
```

例如：

```shell
docker pull mysql
docker tag mysql registry.cn-qingdao.aliyuncs.com/abang/k8s:mysql
docker push registry.cn-qingdao.aliyuncs.com/abang/k8s:mysql
```

# 使用 kubectl 创建 secret

```shell
kubectl create secret docker-registry [secret name] \
  --docker-server=[registry.cn-qingdao.aliyuncs.com] \
  --docker-username=[阿里云登录账号] \
  --docker-password=[阿里云密码] \
  --docker-email=[邮箱]
```

# 使用镜像

```shell
apiVersion: v1
kind: ReplicationController
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          ports:
          - containerPort: 3306
          env:
          - name: MYSQL_ROOT_PASSWORD
            value: "123456"
```

将 `spec.template.spec.containers.image` 的 `mysql` 改成 `registry.cn-qingdao.aliyuncs.com/abang/k8s:mysql` 即可.