---
title: 'AWK 快速入门'
slug: awk-quick-start
date: 2018-08-27
mathjax: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - awk
tags:
  - awk
  - script
  - shell
keywords:
  - awk
  - script
  - shell
---

awk 是一种使用方便且表现力很强的编程语言，它可以应用在多种不同的计算与数据处理任务中。

<!--more-->

## 开始

输入文件 emp.data 这个文件包含有名字，每小 时工资 (以美元为单位)，工作时长，每一行代表一个雇员的记录。你可以使用它运行本文中所有程序。

```data
Beth    4.00    0
Dan     3.75    0
Kathy   4.00    10
Mark    5.00    20
Mary    5.50    22
Susie   4.25    18
```

### AWK 程序的结构

本章的每一个 awk 程序都是由一个或多个 **模式–动作** 语句组成的序列:

```awk
pattern { action }
pattern { action }
```

awk 的基本操作是在由输入行组成的序列中，陆续地扫描每一行，搜索可以被模式 **匹配** 的行.

每一个输入行轮流被每一个模式测试。每匹配一个模式，对应的动作（可能包含多个步骤）就会执行。然后 下一行被读取，匹配重新开始。这个过程会一起持续到所有的输入被读取完毕为止。

### 运行 AWK 程序

运行一个 awk 程序有多种方式。可以输入下面这种形式的命令：

```shell
awk 'program' input files
```

也可以在命令行上省略输入文件：

```shell
awk 'program'
```

在这种情况下，awk 会将 program 应用到你接下来在终端输入的内容上面，直到键入一个文件结束标志（Unix 系统是组合键 Control-D）。

当程序的长度比较短时（只有几行），这种安排会比较方便。如果程序比较长，更好的做法是将它们放在一个单独的文件中，如果文件名是 progfile 的话，运行时只要输入：

```shell
awk -f progfile optional-list-of-files
```

选项 -f 告诉 awk 从文件中提取程序.在 progfile 出现的地方可以是任意的文件名。

### 错误

如果你在 awk 程序犯了一个错误，awk 会显示一个诊断信息。

## 简单的输出

### 打印每一行

如果一个动作没有模式，对于每一个输入行，该动作都会被执行。语句 print 会打印每一个当前输入行。

```awk
{ print }
```

因为 $0 表示一整行，所以下面程序完成同样的工作。

```awk
{ print $0 }
```

### 打印某些字段

在单个 print 语句中可以将多个条目打印到同一个输出行中。打印每一个输入行的第 1 与第 3 个字段的程序是：

```awk
{ print $1, $3 }
```

在 print 语句中由逗号分隔的表达式，在输出时默认用一个空格符分隔。由 print 打印的每一行都由一个换行符终止。这些默认行为都可以修改，我们在后面再进行讨论。

### NF 字段的数量

awk 计算当前输入行的字段数量，并将它存储在 一个内建的变量中，这个变量叫作 NF。

```awk
{ print NF, $1, $NF }
```

打印每一个输入行的字段数量，第一个字段，以及最后一个字段。

### 计算和打印

可以用字段的值进行计算，并将计算得到的结果放在输出语句中，例如：

```awk
{ print $1, $2 * $3 }
```

### 打印行号

awk 提供了另一个内建变量 NR，这个变量计算到目前为止，读取到的行的数量。由此我们可以打印出行号：

```awk
{ print NR, $0 }
```

### 将文本放入输出中

可以把单词放在字段与算术表达式之间。在 print 语句中，被双引号包围的文本会和字段，以及运算结果一起输出。

```awk
{ print "total pay for", $1, "is", $2 * $3 }
```

## 更精美的输出

### 字段排列

printf 语句具有形式

```awk
printf(format, value1, value2, ..., valuen)
```

format 是一个字符串，它包含按字面打印的文本，中间散布着格式说明符，格式说明符用于说明如何打印值。

```awk
{ printf("%-8s $%6.2f\n", $1, $2 * $3) }
```

第一个格式说明符 %-8s，将名字左对齐输出，占用 8 个字符的宽度。第二个格式说明符 %6.2f，将报酬以带有两位小数的数值格式打印出来，数字至少占用 6 个字符的宽度。

### 输出排序

最简单的办法是使用 awk 在每一条记录前加上要排序的项，然后再通过一个排序程序进行排序，在 Unix 中，命令行：

```awk
awk '{ printf("%6.2f %s\n", $2 * $3, $0) }' emp.data | sort -n
```

## 选择

### 通过比较进行选择

直接用字段比较

```awk
$2 >= 5
```

### 通过计算进行选择

先计算值，在比较

```awk
$2 * $3 > 50 { printf("$%.2f for %s\n", $2 * $3, $1) }
```

### 通过文本内容选择

除了数值选择，用户也可以选择那些包含特定单词或短语的输入行。

