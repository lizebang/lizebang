---
title: "把博客迁移到服务器上"
slug: blog-to-server
date: 2018-07-15
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- blog
tags:
- blog
- server
- nginx
keywords:
- blog
- server
- nginx
---

之前一直使用 GitHub Pages 托管博客，但是国内访问 GitHub 速度太慢了。恰逢腾讯云前段时间服务器做活动，便买了服务器把博客迁移到服务器上。

<!--more-->

我使用的是 docker + nginx + certbot。

## 准备工作

安装一些常用工具

```shell
yum -y update
yum install epel-release
```

## 安装 docker

之所以选择 docker 是因为 docker hub 上的 nginx 版本通常能保证是最新的，并且 docker 使用起来也很方便。

```shell
yum install docker
```

启动 docker 服务并设置开机启动

```shell
systemctl enable docker
systemctl start docker
```

## 拉取 nginx 并测试

直接拉取官方镜像就可以了，当然也有一些大神的镜像，它们已经内置了 letsencrypt。

```shell
docker pull nginx
```

运行一个 nginx 容器

```shell
docker run -d --rm --name nginx-test -p 0.0.0.0:80:80 nginx
```

访问 http://<-server-ip->/ 出现如下界面时可以成功访问。

![nginx-test](/images/2018/07/nginx-ok.png)

把这个容器终止，由于 `--rm` 参数的作用，容器文件会自动删除。

`注意`

1.腾讯云主机默认开放 80 端口，若使用的是其他端口例如 8080，这时我们得去[腾讯云控制台](https://console.cloud.tencent.com/cvm/index)在主机的安全组里添加一条规则

![tencent-console](/images/2018/07/tencent-console.png)

2.docker 端口映射不能使用 127.0.0.1 必须使用 0.0.0.0

## 映射网页目录

创建一个目录，让 container 中的网页文件所在的目录 `/usr/share/nginx/html` 映射到新建的目录。

```shell
cd && mkdir nginx-web && cd nginx-web
echo '<h1>Hello World</h1>' > index.html
docker run -d --rm --name nginx-test -p 0.0.0.0:80:80 --volume /root/nginx-web:/usr/share/nginx/html nginx
```

访问 http://<-server-ip->/ 出现 Hello World 时可以成功访问。

## 配置域名

把容器里面的 nginx 配置文件拷贝到本地。

```shell
docker cp nginx-test:/etc/nginx /root/nginx
```

不详细介绍 nginx 的配置参数了，网上有很多相关教程。

配置如下：

nginx/conf.d/www.lizebang.top.conf

```conf
server {
    listen 80;
    server_name www.lizebang.top;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

运行

```shell
docker run -d --rm --name nginx-test -p 0.0.0.0:80:80 --volume /root/nginx-web:/usr/share/nginx/html --volume /root/nginx:/etc/nginx nginx
```

我在阿里云买的域名，最后得去阿里云上添加一条 DNS 解析的 A 类记录，如下：

![aliyun-console](/images/2018/07/aliyun-console.png)

访问 http://www.lizebang.top/ 出现 Hello World 时可以成功访问。
