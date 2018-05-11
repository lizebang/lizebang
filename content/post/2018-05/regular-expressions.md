---
title: "Regular Expressions"
slug: regular-expressions
date: 2018-05-10
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
- skill
tags:
- skill
keywords:
- skill
- regular-expressions
---

正则表达式很好用，但是正则表达式怎样用？现在我介绍一下正则表达式的基本使用。

<!--more-->

# 匹配单个字符

## 匹配纯文本

`Ben` 是一个正则表达式。正则表达式可以包含纯文本。

例子：


正则表达式 `Ben`

| 文本 | 结果 |
| :---: | :---: |
| Hello, my name is Ben. | Hello, my name is `Ben`. |

注意：

正则表达式是区分字母大小写的。

## 匹配任意字符

`.` 字符（英文句号）可以匹配任意一个单个的字符，包括 `.` 字符本身，但不含空字符。需要表示 `.` 时，使用 `\.` 即可。

例子：

正则表达式 `.a.\.xls`


| 文本 | 结果 |
| :---: | :---: |
| apac1.xls<p>europe2.xls<p>na1.xls<p>na2.xls<p>sa1.xls<p>a1.xls | apac1.xls<p>europe2.xls<p>`na1.xls`<p>`na2.xls`<p>`sa1.xls`<p>a1.xls |

# 匹配一组字符

## 匹配多个字符中的某一个

`[]` 字符定义了一个字符集合，正则与该集合里的任意一个成员相匹配。

例子：

正则表达式 `[ns]a.\.xls`

| 文本 | 结果 |
| :---: | :---: |
| apac1.xls<p>europe2.xls<p>na1.xls<p>na2.xls<p>sa1.xls<p>ca1.xls | apac1.xls<p>europe2.xls<p>`na1.xls`<p>`na2.xls`<p>`sa1.xls`<p>ca1.xls |

## 利用字符集合区间

`[0-9]` 等价于 `[0123456789]`，`[0-9]` 就是字符集合区间。以下列举了一些常用的字符集合区间：

* `[0-9]` 匹配从 0 到 9 的所有数字。
* `[A-Z]` 匹配从 A 到 Z 的所有大写字母。
* `[a-z]` 匹配从 a 到 z 的所有小写字母。
* `[A-F]` 匹配从 A 到 F 的所有大写字母。
* `[A-z]` 匹配从 ASCII 字符 A 到 ASCII 字符 z 的任意字母。不常用，因为 Z 和 a 之间包含 [ 和 ^ 等 ASCII 字符。

例子：

1. 匹配任何一个字母（无论大小写）或数字的正则表达式：`[A-Za-z0-9]`。
2. 匹配合法 RGB 值的正则表达式：`#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]`。

## 取非匹配

`^` 元字符可以用来表明你想对一个字符集合进行取非匹配。

例子：

正则表达式 `[ns]a[^0-9]\.xls`

| 文本 | 结果 |
| :---: | :---: |
| apac1.xls<p>europe2.xls<p>sam.xls<p>na1.xls<p>na2.xls<p>sa1.xls<p>ca1.xls | apac1.xls<p>europe2.xls<p>`sam.xls`<p>na1.xls<p>na2.xls<p>sa1.xls<p>ca1.xls |

# 使用元字符

## 对特殊字符进行转义

元字符是一些在正则表达式里有着特殊含义的字符。任何一个元字符都可以通过给它加上一个反斜杠字符作为前缀的办法来转义。

例子：

正则表达式 \\

| 文本 | 结果 |
| :---: | :---: |
| \home\ben\sales | `\`home`\`ben`\`sales |

## 匹配空白字符

空白元字符

| 元字符 | 说明 |
| :---: | :---: |
| [\b] | 回退（并删除）一个字符（Backspace 键） |
| \f | 换页符 |
| \n | 换行符 |
| \r | 回车符 |
| \t | 制表符（Tab 键） |
| \v | 垂直制表符 |

`\r\n` 是 Windows 所使用的文本行结束标签。Unix 和 Linux 系统只使用一个换行符来结束一个文本行。

## 匹配特定的字符类别

字符集合（匹配多个字符中的某一个）是常见的匹配形式，而一些常用的字符集合可以用特殊元字符来替代。这些元字符匹配的是某一类别的字符（术语称之为“字符类”）。

### 匹配数字（与非数字）

数字元字符

| 元字符 | 说明 |
| :---: | :---: |
| \d | 任何一个数字字符（等价于 `[0-9]`） |
| \D | 任何一个非数字字符（等价于 `^[0-9]`） |

例子：

正则表达式 myArray\[\d\]

| 文本 | 结果 |
| :---: | :---: |
| if (myArray[0] == 0 { | if (`myArray[0]` == 0 { |

注意：

`myArray[10]` 不能被匹配到，因为 `myArray\[\d\]` 等价于 `myArray\[0-9\]` 或 `myArray\[0123456789\]`。

### 匹配字母和数字（与非字母和数字）

字母数字元字符

| 元字符 | 说明 |
| :---: | :---: |
| \w | 任何一个字母数字字符（大小写均可）或下划线字符（等价于 `[a-zA-Z0-9_]`） |
| \W | 任何一个字母数字字符或下划线字符（等价于 `[^a-zA-Z0-9_]`） |

例子：

正则表达式 \w\d\w\d\w\d

| 文本 | 结果 |
| :---: | :---: |
| 11213<p>A1C2E3<p>48075<p>48237<p>M1B4F2<p>90046<p>H1H2H2 | 11213<p>`A1C2E3`<p>48075<p>48237<p>`M1B4F2`<p>90046<p>`H1H2H2` |

### 匹配空白字符（与非空白字符）

空白字符元字符

| 元字符 | 说明 |
| :---: | :---: |
| \s | 任何一个空白字符（等价于 `[\f\n\r\t\v]`） |
| \S | 任何一个非空白字符（等价于 `^[\f\n\r\t\v]`） |

注意：

`[\b]` 退格字符是一个例外，它不在不在 `\s` 和 `\S` 的覆盖范围内。

### 匹配十六进制或八进制数值

1. 在正则表达式里，十六进制数值要用前缀 `\x` 来给出。比如，`\x0A` 对应 ASCII 字符 10（换行符），其效果等价于 `\n`。
2. 在正则表达式里，八进制数值要用前缀 `\0` 来给出，数值本身可以是两位或三位数字。比如，`\011` 对应于 ASCII 字符 9（制表符），其效果相当于 `\t`。

## 使用 POSIX 字符类

# 参考

* [ICU User Guide](http://userguide.icu-project.org/strings/regexp)
* [正则表达式必知必会（修订版）](http://www.ituring.com.cn/book/1585)
* [Sams Teach Yourself Regular Expressions in 10 Minutes
](http://forums.forta.com/books/0672325667/)
<!-- sales1.xls<p>orders3.xls<p>sales2.xls<p>sales3.xls<p>apac1.xls<p>europe2.xls<p>na1.xls<p>na2.xls<p>sa1.xls<p>ca1.xls -->
