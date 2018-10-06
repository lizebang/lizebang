---
title: '使用 kubeadm 创建单 master 集群'
slug: create-cluster-kubeadm
date: 2018-08-26
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - kubernetes
tags:
  - kubernetes
keywords:
  - kubernetes
  - kubeadm
  - setup
---

怎样使用 kubeadm 创建 Kubernetes 集群呢？请阅读下面内容。

<!--more-->

## [安装 kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)

我使用的机器：4 台 8 GB E3-1220 v5 CentOS 7 服务器

### [开始前单准备](https://kubernetes.io/docs/setup/independent/install-kubeadm/#before-you-begin)

要求：

- 一台或多台机器运行下列中系统：
  - Ubuntu 16.04+
  - Debian 9
  - CentOS 7
  - RHEL 7
  - Fedora 25/26 (best-effort)
  - HypriotOS v1.0.1+
  - Container Linux (tested with 1800.6.0)
- 每台机器有 2 GB 或者更多的内存
- 双核或者更多
- 集群中的所有计算机之间都可以进行网络连接（公网或私网都行）
- 每个节点有唯一单主机名、MAC 地址、product_uuid
- 禁用 swap，必须禁用 swap 来确保 kubelet 正常工作

暂时关闭 swap

```shell
swapoff -a
```

永久关闭 `vim /etc/fstab` 将 swap 那一行注释掉。

### [检验 MAC 地址、product_uuid 是否唯一](https://kubernetes.io/docs/setup/independent/install-kubeadm/#verify-the-mac-address-and-product-uuid-are-unique-for-every-node)

通过 `ip link` 或 `ifconfig -a` 命令获取 MAC 地址。

通过 `cat /sys/class/dmi/id/product_uuid` 获取 product_uuid。

### [检查网络适配器](https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-network-adapters)

### [检查所需的端口](https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports)

Master node(s)

| Protocol | Direction | Port Range | Purpose                 | Used By              |
| :------- | :-------- | :--------- | :---------------------- | :------------------- |
| TCP      | Inbound   | 6443\*     | Kubernetes API server   | All                  |
| TCP      | Inbound   | 2379-2380  | etcd server client API  | kube-apiserver, etcd |
| TCP      | Inbound   | 10250      | Kubelet API             | Self, Control plane  |
| TCP      | Inbound   | 10251      | kube-scheduler          | Self                 |
| TCP      | Inbound   | 10252      | kube-controller-manager | Self                 |

Worker node(s)

| Protocol | Direction | Port Range  | Purpose               | Used By             |
| :------- | :-------- | :---------- | :-------------------- | :------------------ |
| TCP      | Inbound   | 10250       | Kubelet API           | Self, Control plane |
| TCP      | Inbound   | 30000-32767 | NodePort Services\*\* | All                 |

### [安装 docker](https://kubernetes.io/docs/setup/independent/install-kubeadm/#installing-docker)

Kubernetes 官方建议 docker 使用 17.03 版本。（最新版本 docker 可以正常运行）

