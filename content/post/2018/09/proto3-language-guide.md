---
title: 'Proto3 语言指南'
slug: proto3-language-guide
date: 2018-09-24
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - tool
tags:
  - go
  - proto3
  - guide
keywords:
  - proto3
  - guide
---

本文介绍了如何使用 protocol buffer 构建 pb 数据 -- 包括 `.proto` 语法以及生成数据访问类的方法。

<!--more-->

[Demo Code](https://github.com/lizebang/learning-proto3)

## Message 类型

```protobuf
syntax = "proto3";

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
}
```

- 文件第一行指定使用 `proto3` 格式，默认 `proto2`。
- `SearchRequest` 中定义了三个字段，每个字段由 类型、名称、编号 组成。
- 在 Go 中，`message SearchRequest` 等于 `message search_request`，字段使用下划线 `_` 指明驼峰法大写字母（首字母除外）。

### 字段类型

字段类型可以是基本类型，也可以是 `enum`、`message` 这样的复合类型。

### 字段编号

在一个 `message` 中，每个字段都有唯一的编号。编号范围为 1 ~ $2^{29}$-1，即 1 ~ 536,870,911，其中 19000 ~ 19999 也不可以使用。1 ~ 15 占一个字节，16 ~ 2047 占两个字节。

### 字段规则

- singular：零或一次。
- `repeated`：重复任意次数（包括零），并且编码保留顺序。

在 proto3 中，`repeated` 对基本类型字段默认使用 `packed` 编码。`repeated` 在 Go 中表现为 slice。

### 多个 Message

多个 `message` 类型可以定义在同一文件中。

### 注解

使用 C/C++ 风格，`//` 和 `/* ... */` 语法。

### 保留字段

```protobuf
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

在 `Foo` 不可以使用 `foo` `bar` 作字段名称，不可以使用 `2, 15, 9 ~ 11` 作字段编号。

### 将生成什么

- `C++`：生成一个 `.h` 和一个 `.cc` 文件，并为文件中描述的每种消息类型提供一个类。
- `Java`：生成一个 `.java` 文件，其中包含每种消息类型的类，以及用于创建消息类实例的特殊类 `Builder` 。
- `Python`：有点不同 -- 为文件中描述的每种消息类型生成一个带有静态描述符的模块，它和 **metaclass** 一起使用，以在 runtime 上创建必要的 Python 数据访问类。
- `Go`：生成一个 `.pb.go` 文件，其中包含文件中描述的每种消息类型。
- `Ruby`：生成一个 `.rb` 文件，其中包含消息类型的 Ruby 模块。
- `Objective-C`：生成一个 `pbobjc.h` 和一个 `pbobjc.m` 文件，其中包含文件中描述的每种消息类型的类。
- `C#`：生成一个 `.cs` 文件，其中包含文件中描述的每种消息类型的类。

## 基本类型

基本类型对应规则参见 [官方表格](https://developers.google.com/protocol-buffers/docs/proto3#scalar) 和 [编码方式](https://developers.google.com/protocol-buffers/docs/encoding)。

## 默认值

- `string`：空字符串
- `bytes`：空字节切片
- bool：false
- numeric：0
- enum：第一个枚举值，0
- message：未设置该字段，依编程语言而定（Go 中为 nil）

## 枚举类型

```protobuf
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  Corpus corpus = 4;
}
```

枚举第一个值必须映射为 0，原因如下：

- 必须有一个零值，以便将其作为默认值。
- 零值必须是第一个元素，以便与 proto2 语义兼容，第一个枚举值始终是默认值。

```protobuf
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
enum EnumNotAllowingAlias {
  UNKNOWN = 0;
  STARTED = 1;
  // RUNNING = 1;  // Uncommenting this line will cause a compile error inside Google and a warning message outside.
}
```

`allow_alias` 允许使用别名，如 `STARTED` 和 `RUNNING` 都映射为 1。

枚举类型可以定义在消息内，也可以定义在消息外。`message` 通过 `MessageType.EnumType` 使用其他消息中定义的 `enum`。

在反序列化期间，将在消息中保留无法识别的枚举值，但如何表示这种值取决于编程语言。在 Go 中，未知的枚举值仅作为其基础整数表示存储。在任何情况下，如果消息被序列化，则仍然会使用消息序列化无法识别的值。

枚举也可以设置保留值。

```protobuf
enum Foo {
  reserved 2, 15, 9 to 11, 40 to max;
  reserved "FOO", "BAR";
}
```

## Message 中使用其他 Message

可以使用其他 `message` 类型作为字段类型。

```protobuf
message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}
```

### 导入定义

使用 import 导入定义。

```protobuf
import "myproject/other_protos.proto";
```

将定义移到新的位置，需要在旧位置放置一个虚拟文件，使用 `import public` 将所有导入转移到新位置。

```protobuf
// new.proto
// All definitions are moved here
```

```protobuf
// old.proto
// This is the proto that all clients are importing.
import public "new.proto";
import "other.proto";
```

```protobuf
// client.proto
import "old.proto";
// You use definitions from old.proto and new.proto, but not other.proto
```

编译时使用 `-I`/`-IPATH`/`--proto_path` 指定项目的根目录。

### 使用 proto2 Message 类型

在 `proto3` 中，可以导入并使用 [proto2](https://developers.google.com/protocol-buffers/docs/proto) 消息类型，反之亦然。注意：`proto3` 不能直接使用 `proto2` `enum` 类型，需要将 `enum` 放到消息中使用。

## 嵌套类型

```protobuf
message SearchResponse {
  message Result {
    string url = 1;
    string title = 2;
    repeated string snippets = 3;
  }
  repeated Result results = 1;
}
```

在消息中通过 `Parent.Type` 的方式使用其他消息中的 `message` 类型：

```protobuf
message SomeOtherMessage {
  SearchResponse.Result result = 1;
}
```

你可以根据需要进行多层嵌套。

```protobuf
message Outer {      // Level 0
  message MiddleAA { // Level 1
    message Inner {  // Level 2
      int64 ival = 1;
      bool  booly = 2;
    }
  }
  message MiddleBB { // Level 1
    message Inner {  // Level 2
      int32 ival = 1;
      bool  booly = 2;
    }
  }
}
```

## 更新 Message 类型

在不破坏任何现有代码的情况下更新消息需遵循以下规则：

- 请勿更改任何现有字段的编号。
- 如果添加新字段，则旧格式的消息仍然被新生成的代码解析。你应该记住这些元素的 [默认值](https://developers.google.com/protocol-buffers/docs/proto3#default)，以便新代码可以正确地与旧代码生成的消息进行交互。同样地，新代码生成的消息也可以被旧代码解析：旧二进制文件在解析式忽略新字段。有关信息请查看 [未知字段](https://developers.google.com/protocol-buffers/docs/proto3#unknowns)。
- 只要在更新的消息类型中不再使用此字段编号，就字段就可以被移除。你可能想重命名该字段，可以添加前缀 "OBSOLETE\_"，或者让字段编号 [保留](https://developers.google.com/protocol-buffers/docs/proto3#reserved)，以便 `.proto` 不会在未来意外地重复使用该字段编号。
- `int32`、`uint32`、`int64`、`uint64` 和 `bool` 都是兼容的 -- 这代表你可以任意改变字段类型而不破坏向前、向后的兼容性。如果从线路中解析出一个不符合相应类型的数字，你将获得与 C++ 中将数字转换成所定义类型相同的效果（例如，如果将 64 位数字作为 int32 读取，他将被截断为 32 位数字）。
- `sint32` 和 `sint64` 彼此兼容，但不与其他整型兼容。
- 只要 `bytes` 是有效的 UTF-8，`string` 和 `bytes` 彼此兼容。
- 如果 `bytes` 包含 `message` 编码的版本，内置的 `message` 与 `bytes` 兼容。
- `fixed32` 与 `sfixed32` 兼容，`fixed64` 与 `sfixed64` 兼容。
- `enum` 与 `int32`、`uint32`、`int64` 和 `uint64` 在有线格式方面兼容（注意，如果值不合适将会被截断）。但请注意，在反序列化消息时，客户端代码可能会以不同的方式对待它们：例如，无法识别的 proto3 `enum` 类型将保留在消息中，但是，当反序列化消息时，如何表示它依赖于语言。Int 字段总是保留它们的值。
- 将单个的值改为新类型 `oneof` 是安全且二进制兼容的。如果你确定没有没有代码一次设置多个字段，则将多个字段移到一个新的 `oneof` 可能是安全的。将多个字段移到一个已经存在的 `oneof` 中是不安全的。

## 未知字段

未知字段是解析器无法识别的字段。例如，当旧二进制文件解析具有新字段的新二进制文件发送的数据时，这些新字段将成为旧二进制文件中的未知字段。

最初，proto3 消息总是在解析时丢弃未知字段，但是在 3.5 版本中，我们重新引入了保存未知字段的行为以匹配 proto2。在 3.5 及更高的版本中，未知字段在解析期间保留并包含在序列化输出中。

## Any

`Any` 消息类型允许你在没有 `.proto` 定义的情况下将消息用于嵌入类型。`Any` 包含存储任意序列化消息的 `bytes`，以及用于作为该消息类型全局标识和解析消息类型的 URL。要使用 `Any` 类型，你需要导入 `google/protobuf/any.proto`。

```protobuf
import "google/protobuf/any.proto";

message ErrorStatus {
  string message = 1;
  repeated google.protobuf.Any details = 2;
}
```

给定消息类型默认的 URL 是 `type.googleapis.com/packagename.messagename`。

Go 中 Any 的具体使用请看 [示例](https://github.com/lizebang/learning-proto3/tree/master/any)。

## Oneof

如果你有一个包含许多字段的消息，但是它同时最多只能设置一个字段，则可以使用 `oneof` 功能强制执行此行为以节省内存。

除了所有字段在共享内存中以及同一时间最多设置一个字段外，`oneof` 字段和普通字段一样。设置 `oneof` 中的任何成员都会清除所有其他成员。如果有 `case()` 或 `WhichOneof()` 方法可以使用它们检查哪个值在 `oneof` 中，当然完全取决于你选择的编程语言。

### 使用 Oneof

要在 `.proto` 中使用 oneof，只需要在 `oneof` 名称前加上 `oneof` 关键字，你可以使用任何类型的字段，但是不能使用 `repeated` 字段。，例如 `test_oneof`：

```protobuf
message SampleMessage {
  oneof test_oneof {
    string name = 4;
    SubMessage sub_message = 9;
  }
}
```

在生成的代码中，`oneof` 字段和普通字段一样拥有 getter 和 setter 方法。如果有，你还可以使用特殊的方法检查哪个值是 `oneof` 设置的。

### Oneof 的特征

- 设置一个 `oneof` 成员将自动清除所有其他 `oneof` 成员。所以，如果你设置了多个 `oneof` 字段，只有最后你设置的字段仍然有值。
  ```protobuf
  SampleMessage message;
  message.set_name("name");
  CHECK(message.has_name());
  message.mutable_sub_message(); // Will clear name field.
  CHECK(!message.has_name());
  ```
- 如果解析器在线路上遇到同一 `oneof` 中存在多个成员，则被解析的消息只有最后一个成员可见。
- `oneof` 不能为 `repeated`。
- Reflection APIs 适用于 `oneof` 字段。
- 如果你使用的是 C++，请确保你的代码不会导致内存崩溃。下面的示例代码会导致崩溃，因为由于调用了 `set_name()` 方法 `sub_message` 已经被删除了。
  ```protobuf
  SampleMessage message;
  SubMessage* sub_message = message.mutable_sub_message();
  message.set_name("name"); // Will delete sub_message
  sub_message->set_...      // Crashes here
  ```
- 同样在 C++ 中，如果你使用 `oneofs` 来 `Swap()` 两个消息。两个消息最终将变成对方所拥有的 `oneof` 字段，在下面的示例中：`msg1` 将拥有 `sub_message` 而 `msg2` 将拥有 `name`。
  ```protobuf
  SampleMessage msg1;
  msg1.set_name("name");
  SampleMessage msg2;
  msg2.mutable_sub_message();
  msg1.swap(&msg2);
  CHECK(msg1.has_sub_message());
  CHECK(msg2.has_name());
  ```

### 向后兼容问题

在添加或移除 `oneof` 字段时需要格外小心。如果检查 `oneof` 的值返回为 `None`/`NOT_SET` 时，它可能意味着 `oneof` 还没有被设置或者它在不同版本的 `oneof` 中设置了字段。因为没有办法知道一个未知字段是否是 `oneof` 的成员，所以没有办法将他们区分开。

### 标签重用问题

- **将字段移入或移出 `oneof`：**在消息被序列化和解析的过程中，你可以会丢失一些信息（某些字段将被清除）。但是，你可以安全地将单个字段移动到新的 `oneof` 中，并且如果知道只有一个字段被设置也可以添加多个字段。
- **删除 `oneof` 字段并将其添回：**在消息被序列化和解析后，这可能清除你当前设置的 `oneof` 字段。
- **拆分或合并 `oneof`：**与移动普通字段问题类似。

## Map

如果要在数据定义中创建关联 `map`，pb 提供了一种便捷的语法：

```protobuf
map<key_type, value_type> map_field = N;
```

...其中 `key_type` 可以是任意整型或字符串（即，除浮点类型和 `bytes` 的任何 [标量](https://developers.google.com/protocol-buffers/docs/proto3#scalar) 类型）。注意，enum 不是有效的 `key_type`。`value_type` 可以是除 `map` 外的任意类型。

因此，例如，如果要创建 projects `map`，其中每条 `Project` 消息都与字符串相关联，则可以像下面这样定义它：

```protobuf
map<string, Project> projects = 3;
```

- `map` 字段不能使用 `repeated`。
- `map` 值不具有有线格式排序和映射迭代排序，因此你不能依赖于特定顺序的 `map` 条目。
- 生成 `.proto` 的文本格式时，`map` 按键排序。数字键按数字排序。
- 从线路解析或合并时，如果有重复的 `map` 键，则使用最后的键。从文本格式解析 `map` 时，如果存在重复键，则解析可能失败。
- 如果为 `map` 字段提供的键没有值，则字段序列化时的行为由编程语言决定。在 C++、Java 和 Python 中，类型的默认值被序列化，而在其他语言中没有序列化。

### 向后兼容问题

在线路上，`map` 的语法等同于下面的示例，因此不支持 `map` 的 pb 实现仍然可以处理你的数据：

```protobuf
message MapFieldEntry {
  key_type key = 1;
  value_type value = 2;
}

repeated MapFieldEntry map_field = N;
```

## Package

你可以添加一个可选的 `package` 说明符到 `.proto` 文件，以防止协议消息类型之间到名称发生冲突。

```protobuf
package foo.bar;
message Open { ... }
```

你可以在定义消息类型的字段时使用 `package` 说明符。

```protobuf
message Foo {
  ...
  foo.bar.Open open = 1;
  ...
}
```

`package` 说明符影响生成的代码的方式取决于所选择的编程语言：

- 在 **C++** 中，生成的类包含在 C++ 命名空间中。例如，Open 将在命名空间中 `foo::bar`。
- 在 **Java** 中，除非在 `.proto` 文件中明确提供 `option java_package`，否则 `package` 将用作 Java 包名。
- 在 **Python** 中，`package` 指令被忽略，因为 Python 模块是根据它们在文件系统中的位置进行组织的。
- 在 **Go** 中，除非在 `.proto` 文件中明确提供 `option go_package`，否则 `package` 将用作 Go 包名。
- 在 **Ruby** 中，生成到类被包装在嵌套的 Ruby 命名空间中，并被转换为所需要的 Ruby 大小写样式（首字母大写，如果第一个字符不是字母，则在前面附加上 `PB_`）。例如，`Open` 将在命名空间中 `Foo::Bar`。
- 在 **C#** 中，`package` 转换为 PascalCase 后被用作命名空间，除非你在 `.proto` 文件中明确提供 `option csharp_namespace`。例如，`Open` 将在命名空间中 `Foo::Bar`。

### 包和名称的解析

在 pb 中，类型名的解析与 C++ 类似：首先搜索最内层的作用域，然后是次内层的，以此类推。每个包认为内部的包是其父包。开头的 `.`（例如，`.foo.bar.Baz`）意味着从最外层的作用域开始的。

pb 编译器通过解析导入的 `.proto` 文件来解析所有类型的名称。每种语言的代码生成器都知道任何使用该语言去对应每一种类型，即使它们有不同的作用域规范。

## 定义 Service

如果你想要将消息类型和 RPC（远程过程调用）系统一起使用，你可以在 `.proto` 文件中定义一个 RPC 服务接口并 pb 编译器将生成你所选语言的服务接口代码和存根。例如，如果你想定义一个使用 `SearchRequest` 并返回 `SearchResponse` 的 RPC 服务，你可以像下面这样在 `.proto` 文件中定义它：

```protobuf
service SearchService {
  rpc Search (SearchRequest) returns (SearchResponse);
}
```

与 pb 一起使用的最简单的 RPC 系统是 [gRPC](https://grpc.io/)：一种 Google 开发的语言中立和平台中立的开源的 RPC 系统。gRPC 特别适用于 pb 并允许你使用特定的 pb 编译器插件直接由 `.proto` 文件生成相关的 RPC 代码。

如果你不想使用 gRPC，也可以将 pb 与你自己实现的 RPC 一起使用。详情请看 [Proto2 语言指南]。

还有一些正在进行的第三方项目为 pb 开发的 RPC 实现。更多请查看 [wiki](https://github.com/google/protobuf/blob/master/docs/third_party.md)

## JSON 映射

Proto3 支持 JSON 中的规范编码，使得系统间共享数据变得更加容易。下表介绍了每一种类型的编码方式。

如果 JSON 编码的数据中缺少某个值或其值为 null，则在解析为 pb 时将其解释为相应的默认值。如果字段在 pb 中有默认值，则默认情况下将在 JSON 编码数据中省略该字段以节省空间。pb 的实现可以提供用于在 JSON 编码的输出中具有具有默认值的字段的选项。

| proto3                 | JSON          | JSON example                              | Notes                                                                                                                                                                                                                                                                          |
| :--------------------- | :------------ | :---------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| message                | object        | {"fooBar": v, "g": null, ...}             | 生成JSON对象。消息字段名映射到 lowerCamelCase 并成为 JSON 对象的键。如果指定了 **json_name** 字段选项，则指定的值将用作键。解析器接受 lowerCamelCase 名称（或 **json_name** 选项指定的名称）和原始 proto 字段名。null 是所有字段类型的可接受值，并被视为相应字段类型的默认值。 |
| enum                   | string        | "FOO_BAR"                                 | enum 值的名称同指定 proto 中使用的值一样。解析器接受 enum 名和整数值。                                                                                                                                                                                                         |
| map<K,V>               | object        | {"k": v, ...}                             | 所有的键都转换为字符串。                                                                                                                                                                                                                                                       |
| repeated V             | array         | [v, ...]                                  | 接受 **null** 值并视为空列表 []。                                                                                                                                                                                                                                              |
| bool                   | true, false   | true, false                               |                                                                                                                                                                                                                                                                                |
| string                 | string        | "Hello World!"                            |                                                                                                                                                                                                                                                                                |
| bytes                  | base64 string | "YWJjMTIzIT8kKiYoKSctPUB+"                | JSON 值是使用带填充的标准 base64 编码的字符串。接受 带填充/不带填充 的 标准/URL 安全的 base64 编码。                                                                                                                                                                           |
| int32, fixed32, uint32 | number        | 1, -10, 0                                 | JSON 值是十进制数。接受数字和字符串。                                                                                                                                                                                                                                          |
| int64, fixed64, uint64 | string        | "1", "-10"                                | JSON 值是十进制字符串。接受数字和字符串。                                                                                                                                                                                                                                      |
| float, double          | number        | 1.1, -10.0, 0, "NaN", "Infinity"          | JSON 值是数字或特殊的字符串 "NaN"、"Infinity" 和 "-Infinity"。接受数字、字符串和指数表示法。                                                                                                                                                                                   |
| Any                    | object        | {"@type": "url", "f": v, ...}             | 如果 Any 包含具有特殊 JSON 映射的值，它将按如下方式转换：**{"@type": xxx, "value": yyy}**。否则，值将被转换成一个 JSON 对象，并将插入 "@type" 字段以指出实际的数据类型。                                                                                                       |
| Timestamp              | string        | "1972-01-01T10:00:20.021Z"                | 使用 RFC3339 标准，其中生成的结果始终被 Z 标准化并使用 0、3、6 或 9 位小数。接受 "Z" 以外的偏移。                                                                                                                                                                              |
| Duration               | string        | "1.000340012s", "1s"                      | 生成的结果始终包含 0、3、6 或 9 位小数，具体取决于所需的精度，结果后跟着后缀 "s"。接受任何小数位（也可以没有），只要它们符合纳秒精度并且跟有后缀 "s"。                                                                                                                         |
| Struct                 | object        | { ... }                                   | 任何 JSON 对象。请查看 **struct.proto**。                                                                                                                                                                                                                                      |
| Wrapper types          | various types | 2, "2", "foo", true, "true", null, 0, ... | Wrappers 在 JSON 中使用与包装原始类型，除了 **null** 是在数据转换和传输期间允许和保留。                                                                                                                                                                                        |
| FieldMask              | string        | "f.fooBar,h"                              | 请查看 **field_mask.proto**。                                                                                                                                                                                                                                                  |
| ListValue              | array         | [foo, bar, ...]                           |                                                                                                                                                                                                                                                                                |
| Value                  | value         |                                           | 任何 JSON 对象                                                                                                                                                                                                                                                                 |
| NullValue              | null          |                                           | JSON null                                                                                                                                                                                                                                                                      |

### JSON 选项

一个 proto3 JSON 的实现提供下列选项：

- **发出具有默认值的字段：**默认情况下，proto3 JSON 输出中省略了具有默认值的字段。实现可以提供覆盖此行为的选项，并输出具有默认值的字段。
- **忽略未知字段：**默认情况下，proto3 JSON 解析器应该拒绝未知字段，但是可以提供在解析时忽略未知字段的选项。
- **使用 proto 字段名代替 lowerCamelCase 名：**默认情况下，proto3 JSON 应将字段名转换成 lowerCamelCase 名。实现可以提供使用 proto 字段名作为 JSON 名的选项。proto3 JSON 解析器需要接受转换后 lowerCamelCase 名和 proto 字段名。
- **发出的 enum 值为整数而不是字符串：**默认情况下，在 JSON 输出中使用 `enum` 的名称。提供使用 `enum` 数值的选项。

## Option

`.proto` 文件中的个别声明可以使用许多 `options` 进行注解。`Options` 不会改变声明的整体含义，但是可能会影响它处理特定上下文方式。可用选项的完整列表定义在 `google/protobuf/descriptor.proto` 中。

一些是文件级选项，这意味着它们应该在文件头部编写，而不是在任何 `message`、`enum`、`service` 定义中。一些选项是消息级的选项，这意味着它们应该写在 `massage` 定义中。一些选项是字段级的选项，这意味着它们应该写在字段定义中。选项也可以写在枚举类型、枚举值、服务类型，以及服务方法上，但是目前没有有用的选项供它们使用。

这里有一些最常用的选项：

- `java_package`（文件选项）：用于生成的 Java 类的包。如果不在给定的 `.proto` 文件中明确 `java_package` 选项，则在默认情况下将使用 proto 包（使用 `.proto` 文件中的 "package" 关键字指定）。但是，proto 包通常不会生成友好的 Java 包，因为 proto 包不回以反向域名开头。如果不生成 Java 代码，则此选项无效。
  `option java_package = "com.example.foo";`
- `java_multiple_files`（文件选项）：使 `message`、`enum` 以及 `service` 定义在不同的类中（不同的文件），而不是定义为内部类。
  `option java_multiple_files = true;`
- `java_outer_classname`（文件选项）：生成的最外层的 Java 类的类名（文件名）。如果没有在 `.proto` 文件中明确指定 `java_outer_classname`，则将 `.proto` 文件名转换为 camel-case 来构造类名（`foo_bar.proto` 会被转换为 `FooBar.java`）。如果不生成 Java 代码，则此选项无效。
  `option java_outer_classname = "Ponycopter";`
- `optimize_for`（文件选项）：可以设置为 `SPEED`、`CODE_SIZE` 或 `LITE_RUNTIME`。这会以下列方式影响 C++ 和 Java 代码生成器（可能还有第三方生成器）：
  - `SPEED`（默认）：pb 的编译器将生成用于消息类型进行序列化、解析和执行其他常见操作的代码。此代码经过高度优化。
  - `CODE_SIZE`：pb 的编译器将生成最小的类，并依赖共享的、基于反射的代码实现序列化、解析和执行其他操作。生成的代码将比使用 `SPEED` 的小很多，但是操作会更慢。类仍然实现与 `SPEED` 模式完全相同的公有 API。此模式在包含数量非常大的 `.proto` 文件且不需要所有文件都非常迅速的应用程序中最有用。
  - `LITE_RUNTIME`：pb 的编译器将生成仅依赖于 "lite" 运行时库的类（`libprotobuf-lite` 而不是 `libprotobuf`）。精简版运行时比整个库小得多（大约小一个数量级），但是省略了描述符和反射等特定功能。这对于移动电话等受限制平台上运行的应用程序尤其有用。编译器仍然会像在 `SPEED` 模式中一样生成所有方法的快速实现。生成的类将仅实现每种语言中的 `MessageLite` 接口，它只提供完整 `Message` 接口功能的子集。
  `option optimize_for = CODE_SIZE;`
- `cc_enable_arenas`（文件选项）：为 C++ 生成的代码启用 [arena allocation](https://developers.google.com/protocol-buffers/docs/reference/arenas)。
- `objc_class_prefix`（文件选项）：设置 Objective-C 类前缀，该前缀添加到用此 `.proto` 文件生成的 Objective-C 的类和枚举前。没有默认值。你应该使用 [Apple 建议](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html#//apple_ref/doc/uid/TP40011210-CH10-SW4) 的 3-5 个大写字符之间的前缀。请注意，Apple 保留所有 2 个字母的前缀。
- `deprecated`（文件选项）：如果设置为 `true`，则表示该字段已弃用，新代码不应该使用该字段。在大多数语言中没有实际效果。在 Java 中，这个选项会生成一个 `@Deprecated` 的注解。将来，其他特定语言的代码生成器可能会在字段的访问器上生成弃用注释，这将导致在编译尝试使用该字段的代码时发出警告。如果你们没有人使用该字段，希望不要使用此字段并推荐使用 [reserved](https://developers.google.com/protocol-buffers/docs/proto3#reserved) 声名。
  `int32 old_field = 6 [deprecated=true];`

### 自定义选项

Protocol Buffers 还允许您定义和使用自己的选项。这是大多数人不需要的 **高级功能**。如果你确实需要创建自己的选项，请参阅 [Proto2 语言指南](https://developers.google.com/protocol-buffers/docs/proto.html#customoptions) 以获取详细信息。请注意，创建自定义选项使用的 [extensions](https://developers.google.com/protocol-buffers/docs/proto#extensions)，它们仅允许用于 proto3 中的自定义选项。

## 生成数据访问类

这里介绍 Go 使用的方法，其他语言参见 [官方教程](https://developers.google.com/protocol-buffers/docs/tutorials)。

安装步骤：

1.macOS 上使用 Homebrew 安装 `brew install protobuf`，其他从 [GitHub](https://github.com/protocolbuffers/protobuf/releases) 下载安装。

2.安装 [Go](https://golang.org/doc/install) 并配置 `GOPATH` `GOBIN`，将 `GOBIN` 添加到 `PATH` 中。使用 gccgo 参见 [官方文档](https://golang.org/doc/install/gccgo)。

3.使用 `go get -u github.com/golang/protobuf/protoc-gen-go` 完成插件安装。

生成访问类：

```shell
protoc --proto_path=IMPORT_PATH --go_out=DST_DIR path/to/file.proto
```
