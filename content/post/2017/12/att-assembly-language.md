---
title: "AT&T 汇编 (一)"
slug: att-assembly-language
date: 2017-12-13
markup: mmark
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
markup: mmark
categories:
- CSAPP
tags:
- CSAPP
- assembly language
keywords:
- CSAPP
- assembly language
---

ATT 格式的汇编根据 AT&T 命名, AT&T 是运营贝尔实验室多年的公司.

<!--more-->

第一部分介绍了数据格式、访问信息相关的内容.

# 数据格式

Intel 用术语 `字` (word)表示 16 位数据类型. 称 32 位数为 `双字` (double words), 称 64 位数为 `四字` (quad words). 下表给出了 C 语言基本数据类型对应的 x86-64 表示. (char \* 表示指针)

$$\begin{array} {| c | c | c | c |} \hline \mathrm{C\;声明} & \mathrm{Intel\;数据类型} & \mathrm{汇编代码后缀} & \mathrm{大小(字节)} \\ \hline char & 字节 & b & 1 \\ \hline short & 字 & w & 2 \\ \hline int & 双字 & l & 4 \\ \hline long & 四字 & q & 8 \\ \hline char\* & 四字 & q & 8 \\ \hline float & 单精度 & s & 4 \\ \hline double & 双精度 & l & 8 \\ \hline \end{array}$$

注意 : 汇编代码使用后缀 `l` 来表示 4 字节整数和 8 字节双精度浮点数. 这不会产生歧义, 因为浮点数使用的是一组完全不同的指令和寄存器.

# 访问信息

最初的 8086 中有 8 个 16 位的寄存器, 即下表中的 %ax 到 %bp. 每个寄存器都有特殊的用途, 它们的名字就反映了这些不同的用途. 扩展到 IA32 构架时, 这些寄存器也扩展成 32 位寄存器, 标号从 %eax 到 %ebp. 扩展到 x86-64 后, 原来的 8 个寄存器扩展成 64 位, 标号从 %rax 到 %rbp. 除此之外, 还增加了 8 个新的寄存器, 它们的标号是按照新的命名规则制定的 : 从 %r8 到 %r15.

$$\begin{array} {| l | l | l | l | l |} \hline \;\,\mathrm{四字} & \;\;\mathrm{双字} & \quad\mathrm{字} & \;\,\mathrm{字节} & \quad\;\;\mathrm{用途} \\ \hline \%rax & \%eax & \%ax & \%al & 返回值 \\ \hline \%rbx & \%ebx & \%bx & \%bl & 被调用者保存 \\ \hline \%rcx & \%ecx & \%cx & \%cl & 第\;4\;个参数 \\ \hline \%rdx & \%edx & \%dx & \%dl & 第\;3\;个参数 \\ \hline \%rsi & \%esi & \%si & \%sil & 第\;2\;个参数 \\ \hline \%rdi & \%edi & \%di & \%dil & 第\;1\;个参数 \\ \hline \%rbp & \%ebp & \%bp & \%bpl & 被调用者保存 \\ \hline \%rsp & \%esp & \%sp & \%spl & 栈指针 \\ \hline \%r8 & \%r8d & \%r8w & \%r8b & 第\;5\;个参数 \\ \hline \%r9 & \%r9d & \%r9w & \%r9b & 第\;6\;个参数 \\ \hline \%r10 & \%r10d & \%r10w & \%r10b & 调用者保存 \\ \hline \%r11 & \%r11d & \%r11w & \%r11b & 调用者保存 \\ \hline \%r12 & \%r12d & \%r12w & \%r12b & 被调用者保存 \\ \hline \%r13 & \%r13d & \%r13w & \%r13b & 被调用者保存 \\ \hline \%r14 & \%r14d & \%r14w & \%r14b & 被调用者保存 \\ \hline \%r15 & \%r15d & \%r15w & \%r15b & 被调用者保存 \\ \hline \end{array}$$

