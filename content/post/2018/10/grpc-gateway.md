---
title: 'gRPC Gateway'
date: 2018-10-04
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
tags:
  - go
  - grpc
  - grpc-gateway
  - proto3
keywords:
  - go
  - grpc
  - grpc-gateway
  - proto3
---

本文将向你介绍 gRPC Gateway。代码示例：[demo](https://github.com/lizebang/learning-grpc)

<!--more-->

## 简介

grpc-gateway 是一个 [protoc](http://github.com/google/protobuf) 的插件。它读取 [gRPC](http://github.com/grpc/grpc-common) 服务定义，生成反向代理服务器，将 RESTful JSON API 翻译成 gRPC。

![gRPC Gateway](/images/2018/10/grpc-gateway.png)

## 安装

源码编译安装 **Protocol Buffers v3**

```shell
mkdir tmp
cd tmp
git clone https://github.com/google/protobuf
cd protobuf
./autogen.sh
./configure
make
make check
sudo make install
```

安装所需的 protoc 插件

```shell
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
go get -u github.com/golang/protobuf/protoc-gen-go
```

## 使用

grpc-gateway 有两种使用方式：

- 注解
- 配置

### 原服务

例如我有下面这样一个 gRPC 服务。

```protobuf
syntax = "proto3";
package example;
message StringMessage {
  string value = 1;
}

service YourService {
  rpc Echo(StringMessage) returns (StringMessage) {}
}
```

### 使用注解

按照 +/- 提示修改 `.proto` 文件，给服务添加一个 option。

```protobuf
 syntax = "proto3";
 package example;
+
+import "google/api/annotations.proto";
+
 message StringMessage {
   string value = 1;
 }

 service YourService {
-  rpc Echo(StringMessage) returns (StringMessage) {}
+  rpc Echo(StringMessage) returns (StringMessage) {
+    option (google.api.http) = {
+      post: "/v1/example/echo"
+      body: "*"
+    };
+  }
 }
```

### 使用配置

保持 `.proto` 文件不变，新建一个 `your_service.yaml` 写入服务相关配置。

```yaml
type: google.api.Service
config_version: 3

http:
  rules:
    - selector: example.YourService.Echo
      post: /v1/example/echo
      body: '*'
```
