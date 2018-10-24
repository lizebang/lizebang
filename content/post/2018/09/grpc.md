---
title: 'gRPC in Go'
slug: grpc
date: 2018-09-28
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - go
tags:
  - go
  - library
  - grpc
  - proto3
keywords:
  - go
  - library
  - grpc
  - proto3
---

本文将向你介绍 gRPC 和 protocol buffers。代码示例：[demo](https://github.com/lizebang/learning-grpc)

<!--more-->

## 简介

在 gRPC 中，客户端可以直接调用其他机器上的提供方法，并且客户端感觉就像是本地调用一样，这使得创建分布式应用程序和服务更加轻松。

![gRPC](/images/2018/09/grpc.svg)

在服务器端，服务器实现此接口并运行 gRPC Server 来处理客户端调用。在客户端，客户端有一个 Stub（有些地方称为 Client），它提供与服务器相同的方法。

gRPC 客户端和服务器可以在各种环境中相互运行和通信，并且可以使用任何 gRPC 支持的语言编写。

## 安装

gRPC 需要 Go 版本在 1.6 以上。

然后，安装 gRPC 和 Protocol Buffers v3。

```shell
$ go get -u google.golang.org/grpc
$ brew install protobuf # on macOS, others can find from https://github.com/protocolbuffers/protobuf/releases
$ go get -u github.com/golang/protobuf/protoc-gen-go
```

## 使用 protocol buffers

接下来的学习请先阅读 [protocol buffers](https://developers.google.com/protocol-buffers/docs/overview) 再继续。

我们可以直接在 `.proto` 文件中定义服务，请看下面的示例：

```protobuf
message HelloRequest {
  string Data = 1;
}

message HelloResponse {
  string Data = 1;
}

service Hello {
  rpc Hello (HelloRequest) returns (HelloResponse) {};
}
```

然后使用 grpc 插件通过命令 `protoc --proto_path=IMPORT_PATH --go_out=plugins=grpc:DST_DIR path/to/file.proto` 生成相关的代码。

## 服务定义

gRPC 允许定义四种服务方法：

- 一元 RPC

  ```protobuf
  rpc SayHello(HelloRequest) returns (HelloResponse){
  }
  ```

- 服务器流式 RPC

  ```protobuf
  rpc LotsOfReplies(HelloRequest) returns (stream HelloResponse){
  }
  ```

- 客户端流式 RPC

  ```protobuf
  rpc LotsOfGreetings(stream HelloRequest) returns (HelloResponse) {
  }
  ```

- 双向流式 RPC

  ```protobuf
  rpc BidiHello(stream HelloRequest) returns (stream HelloResponse){
  }
  ```

流式的处理方法：

- 服务器流式 RPC

  ```go
  func (s *routeGuideServer) ListFeatures(rect *pb.Rectangle, stream pb.RouteGuide_ListFeaturesServer) error {
  	for ... {
  		// ...

  		if err := stream.Send(feature); err != nil {
  			return err
  		}

  		// ...
  	}
  	return nil
  }
  ```

- 客户端流式 RPC

  ```go
  func (s *routeGuideServer) RecordRoute(stream pb.RouteGuide_RecordRouteServer) error {
  	for {
  		point, err := stream.Recv()
  		if err == io.EOF {
  			return stream.SendAndClose(&pb.RouteSummary{...})
  		}
  		if err != nil {
  			return err
  		}

  		// ...
  	}
  }
  ```

- 双向流式 RPC

  ```go
  func (s *routeGuideServer) RouteChat(stream pb.RouteGuide_RouteChatServer) error {
  	for {
  		in, err := stream.Recv()
  		if err == io.EOF {
  			return nil
  		}
  		if err != nil {
  			return err
  		}

  		// ...

  		for ... {
  			if err := stream.Send(note); err != nil {
  				return err
  			}
  		}
  	}
  }
  ```

## 身份验证

gRPC 内置了两种身份验证机制：

- SSL/TLS
- 使用 Google 进行基于令牌的身份验证

## 代码示例

1.没有加密和认证的情况

Client:

```go
conn, _ := grpc.Dial("localhost:50051", grpc.WithInsecure())
// error handling omitted
client := pb.NewGreeterClient(conn)
// ...
```

Server:

```go
s := grpc.NewServer()
lis, _ := net.Listen("tcp", "localhost:50051")
// error handling omitted
s.Serve(lis)
```

2.带有 SSL/TLS 的情况

Client:

```go
creds, _ := credentials.NewClientTLSFromFile(certFile, "")
conn, _ := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(creds))
// error handling omitted
client := pb.NewGreeterClient(conn)
// ...
```

Server:

```go
creds, _ := credentials.NewServerTLSFromFile(certFile, keyFile)
s := grpc.NewServer(grpc.Creds(creds))
lis, _ := net.Listen("tcp", "localhost:50051")
// error handling omitted
s.Serve(lis)
```

3.使用 Google 验证

```go
pool, _ := x509.SystemCertPool()
// error handling omitted
creds := credentials.NewClientTLSFromCert(pool, "")
perRPC, _ := oauth.NewServiceAccountFromFile("service-account.json", scope)
conn, _ := grpc.Dial(
	"greeter.googleapis.com",
	grpc.WithTransportCredentials(creds),
	grpc.WithPerRPCCredentials(perRPC),
)
// error handling omitted
client := pb.NewGreeterClient(conn)
// ...
```
