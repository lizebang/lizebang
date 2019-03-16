---
title: "Kubernetes 证书"
slug: kubernetes_concepts_cluster-administration_certificates
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

原文：https://kubernetes.io/docs/concepts/cluster-administration/certificates/

使用客户端证书身份验证时，可以通过 `easyrsa`、`openssl` 和 `cfssl` 手动生成证书。

<!--more-->

## 证书

### easyrsa

**easyrsa** 可以手动为集群生成证书。

1.下载、解压以及初始化 easyrsa3 的补丁版本。

```shell
curl -LO https://storage.googleapis.com/kubernetes-release/easy-rsa/easy-rsa.tar.gz
tar xzf easy-rsa.tar.gz
cd easy-rsa-master/easyrsa3
./easyrsa init-pki
```

2.生成一个 CA。（`--batch` 设置自动模式，`--req-cn` 默认使用 CN。）

```shell
./easyrsa --batch "--req-cn=${MASTER_IP}@`date +%s`" build-ca nopass
```

3.生成服务器证书和密钥。参数 `--subject-alt-name` 设置可能访问 API 服务器的 IP 和 DNS 域名。`MASTER_CLUSTER_IP` 通常是服务 CIDR 的第一个 IP，它被指定为 API 服务器和控制器管理组件的 `--service-cluster-ip-range` 参数。参数 `--days` 被用来设置证书过期的天数。下面的例子还假定你使用 `cluster.local` 做为默认 DNS 域名。

```shell
./easyrsa --subject-alt-name="IP:${MASTER_IP},"\
"IP:${MASTER_CLUSTER_IP},"\
"DNS:kubernetes,"\
"DNS:kubernetes.default,"\
"DNS:kubernetes.default.svc,"\
"DNS:kubernetes.default.svc.cluster,"\
"DNS:kubernetes.default.svc.cluster.local" \
--days=10000 \
build-server-full server nopass
```

4.复制 `pki/ca.crt`、`pki/issued/server.crt` 和 `pki/private/server.key` 到你的文件夹。

5.在 API 服务器启动参数中添加以下参数：

```shell
--client-ca-file=/yourdirectory/ca.crt
--tls-cert-file=/yourdirectory/server.crt
--tls-private-key-file=/yourdirectory/server.key
```

### openssl

**openssl** 可以手动为集群生成证书。

1.生成一个 2048bit 的 ca.key：

```shell
openssl genrsa -out ca.key 2048
```

2.根据 ca.key 生成 ca.crt（使用 -days 设置证书有效时间）：

```shell
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${MASTER_IP}" -days 10000 -out ca.crt
```

3.生成一个 2048bit 的 server.key：

```shell
openssl genrsa -out server.key 2048
```

4.创建用于生成证书签名请求（CSR）的配置文件。在保存此到文件（如 `csr.conf`）前，请务必将尖括号（如 `<MASTER_IP>`）标记的值替换成实际值。注意，和前面提到的一样 `MASTER_CLUSTER_IP` 是 API 服务器的服务集群 IP。下面的例子还假定使用 `cluster.local` 做为默认 DNS 域名。

```yaml
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = <country>
ST = <state>
L = <city>
O = <organization>
OU = <organization unit>
CN = <MASTER_IP>

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = <MASTER_IP>
IP.2 = <MASTER_CLUSTER_IP>

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
```

5.根据配置文件生成证书签名请求：

```shell
openssl req -new -key server.key -out server.csr -config csr.conf
```

6.使用 ca.key、ca.crt 和 server.csr 生成服务器证书：

```shell
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
-CAcreateserial -out server.crt -days 10000 \
-extensions v3_ext -extfile csr.conf
```

7.查看证书：

```shell
openssl x509  -noout -text -in ./server.crt
```

最终，添加相同的参数到 API 服务器启动参数中。

### cfssl

**cfssl** 另一个用于生成证书的工具。

1.下载、解压和准备命令行工具，如下所示。注意，你可能需要根据所使用的硬件体系结构和 cfssl 版本来调整下面的命令。

```shell
curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
chmod +x cfssl
curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
chmod +x cfssljson
curl -L https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o cfssl-certinfo
chmod +x cfssl-certinfo
```

2.创建一个用于保存文件的目录并且初始化 cfssl：

```shell
mkdir cert
cd cert
../cfssl print-defaults config > config.json
../cfssl print-defaults csr > csr.json
```

3.创建一个用于生成 CA 文件的 JSON 配置文件，例如，`ca-config.json`：

```json
{
	"signing": {
		"default": {
			"expiry": "8760h"
		},
		"profiles": {
			"kubernetes": {
				"usages": ["signing", "key encipherment", "server auth", "client auth"],
				"expiry": "8760h"
			}
		}
	}
}
```

4.创建一个用于 CA 证书签名请求（CSR）的 JSON 配置文件，例如，`ca-csr.json`。请确保用要使用的实际值替换用尖括号标记的值。

```json
{
	"CN": "kubernetes",
	"key": {
		"algo": "rsa",
		"size": 2048
	},
	"names": [
		{
			"C": "<country>",
			"ST": "<state>",
			"L": "<city>",
			"O": "<organization>",
			"OU": "<organization unit>"
		}
	]
}
```

5.生成 CA 密钥（`ca-key.pem`）和证书（`ca.pem`）：

```shell
../cfssl gencert -initca ca-csr.json | ../cfssljson -bare ca
```

6.创建一个 JSON 配置文件，用于生成 API 服务器的密钥和证书，如下所示。确保用要使用的实际值替换尖括号中的值。和前面提到的一样，`MASTER_CLUSTER_IP` 是 API 服务器的服务集群 IP。下面的例子也假设你使用 `cluster.local` 做为默认 DNS 域名。

```json
{
	"CN": "kubernetes",
	"hosts": [
		"127.0.0.1",
		"<MASTER_IP>",
		"<MASTER_CLUSTER_IP>",
		"kubernetes",
		"kubernetes.default",
		"kubernetes.default.svc",
		"kubernetes.default.svc.cluster",
		"kubernetes.default.svc.cluster.local"
	],
	"key": {
		"algo": "rsa",
		"size": 2048
	},
	"names": [
		{
			"C": "<country>",
			"ST": "<state>",
			"L": "<city>",
			"O": "<organization>",
			"OU": "<organization unit>"
		}
	]
}
```

7.生成 API 服务器所要的密钥和证书，它们默认会分别保存到文件 `server-key.pem` 和 `server.pem` 中。

```shell
../cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
--config=ca-config.json -profile=kubernetes \
server-csr.json | ../cfssljson -bare server
```

## 分发自签名 CA 证书

客户端节点可能拒绝将自签名 CA 证书识别为有效的。对于非生产部署或在公司防火墙后面运行的部署，你可以向所有客户端分发自签名 CA 证书，并刷新本地列表以寻找有效的证书。

```shell
$ sudo cp ca.crt /usr/local/share/ca-certificates/kubernetes.crt
$ sudo update-ca-certificates
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d....
done.
```

## 证书 API

你可以使用 `certificates.k8s.io` API 来提供 x509 证书以用于身份验证，参考 [文档](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster)。
