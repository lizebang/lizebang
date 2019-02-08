---
title: 'Shell Script 快速入门'
slug: shell-script-quick-start
date: 2019-02-06
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - skill
tags:
  - shell
  - script
keywords:
  - shell
  - script
---

Shell 是一个 C 语言编写的程序，是用户使用 Linux 的桥梁。Shell 既是一种程序命令，又是一种程序设计语言。Shell 脚本是一种为 Shell 编写的脚本程序。

<!--more-->

## 变量

变量类型

Shell 的两种变量：

1. _局部变量：_ 局部变量在脚本或命令中定义，仅在当前脚本或命令中有效，其他脚本或命令启动的程序无法访问。
2. _环境变量：_ 所有的程序，包括 Shell 启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。

### 基本操作

1.定义变量

定义变量时，变量名和等号之间不能有空格。变量名的命名规则与大多数编程语言相同，在此不再赘述。

```shell
var
VAR
CONST_VAR
_var
```

2.使用变量

使用一个定义过的变量，只要在变量名前面加美元符号即可，变量名外也可以加花括号。

```shell
echo $var
echo ${var}
```

3.只读变量

使用 `readonly` 命令可以将变量定义为只读变量，只读变量的值不能被改变。

```shell
readonly var
```

4.删除变量

使用 `unset` 命令可以删除变量。变量被删除后不能再次使用。`unset` 命令不能删除只读变量。

```shell
unset var
```

### 字符串

1.单引号

```shell
str='My name is '$name'.'
```

单引号字符串的限制：

1. 单引号字符串里的任何字符都会原样输出，使用的变量、转义字符都会被原样输出。
2. 单引号字串中的单引号必须成对出现，成对时可以进行字符串拼接。

2.双引号

```shell
str="My name is $name."
```

双引号字符串的优点：

1. 双引号字符串里可以有变量。
2. 双引号字符串里可以出现转义字符。

3.拼接字符串

单引号字符串、双引号字符串都可以进行拼接，而且单引号字符串和双引号字符串可以混合拼接。

```shell
# 单引号
greeting="Hello, "$your_name"!"
# 双引号
greeting='Hello, '$your_name'!'
# 混合拼接
greeting="Hello, "$your_name'!'
```

4.获取长度

```shell
echo ${#string}
```

5.提取子串

```shell
echo ${string:1:4}
```

6.查找子串

```shell
echo `expr index "$string" io`
```

### 数组

BASH 只支持一维数组，不支持多维数组，并且不限定数组的大小。数组元素的下标由 0 开始编号，而且可以不使用连续下标，下标的范围没有限制。

1.定义数组

在 Shell 中，用括号来表示数组，数组元素用 _空格_ 符号分割开。

```shell
array_name=(value0 value1 value2 value3)

array_name=(
value0
value1
value2
value3
)

array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
array_name[3]=value3
```

2.读取数组

读取数组元素值。

```shell
${array_name[index]}
```

获取数组中的所有元素。

```shell
${array_name[@]}
```

3.获取长度

获取数组长度的方法与获取字符串长度的方法相同。

```shell
${#array_name}
${#array_name[@]}
${#array_name[*]}
```

### 注释

Shell 支持 _单行注释_ 和 _多行注释_。

1.单行注释

以 `#` 开头的行就是注释，会被解释器忽略。

```shell
# annotation
# annotation
# annotation
```

2.多行注释

使用 `: <<delimiter` 可以定义一个多行注释，它遇到 `delimiter` 结束，`delimiter` 可以是任意标记。

```shell
: <<EOF
annotation
annotation
annotation
EOF
```

## 参数

在执行 Shell 脚本时，可以向脚本传递参数，脚本内获取参数的格式为：`$n`。n 是一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推。

```shell
#!/usr/bin/env bash
# -*- coding: utf-8 -*-
echo "$0"
echo "$1"
echo "$2"
echo "$3"
```

另外，还有几个特殊字符用来处理参数：

| 参数处理 | 说明                                                   |
| :------- | :----------------------------------------------------- |
| `$#`     | 传递到脚本的参数个数                                   |
| `$*`     | 以一个单字符串显示所有向脚本传递的参数                 |
| `$$`     | 脚本运行的当前进程 ID 号                               |
| `$!`     | 后台运行的最后一个进程的 ID 号                         |
| `$@`     | 与 `$*` 相同，但是使用时加引号，并在引号中返回每个参数 |
| `$-`     | 显示 Shell 使用的当前选项                              |
| `$?`     | 显示最后命令的退出状态，0 表示没有错误                 |

`$*` 与 `$@` 区别：

- 相同点：都是引用所有参数。