字节级操作可以访问最低的字节, 16 位操作可以访问最低的 2 个字节, 32 位操作可以访问最低的 4 个字节, 而 64 位操作可以访问整个寄存器.

两条规则 :

1.  生成 1 字节和 2 字节数字的指令会保持剩下的字节不变.

2.  生成 4 字节数字的指令会把高位 4 个字节置为 0.

# 操作数指示符

各种不同的操作数的可能性被分为三种类型, 分别是 立即数、寄存器 和 内存引用.

$$\begin{array} {| l | l | l | l |} \hline \;\,\mathrm{类型} & \qquad\mathrm{格式} & \qquad\qquad\,\mathrm{操作数值} & \qquad\quad\mathrm{名称} \\ \hline 立即数 & \$I*{mm} & I*{mm} & 立即数寻址 \\ \hline 寄存器 & r*a & R[r_a] & 寄存器寻址 \\ \hline 存储器 & I*{mm} & M[I_{mm}] & 绝对寻址 \\ \hline 存储器 & (r*a) & M[R[r_a]] & 间接寻址 \\ \hline 存储器 & I*{mm}(r*b) & M[I*{mm}+R[r_b]] & (基址+偏移量)寻址\qquad \\ \hline 存储器 & (r*b, r_i) & M[R[r_b]+R[r_i]] & 变址寻址 \\ \hline 存储器 & I*{mm}(r*b, r_i) & M[I*{mm}+R[r_b]+R[r_i]] & 变址寻址 \\ \hline 存储器 & (, r*i, s) & M[R[r_i]\*s] & 比例变址寻址 \\ \hline 存储器 & I*{mm}(, r*i, s) & M[I*{mm}+R[r_b]+R[r_i]] & 比例变址寻址 \\ \hline 存储器 & (r*b, r_i, s) & M[R[r_b]+R[r_i]\*s] & 比例变址寻址 \\ \hline 存储器 & I*{mm}(r*b, r_i, s) & M[I*{mm}+R[r_b]+R[r_i]\*s] & 比例变址寻址 \\ \hline \end{array}$$

为了更好的理解三种操作数的表示, 请看下面例题.

`例, 假设下面的值存放在指明的内存地址和寄存器种`

$$\begin{array} {c c} \begin{array} {| c | c |} \hline \mathrm{地址} & \mathrm{值} \\ \hline 0x100 & 0xFF \\ \hline 0x104 & 0xAB \\ \hline 0x108 & 0x13 \\ \hline 0x10C & 0x11 \\ \hline \end{array} & \begin{array} {| c | c |} \hline \mathrm{寄存器} & \mathrm{值} \\ \hline \%rax & 0x100 \\ \hline \%rcx & 0x1 \\ \hline \%rdx & 0x3 \\ \hline \end{array} \end{array}$$

`填写下表, 给出所示操作数的值`

$$\begin{array} {| l | l | l |} \hline \qquad\quad\;\;\mathrm{操作数} & \;\;\;\,\mathrm{值} & \quad\,\,\mathrm{注释} \\ \hline \quad \%rax & 0x100 & 寄存器 \\ \hline \quad 0x104 & 0xAB & 绝对地址 \\ \hline \quad \$0x108 & 0x108 & 立即数 \\ \hline \quad (\%rax) & 0xFF & 地址\,0x100 \\ \hline \quad 4(\%rax) & 0xAB & 地址\,0x104 \\ \hline \quad 9(\%rax,\,\%rdx) & 0x11 & 地址\,0x10C \\ \hline \quad 206(\%rcx,\,\%rdx) \quad & 0x13 & 地址\,0x108 \\ \hline \quad 0xFC(,\,\%rcx,\,4) & 0xFF & 地址\,0x100 \\ \hline \quad (\%rax,\,\%rdx,\,4) & 0x11 & 地址\,0x10C \\ \hline \end{array}$$

# 数据传送指令

