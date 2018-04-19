---
title: "ssh 的使用"
slug: ssh-usage
date: 2018-03-17
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- linux
tags:
- linux
- ssh
keywords:
- linux
- ssh
---

ssh 是每一台 Linux 电脑的标配，学习它的使用是非常有必要的！

<!--more-->

1.生成一对公私钥，在 $HOME/.ssh/ 目录下 id_rsa.pub 和 id_rsa 分别是公私钥

```shell
ssh-keygen
```

2.由于防火墙的存在 ssh 连接容易断开，可以编辑 /etc/ssh/sshd_config，加入下面三个参数，最后重启 ssh 服务

```sshd_config
TCPKeepAlive yes
ClientAliveInterval 30
ClientAliveCountMax 6
```

因为 SSH 是一个 TCP 之下的协议，所以超时连接自然会断开。这里的三个参数含义分别是 TCP 保持连接不断开，每 30  秒发一次心跳包，最多连续发 6 包。

3.登陆远端服务器

```shell
ssh user@host
ssh user@host # local username 和 remote username 一致
ssh -p 9942 user@host # 默认 22 端口
```

4.远程操作

```shell
ssh user@host 'ps ax | grep [h]ttpd' # 查看远程主机是否运行进程 httpd
ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub # 将公钥传送到远程主机 host 上面
```

5.传输文件

```shell
scp localpath/localfile user@host:/remotepath # 上传文件
scp -r localpath/localdirectory user@host:/remotepath/remotedirectory # 上传文件夹
scp user@host:/remotepath/remotefile localpath/localfile # 下载文件
scp -r user@host:/remotepath/remotedirectory localpath/localdirectory # 下载文件夹
```