- 不同点： `"$*"` 等价于 "$1 $2 $3 ... $n" 只传递了一个参数，而 `"$@"` 等价于 "$1" "$2" "$3" ... "$n" 传递了 n 个参数。

```shell
#!/usr/bin/env bash
# -*- coding: utf-8 -*-
args1=("$*"...)
echo "${#args1}"

args2=("$@"...)
echo "${#args2}"
```

## 运算符

Shell 和其他编程语言一样，支持多种运算符，包括：

1. 算数运算符
2. 关系运算符
3. 布尔运算符
4. 逻辑运算符
5. 字符串运算符
6. 文件测试运算符

### 算数运算符

> 注意：请使用 `$((...))`，不要使用 `expr` 和 `$[...]`。

| 运算 | 示例                |
| :--- | :------------------ |
| 赋值 | `var1=$var2`        |
| 加法 | `$((var1 + var2))`  |
| 减法 | `$((var1 - var2))`  |
| 乘法 | `$((var1 * var2))`  |
| 除法 | `$((var1 / var2))`  |
| 取余 | `$((var1 % var2))`  |
| 相等 | `$((var1 == var1))` |
| 不等 | `$((var1 != var1))` |

### 关系运算符

| 运算符 | 说明                                | 示例                  |
| :----- | :---------------------------------- | :-------------------- |
| `-eq`  | 检测两个数是否相等，相等则返回 true | `[ $var1 -eq $var2 ]` |
| `-ne`  | 检测两个数是否不等，不等则返回 true | `[ $var1 -ne $var2 ]` |
| `-gt`  | 检测左边是否大于右边，是则返回 true | `[ $var1 -gt $var2 ]` |
| `-lt`  | 检测左边是否小于右边，是则返回 true | `[ $var1 -lt $var2 ]` |
| `-ge`  | 检测左是否大于等于右，是则返回 true | `[ $var1 -ge $var2 ]` |
| `-le`  | 检测左是否小于等于右，是则返回 true | `[ $var1 -le $var2 ]` |

### 布尔运算符

| 运算符 | 说明   | 示例               |
| :----- | :----- | :----------------- |
| `!`    | 非运算 | `[ ! bool ]`       |
| `-o`   | 或运算 | `[ bool -o bool ]` |
| `-a`   | 与运算 | `[ bool -a bool ]` |

### 逻辑运算符

| 运算符 | 说明   | 示例                   |
| :----- | :----- | :--------------------- |
| `||`   | 逻辑或 | `[ bool ] || [ bool ]` |
| `&&`   | 逻辑与 | `[ bool ] && [ bool ]` |

> _布尔运算符_ 与 _逻辑运算符_ 有什么区别呢？

> 逻辑运算符具有短路的功能。即， `||` 的左式为 true，右式不会执行。同理，`&&` 的左式为 false，右式不会执行。布尔运算符则不具有短路的功能。

### 字符串运算符

| 运算符 | 说明                                       | 示例                |
| :----- | :----------------------------------------- | :------------------ |
| `=`    | 检测两个字符串是否相等，相等则返回 true    | `[ $str1 = $str2 ]` |
| `!=`   | 检测两个字符串是否不等，不等则返回 true    | `[ $str1 != $str ]` |
| `-z`   | 检测字符串长度是否为 0，为 0 则返回 true   | `[ -z $string ]`    |
| `-n`   | 检测字符串长度是否为 0，不为 0 则返回 true | `[ -n "$string" ]`  |
| `$`    | 检测字符串是否为空，不为空则返回 true      | `[ $string ]`       |

### 文件测试运算符

文件测试运算符用于检测文件的各种属性。

| 运算符    | 说明                                          | 示例           |
| :-------- | :-------------------------------------------- | :------------- |
| `-b file` | 检测文件是否是块设备文件，是则返回 true       | `[ -b $file ]` |
| `-c file` | 检测文件是否是字符设备文件，是则返回 true     | `[ -c $file ]` |
| `-d file` | 检测文件是否是目录，是则返回 true             | `[ -d $file ]` |
| `-e file` | 检测文件（目录）是否存在，是则返回 true       | `[ -e $file ]` |
| `-f file` | 检测文件是否是 _普通文件_@1，是则返回 true    | `[ -f $file ]` |
| `-g file` | 检测文件是否设置 _SGID 位_@2，是则返回 true   | `[ -g $file ]` |
| `-k file` | 检测文件是否设置 _Sticky 位_@2，是则返回 true | `[ -k $file ]` |
| `-p file` | 检测文件是否是有名管道，是则返回 true         | `[ -p $file ]` |
| `-r file` | 检测文件是否可读，是则返回 true               | `[ -r $file ]` |
| `-s file` | 检测文件是否为 _空_@3，不为空则返回 true      | `[ -s $file ]` |
| `-u file` | 检测文件是否设置 _SUID 位_@2，是则返回 true   | `[ -u $file ]` |
| `-w file` | 检测文件是否可写，是则返回 true               | `[ -w $file ]` |
| `-x file` | 检测文件是否可执行，是则返回 true             | `[ -x $file ]` |