```awk
$1 == "Susie"
```

操作符 == 测试相等性。用户也可以搜索含有任意字母，单词或短语的文本，通过一个叫做正则表达式的模式来完成。

```awk
/Susie/
```

### 模式的组合

模式可以使用括号和逻辑运算符进行组合，逻辑运算符包括 &&、|| 和 !，分别表示 AND、OR 和 NOT。

```awk
$2 >= 4 || $3 >= 20
```

下面的条件判断与上面的等价，虽然在可读性方面差了一点。

```awk
!($2 < 4 && $3 < 20)
```

### 数据验证

真实的数据总是存在错误。检查数据是否具有合理的值，格式是否正确，这种任务通常称作数据验证，在这一方面 awk 是一款非常优秀的工具。

数据验证在本质上是否定：不打印具有期望的属性的行，而是打印可疑行。

### BEGIN 与 END

特殊的模式 BEGIN 在第一个输入文件的第一行之前被匹配，END 在最后一个输入文件的最后一行被处理之后匹配。

```awk
BEGIN { print "NAME    RATE    HOURS"; print "" }
      { print }
```

在同一行可以放置多个语句，语句之间用分号分开。注意 print "" 打印一个空行，它与一个单独的 print 并不相同，后者打印当前行。

## 用 AWK 计算

### 计数

这个程序用一个变量 emp 计算工作时长超过 15 个小时的员工人数：

```awk
$3 > 15 { emp = emp + 1 }
END { print emp, "employees worked more than 15 hours" }
```

对每一个第三个字段超过 15 的行，变量 emp 的值就加 1。

当 awk 的变量作为数值使用时，默认初始值为 0，所以我们没必要初始化 emp。

### 计算总和与平均数

利用 NR 来计算平均报酬：

```awk
{ pay = pay + $2 * $3 }
END { print NR, "employees"
      print "total pay is", pay
      print "average pay is", pay / NR
    }
```

这个程序有一个潜在的错误：一种不常见的情况是 NR 的值为 0，程序会尝试将 0 作除数，此时 awk 就会产生一条错误消息。

### 操作文本

awk 的长处之一是它可以非常方便地对字符串进行操作，就像其他大多数语言处理数值那样方便。awk 的变量除了可以存储数值，还可以存储字符串。

```awk
$2 > maxrate { maxrate = $2; maxemp = $1 }
END { print "highest hourly rate:", maxrate, "for", maxemp }
```

这个程序搜索每小时工资最高的雇员。

### 字符串拼接

可以通过旧字符串的组合来生成一个新字符串，这个操作叫作 **拼接**。

```awk
    { names = names $1 " " }
END { print names }
```

拼接方式类似：names = names + $1 + " "

### 打印最后一行

虽然在 END 动作里，NR 的值被保留了下来，但是 $0 却不会。

```awk
    { last = $0 }
END { print last }
```

上面程序可以打印文件的最后一行。

### 内建函数

awk 提供有内建变量，这些变量可以用来维护经常需要用到的量，比如字段的个数（NF），以及当前输入行的行号（NR）。同样，awk 也提供用来计算其他值的内建函数 -- 求平方根、取对数、随机数，除了这些数学函数，还有其他用来操作文本的函数，其中之一是 length，它用来计算字符串中字符的个数。

```awk
{ print $1, length($1) }
```

### 行、单词与字符的计数

使用 length，NF 与 NR 计算行，单词与字符的数量。

```awk
{ nc = nc + length($0) + 1
  nw = nw + NF
}
END { print NR, "lines,", nw, "words,", nc, "characters" }
```

每一个输入行末尾的换行符加 1，这是因为 $0 不包含换行符。

## 流程控制语句

### If-Else 语句

在计算平均数时，它用到了 if 语 句，避免用 0 作除数。

```awl
$2 > 6 { n = n + 1; pay = pay + $2 * $3 }
END { if (n > 0)
          print n, "employees, total pay is", pay,
                   "average pay is", pay/n
      else
          print "no employees are paid more than $6/hour"
    }
```

在 if-else 语句里，if 后面的条件被求值，如果条件为真，第一个 print 语句执行，否则是第二个 print 语 句被执行。

注意到，在逗号后面断行，我们可以将一个长语句延续到下一行。

### While 语句

一个 while 含有一个条件判断与一个循环体。当条件为真时，循环体执行。下面这个程序展示了一笔钱在 一个特定的利率下，其价值如何随着投资时间的增长而增加，价值计算的公式是 $value = amount(1+rate)^{years}$。

```awk
# interest1 - compute compound interest
#   input: amount rate years
#   output: compounded value at the end of each year

{   i = 1
    while (i <= $3) {
        printf("\t%.2f\n", $1 * (1 + $2) ^ i)
        i = i + 1
    }
}
```