MOV 类由四条指令组成 : movb、movw、movl 和 movq. 这些指令把数据从源位置复制到目的位置, 不做任何变化.

## MOV 类

$$\begin{array} {| l | l | l |} \hline \qquad\;\;\mathrm{指令} & \;\;\,\mathrm{效果} & \;\;\;\;\;\;\;{描述} \\ \hline MOV \qquad S, D & D \leftarrow S & 传送\\ \hline movb & & 传送字节 \\ movw & & 传送字 \\ movl & & 传送双字\\ movq & & 传送四字\\ movabsq \quad I, R & R \leftarrow I & 传送绝对的四字 \\ \hline \end{array}$$

源操作数指定的值是一个立即数, 存储在寄存器中或者内存中. 目的操作数指定一个位置, 要么是一个寄存器或者, 要么是一个内存地址. x86-64 加了一条限制, 传送指令的两个操作数不能都指向内存位置. 将一个值从一个内存位置复制到另一个内存位置需要两条指令 -- 第一条指令将源值加载到寄存器中, 第二条将该寄存器值写入目的位置. 大多数情况中, MOV 指令只会更新目的操作数指定的那些寄存器字节或内存位置. 唯一的例外是 movl 指令以寄存器为目的时, 它会把该寄存器的高位 4 字节设置为 0. 造成这个例外的原因是 x86-64 采用的惯例, 即任何为寄存器生成 32 位值的指令都会把该寄存器的高位分部置位 0.

常规的 movq 指令指令以表示 32 位补码数字的立即数作为源操作数, 然后把这个值符号扩展得到 64 位的值, 放到目的位置. movabsq 指令能够以任意 64 位立即数作为源操作数, 并且只能以寄存器作为目的.

## MOVZ 类

$$\begin{array} {| l | l | l |} \hline \qquad\;\;\;\,\mathrm{指令} & \qquad\,\mathrm{效果} & \qquad\qquad\;\;\;\mathrm{描述} \\ \hline MOVZ \qquad S, D & D \leftarrow 零扩展 (S) \;\;\; & 以零扩展进行传送\\ \hline movzbw & & 将做了零扩展的字节传送到字\quad \\ movzbl & & 将做了零扩展的字节传送到双字\, \\ movzwl & & 将做了零扩展的字传送到双字\\ movzbq & & 将做了零扩展的字节传送到四字\\ movzwq & & 将做了零扩展的字传送到四字 \\ \hline \end{array}$$

MOVZ 类中的指令把目的中剩余的字节填充为 0. 每条命令名字的后两个字符都是大小指示符 : 第一个字符指定源的大小, 而第二个指明目的的大小.

注意 : 没有 movzlq 指令, 由于生成 4 字节值并以寄存器作为目的的指令会把高 4 字节置为 0, 所以可以用以寄存器为目的的 movl 指令来实现

## MOVS 类

$$\begin{array} {| l | l | l |} \hline \qquad\;\;\;\mathrm{指令} & \qquad\qquad\;\;\mathrm{效果} & \qquad\qquad\;\;\;\mathrm{描述} \\ \hline MOVS \qquad S, R & \qquad R \leftarrow 零扩展 (S) \;\;\; & 传送字符扩展的字节\\ \hline movsbw & & 将做了符号扩展的字节传送到字 \\ movsbl & & 将做了符号扩展的字节传送到双字 \\ movswl & & 将做了符号扩展的字传送到双字 \\ movsbq & & 将做了符号扩展的字节传送到四字 \\ movswq & & 将做了符号扩展的字传送到四字 \\ movslq & & 将做了符号扩展的双字传送到四字 \\ cltq & \%rax \leftarrow 符号扩展 (\%eax) \quad\; & 把\,\%eax\,符号扩展到\,\%rax \\ \hline \end{array}$$

MOVS 类中的指令通过符号扩展来填充, 把源操作的最高位进行复制. 每条命令名字的后两个字符都是大小指示符 : 第一个字符指定源的大小, 而第二个指明目的的大小.