1. 普通文件：既不是目录，也不是设备文件。
2. SUID、SGID、Sticky：《深入理解 LINUX 内核》（第三版）的第 21 面有简单解释。详细请参见维基百科 [setuid](https://en.wikipedia.org/wiki/Setuid)、[chmod](https://en.wikipedia.org/wiki/Chmod)、[sticky bit](https://en.wikipedia.org/wiki/Sticky_bit) 等。
3. 空：文件大小为 0。

## 控制流

与大多数编程语言不同，Shell 的流程控制语句不能为空。

### if else 语句

1.if

```shell
if condition then
    command
fi
```

2.if else

```shell
if condition then
    command
else
    command
fi
```

3.if elif else

```shell
if condition then
    command
elif condition then
    command
else
    command
fi
```

### for 语句

1.for i

```shell
for ((i = 0; i < n; i++)); do
    command
done
```

2.for in

```shell
for item in item item ...; do
    command
done
```

### while 语句

```shell
while condition
do
    command
done
```

### until 语句

```shell
until condition
do
    command
done
```

### case 语句

```shell
case "$item" in
    1)
        echo "case 1"
    ;;
    2|3)
        echo "case 2 or 3"
    ;;
    *)
        echo "default"
    ;;
esac
```

### break 和 continue 命令

1. break 命令允许跳出所有循环，终止执行后面的所有循环。
2. continue 命令跳出当前循环，并进入下一次循环。

## 函数

Shell Script 中也可以定义函数。

### 函数格式

```shell
# define
function function_name() {
    command
}

# call
function_name
```

### 函数参数

调用函数时可以向其传递参数，在函数体内部，通过 `$n` 的形式来获取参数的值。

> 注意：当 n>=10 时，需要使用 `${n}` 来获取参数。

```shell
# define
function function_name() {
    echo "$1 $2 $3 ... $n"
}

# call
function_name 1 2 3 ... n
```

函数也可以使用与 _参数_ 中提到的相同的几个特殊字符用来处理参数。

### 带 return 语句

与大多数编程语言不同，Shell 中的 `return` 只允许返回 0~255 之间的数字。

```shell
function function_name() {
    command
    return num
}
```

## 输入/输出

默认情况下，命令从 _标准输入_ 读取输入，然后将输出写入到 _标准输出_。

| 命令              | 说明                                                         |
| :---------------- | :----------------------------------------------------------- |
| `command < file`  | 将输入重定向到 file                                          |
| `command > file`  | 将输出重定向到 file                                          |
| `command >> file` | 将输出以追加的方式重定向到 file                              |
| `n > file`        | 将文件描述符为 n 的文件重定向到 file                         |
| `n >> file`       | 将文件描述符为 n 的文件以追加的方式重定向到 file             |
| `n <& m`          | 将输入文件 m 和 n 合并                                       |
| `n >& m`          | 将输出文件 m 和 n 合并                                       |
| `<< delimiter`    | 将开始标记 delimiter 和结束标记 delimiter 之间的内容作为输入 |

### 输入重定向

```shell
command < file
```

### 输出重定向

```shell
command > file
```

### 输入输出重定向

```shell
command < file > file
```

### stdin、stdout、stderr 的处理

一般情况下，每个命令运行时都会打开三个文件：

- 标准输入文件：stdin 的文件描述符为 0，程序默认会从 stdin 读取数据。
- 标准输出文件：stdout 的文件描述符为 1，程序默认会向 stdout 写入数据。
- 标准错误文件：stderr 的文件描述符为 2，程序默认会向 stderr 入错误信息。

```shell
command < file > file

command 2 > file
command 2 >> file

command > file 2>&1
command >> file 2>&1
```

### Here Document

Here Document 是 Shell 中的一种特殊的重定向方式。

```shell
command << delimiter
    document
delimiter
```

将两个 delimiter 之间的内容作为输入传递给 command。

> 注意：前面的 delimiter 前后的空格会被忽略掉。结尾的 delimiter 一定要顶格写，前面不能有任何字符，后面也不能有任何字符。

### /dev/null 文件

`/dev/null` 是一个特殊的文件，写入到它的内容都会被丢弃，并且从该文件中无法读取任何内容。

## 导入文件

和其他编程语言一样，Shell 也可以包含外部脚本。

```shell
# use `.`
. filename

# use `source`
source filename
```

## Reference

- [Bash Hackers Wiki](https://wiki.bash-hackers.org/)