while 后面被括号包围起来的表达式是条件判断，循环体是跟在条件判断后面的，被花括号包围起来的的两条语句。printf 格式控制字符串里的 \t 表示一个制表符，^ 是指数运算符。从井号 (#) 开始，直到行末的文本是 **注释**，注释会被 awk 忽略，但有助于其他人读懂程序。

### For 语句

大多数循环都包括初始化，测试，增值，而 for 语句将这三者压缩成一行。这里是前一个计算投资回报的程序，不过这次用 for 循环：

```awk
# interest2 - compute compound interest
#   input: amount rate years
#   output: compounded value at the end of each year

{   for (i = 1; i <= $3; i = i + 1)
        printf("\t%.2f\n", $1 * (1 + $2) ^ i)
}
```

初始化语句 i = 1 只执行一次。接下来，判断条件 i <= $3 是否成立，如果测试结果为真，循环体的 printf 语句被执行。执行完循环体之后，增值语句 i = i + 1 执行，循环的下一次迭代从条件的另一次测试开始。代码很紧凑，因为循环体只有一条语句，也就不再需要花括号。

### 数组

awk 提供了数组，用来存储一组相关的值。

下面这个程序按行逆序显示输入数据。第一个动作将输入行放入数组 line 的下一个元素中，也就是说，第一行放入 line[1]，第二行放入 line[2]，依次类推。END 动作用一个 while 循环，从数组的最 后一个元素开始打印，一直打印到第一个元素为止：

```awk
# reverse - print input in reverse order by line
    { line[NR] = $0 } # remember each input line
END { i = NR          # print lines in reverse order
      while (i > 0)
          {
              print line[i]
              i = i - 1
          }
    }
```

这是用 for 循环实现的等价的程序：

```awk
# reverse - print input in reverse order by line
    { line[NR] = $0 } # remember each input line
END { for (i = NR; i > 0; i = i - 1)
        print line[i]
    }
```

## 实用 “一行” 手册

虽然 awk 可以写出非常复杂的程序，但是许多实用的程序并不比我们目前为止看到的复杂多少。这里有 一些小程序集合，对读者应该会有一些参考价值。

1. 输入行的总行数

   ```awk
   END { print NR }
   ```

2. 打印第 10 行

   ```awk
   NR == 10
   ```

3. 打印每一个输入行的最后一个字段

   ```awk
   { print $NF }
   ```

4. 打印最后一行的最后一个字段

   ```awk
   { field = $NF }
   END { print field }
   ```

5. 打印字段数多于 4 个的输入行

   ```awk
   NF > 4
   ```

6. 打印最后一个字段值大于 4 的输入行

   ```awk
   $NF > 4
   ```

7. 打印所有输入行的字段数的总和

   ```awk
   { nf = nf + NF } END { print nf }
   ```

8. 打印包含 Beth 的行的数量

   ```awk
   /Beth/ { nlines = nlines + 1 }
   END { print nlines }
   ```

9. 打印具有最大值的第一个字段，以及包含它的行（假设 $1 总是 正的）

   ```awk
   $1 > max { max = $1; maxline = $0 }
   END { print max, maxline }
   ```

10. 打印至少包含一个字段的行

    ```awk
    NF > 0
    ```

11. 打印长度超过 80 个字符的行

    ```awk
    length($0) > 80
    ```

12. 在每一行的前面加上它的字段数

    ```awk
    { print NF, $0 }
    ```

13. 打印每一行的第 1 与第 2 个字段，但顺序相反

    ```awk
    { print $2, $1 }
    ```

14. 交换每一行的第 1 与第 2 个字段，并打印该行

    ```awk
    { temp = $1; $1 = $2; $2 = temp; print }
    ```

15. 将每一行的第一个字段用行号代替

    ```awk
    { $1 = NR; print }
    ```

16. 打印删除了第 2 个字段后的行

    ```awk
    { $2 = ""; print }
    ```

17. 将每一行的字段按逆序打印

    ```awk
    { for (i = NF; i > 0; i = i - 1) printf("%s ", $i)
         printf("\n")
    }
    ```

18. 打印每一行的所有字段值之和

    ```awk
    { sum = 0
        for (i = 1; i <= NF; i = i + 1) sum = sum + $i
        print sum
    }
    ```

19. 将所有行的所有字段值累加起来

    ```awk
        { for (i = 1; i <= NF; i = i + 1) sum = sum + $i }
    END { print sum }
    ```

20. 将每一行的每一个字段用它的绝对值替换

    ```awk
    { for (i = 1; i <= NF; i = i + 1) if ($i < 0) $i = -$i
    print
    }
    ```

## Reference

- [awkbook](https://github.com/wuzhouhui/awk)
- [The AWK Programming Language](https://book.douban.com/subject/1876898/)