安装 17.03 版本 docker（其他系统请查看 [guides](https://docs.docker.com/install/)）

[rpm repository](https://download.docker.com/linux/centos/7/x86_64/stable/Packages/)

```shell
yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm
```

### [安装 kubeadm、kubelet 和 kubectl](https://kubernetes.io/docs/setup/independent/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

CentOS 上安装过程

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet
```

setenforce 0 禁用 SELinux 以允许容器访问主机文件系统。永久禁用 `vim /etc/sysconfig/selinux` 将 `SELINUX=enforcing` 改为 `SELINUX=disabled`。

```shell
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

由于 GFW 缘故需要翻墙，我使用的是 shadowsocs/v2ray + privoxy

shadowsocs/v2ray -- 代理软件

privoxy -- 桥接 HTTP 代理到 Socks5

privoxy 将 `forward-socks5t / 127.0.0.1:1080 .` 加到 `/etc/privoxy/config` 中，其中 1080 为端口号。

### [配置 kubelet 使用的 cgroup 驱动](https://kubernetes.io/docs/setup/independent/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-master-node)

使用 docker 时，kubeadm 会自动检测 kubelet 的 cgroup 驱动程序，并在运行时将其设置在 `/var/lib/kubelet/kubeadm-flags.env` 中。

使用其他 CRI 时，在 `/etc/default/kubelet` 文件中配置 `cgroup-driver` 值，例如：

```file
KUBELET_KUBEADM_EXTRA_ARGS=--cgroup-driver=<value>
```

记住，只在 cgroup 驱动不是 `cgroupfs` 时，进行这项工作。

最后重启 `kubelet`

```shell
systemctl daemon-reload
systemctl restart kubelet
```

## [创建集群](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

### [初始化主节点](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#initializing-your-master)

```shell
kubeadm init <args>
```

开始使用集群到准备

- 普通用户

  ```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```

- root 用户（当然也可以使用普通用户的方法）
  ```shell
  export KUBECONFIG=/etc/kubernetes/admin.conf
  ```

### [安装 Pod 网络组件](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)

必须安装 Pod 网络组件，Pods 间才能通讯。

网络必须在任何之前部署。同时，CoreDNS 也不会在网络部署好前启动。kubeadm 只支持基于容器网络接口（CNI）的网络（不支持 kubenet）。

举个例子 [Calico v3.2](https://docs.projectcalico.org/v3.2/getting-started/kubernetes/)

```shell
kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/etcd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/rbac.yaml
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/calico.yaml
kubectl get pods --all-namespaces
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### [添加节点](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#join-nodes)

```shell
kubeadm join <master-ip>:<master-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

如果没有 token，可以使用下面的命令从主节点上获取。

```shell
kubeadm token list
```

默认情况下，令牌在 24 小时后过期。如果在当前令牌过期后，则可以在主节点上运行下面的命令来创建新令牌。

```shell
kubeadm token create
```

如果没有 --discovery-token-ca-cert-hash 的值，则可以在主节点上运行下面的命令来获取。

```shell
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

#### [让非主节点控制集群（可选的）](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#optional-controlling-your-cluster-from-machines-other-than-the-master)

```shell
scp root@<master ip>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
```

#### [代理 API Server 到 localhost（可选的）](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#optional-proxying-api-server-to-localhost)

```shell
scp root@<master ip>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf proxy
```

### [销毁](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#tear-down)

node [drain the node](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#drain)

```shell
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
```

master [kubeadm reset](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/)

```shell
kubeadm reset
```

### [维护集群](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#lifecycle)

[Instructions](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm)

### [探索其他插件](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#other-addons)

[list of add-ons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)

### [扩展](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#whats-next)

- 检验集群是否运行正常 -- [Sonobuoy](https://github.com/heptio/sonobuoy)
- kubeadm 高级用法 -- [reference](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm)
- 配置日志轮换，使用 logrotate -- 使用 docker 时，可以为 Docker 守护程序指定日志轮换选项，例子 `--log-driver=json-file --log-opt=max-size=10m --log-opt=max-file=5`，[for details](https://docs.docker.com/config/daemon/)。

## 题外话

### 端口被占用

```shell
netstat -apt | grep <-port->
kill -9 <-PID->
```

### 镜像拉不下来的问题

使用 Docker Cloud 的 [autobuild](https://docs.docker.com/docker-cloud/builds/automated-build/) 功能 build 出需要的镜像，然后 docker pull 下来 docker tag 成需要的镜像。

kubeadm init 时加上 `--kubernetes-version=v1.11.2` 参数可以使用下面的命令拉取镜像。镜像需要在 kubeadm init 之前准备好。

所有可能用到镜像的 Dockerfile 可以在 [docker-images](https://github.com/lizebang/docker-images) 中找到。

```shell
docker pull lizebang/coredns:1.1.3
docker tag lizebang/coredns:1.1.3 k8s.gcr.io/coredns:1.1.3
docker rmi lizebang/coredns:1.1.3

docker pull lizebang/etcd-amd64:3.2.18
docker tag lizebang/etcd-amd64:3.2.18 k8s.gcr.io/etcd-amd64:3.2.18
docker rmi lizebang/etcd-amd64:3.2.18

docker pull lizebang/kube-controller-manager-amd64:v1.11.2
docker tag lizebang/kube-controller-manager-amd64:v1.11.2 k8s.gcr.io/kube-controller-manager-amd64:v1.11.2
docker rmi lizebang/kube-controller-manager-amd64:v1.11.2

docker pull lizebang/kube-proxy-amd64:v1.11.2
docker tag lizebang/kube-proxy-amd64:v1.11.2 k8s.gcr.io/kube-proxy-amd64:v1.11.2
docker rmi lizebang/kube-proxy-amd64:v1.11.2

docker pull lizebang/kube-scheduler-amd64:v1.11.2
docker tag lizebang/kube-scheduler-amd64:v1.11.2 k8s.gcr.io/kube-scheduler-amd64:v1.11.2
docker rmi lizebang/kube-scheduler-amd64:v1.11.2

docker pull lizebang/pause:3.1
docker tag lizebang/pause:3.1 k8s.gcr.io/pause:3.1
docker rmi lizebang/pause:3.1

docker pull lizebang/kube-apiserver-amd64:v1.11.2
docker tag lizebang/kube-apiserver-amd64:v1.11.2 k8s.gcr.io/kube-apiserver-amd64:v1.11.2
docker rmi lizebang/kube-apiserver-amd64:v1.11.2
```
