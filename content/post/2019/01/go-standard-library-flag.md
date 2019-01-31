---
title: 'flag Go 源码解析'
slug: go-standard-library-flag
date: 2019-01-22
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - golang
tags:
  - golang
  - standard library
keywords:
  - golang
  - standard library
  - flag
---

最近看了一下 Go's flag 的源码，在这里分享一下。

<!--more-->

## 用法简介

不知道怎样使用，就会难以理解结构和函数所要做的事情。所以在开始分析源码之前，先来看一下怎样使用 flag 包。

1.定义标志

- 使用 flag.String()、Bool()、Int() 等函数
  `var ip = flag.Int("flagname"、1234、"help message for flagname")`
- 使用 flag.StringVar()、BoolVar()、IntVar() 等函数
  `flag.IntVar(&flagvar、"flagname"、1234、"help message for flagname")`
- 使用 flag.Var() 创建满足 Value 接口的自定义标志
  `flag.Var(&flagVal、"name"、"help message for flagname")`

> 注意：对于 _flag.Var()_ 不能为 _自定义标志_ 设置默认值。其默认值为 Go 声明时的默认值，如 int 的默认值为 0，bool 的默认值为 false。

2.解析标志

在定义完所有标志后，调用 _flag.Parse()_ 函数，将命令行参数解析到定义的标志上。

解析会在遇到 _第一个非标志参数_ 或 _终结符 "--"_ 时结束。

通过 _flag.Args()_ 可以获取解析完剩下的参数，通过 _flag.Arg(i)_ 可以获取剩下参数中指定位置处的参数。

3.标志语法

两个破折号等价于一个破折号。

boolean flag

```shell
-flag
-flag=x
```

non-boolean flag

```shell
-flag=x
-flag x
```

int 型标志可以接受 1234、0664、0x1234 以及负数。

bool 型标志可以接受 1、0、t、f、T、F、true、false、TRUE、FALSE、True、False

duration 型标志可以接受对 time.ParseDuration 有效对任何输入。

## 基础数据

看完上面的用法介绍，很明显可以猜到最重要的数据结构可能就是 _标志_ `Flag`、_标志集_ `FlagSet`、_自定义标志需要满足的接口_ `Value`。

1.Flag

```go
type Flag struct {
	Name     string
	Usage    string
	Value    Value
	DefValue string
}
```

_Flag_ 是一个非常简单的结构。Name 是标志名。Usage 是帮助信息。Value 用于存放标志值。DefValue 用于打印用法信息。

2.FlagSet

```go
type FlagSet struct {
	Usage         func()
	name          string
	parsed        bool
	actual        map[string]*Flag
	formal        map[string]*Flag
	args          []string
	errorHandling ErrorHandling
	output        io.Writer
}
```

_FlagSet_ 也并不复杂。Usage 会在解析发生错误时被调用。name 是标志集名称。parsed 标志是否完成标志解析。actual 是解析得到的标志集合。formal 是所设置的标志集合。args 是解析完剩下的参数。errorHandling 是解析出错后处理的方法。output 用于写入错误信息，默认为 stderr。

3.Value

```go
type Value interface {
	String() string
	Set(string) error
}

type Getter interface {
	Value
	Get() interface{}
}

type boolFlag interface {
	Value
	IsBoolFlag() bool
}
```

![flag one](/images/2019/01/flag-1.svg)

## 关键代码

1.设置标志

```go
func (f *FlagSet) Var(value Value, name string, usage string) {
	// Remember the default value as a string; it won't change.
	flag := &Flag{name, usage, value, value.String()}
	_, alreadythere := f.formal[name]
	if alreadythere {
		var msg string
		if f.name == "" {
			msg = fmt.Sprintf("flag redefined: %s", name)
		} else {
			msg = fmt.Sprintf("%s flag redefined: %s", f.name, name)
		}
		fmt.Fprintln(f.Output(), msg)
		panic(msg) // Happens only if flags are declared with identical names
	}
	if f.formal == nil {
		f.formal = make(map[string]*Flag)
	}
	f.formal[name] = flag
}
```

设置标志的过程很简单。先创建 Flag，然后尝试放到 FlagSet.formal 中。如果标志名已存在，则会发生冲突引发 panic。如果标志名不存在，则将其放入。

2.解析标志

```go
func (f *FlagSet) Parse(arguments []string) error {
	f.parsed = true
	f.args = arguments
	for {
		seen, err := f.parseOne()
		if seen {
			continue
		}
		if err == nil {
			break
		}
		switch f.errorHandling {
		case ContinueOnError:
			return err
		case ExitOnError:
			os.Exit(2)
		case PanicOnError:
			panic(err)
		}
	}
	return nil
}
```

Parse 主要通过 FlagSet.parseOne() 函数完成。当发生错误时，按所设置的 FlagSet.errorHandling 做相应的处理。

```go
func (f *FlagSet) parseOne() (bool, error) {
	if len(f.args) == 0 {
		return false, nil
	}
	s := f.args[0]
	if len(s) < 2 || s[0] != '-' {
		return false, nil
	}
	numMinuses := 1
	if s[1] == '-' {
		numMinuses++
		if len(s) == 2 { // "--" terminates the flags
			f.args = f.args[1:]
			return false, nil
		}
	}
	name := s[numMinuses:]
	if len(name) == 0 || name[0] == '-' || name[0] == '=' {
		return false, f.failf("bad flag syntax: %s", s)
	}

	// it's a flag. does it have an argument?
	f.args = f.args[1:]
	hasValue := false
	value := ""
	for i := 1; i < len(name); i++ { // equals cannot be first
		if name[i] == '=' {
			value = name[i+1:]
			hasValue = true
			name = name[0:i]
			break
		}
	}
	m := f.formal
	flag, alreadythere := m[name] // BUG
	if !alreadythere {
		if name == "help" || name == "h" { // special case for nice help message.
			f.usage()
			return false, ErrHelp
		}
		return false, f.failf("flag provided but not defined: -%s", name)
	}

	if fv, ok := flag.Value.(boolFlag); ok && fv.IsBoolFlag() { // special case: doesn't need an arg
		if hasValue {
			if err := fv.Set(value); err != nil {
				return false, f.failf("invalid boolean value %q for -%s: %v", value, name, err)
			}
		} else {
			if err := fv.Set("true"); err != nil {
				return false, f.failf("invalid boolean flag %s: %v", name, err)
			}
		}
	} else {
		// It must have a value, which might be the next argument.
		if !hasValue && len(f.args) > 0 {
			// value is the next arg
			hasValue = true
			value, f.args = f.args[0], f.args[1:]
		}
		if !hasValue {
			return false, f.failf("flag needs an argument: -%s", name)
		}
		if err := flag.Value.Set(value); err != nil {
			return false, f.failf("invalid value %q for flag -%s: %v", value, name, err)
		}
	}
	if f.actual == nil {
		f.actual = make(map[string]*Flag)
	}
	f.actual[name] = flag
	return true, nil
}
```

parseOne 的执行过程：

1.获取当前的第一个参数，当参数长度小于 2 或第一个字符不是 '-' 时，可以判定标志解析完成。否则，执行 2。

2.此时可知，当前参数长度大于等于 2 并且第一个字符是 '-'。当第二个字符不是 '-' 时，可以判定参数从第一个字符起可能是标志名，并执行 3。当第二个字符是 '-' 时，若参数长度是 2，则说明遇到终结符，若长度大于 21，则可以判定参数从第二个字符起可能是标志名，并执行 3。

3.若标志名长度为 0 或以 '-'、'=' 开头，则返回错误。否则，参数后移一个并执行 4。

4.现在需要判断标志是否有值。如果存在 '='，则存在值并且能得到 _标志名_ 和 _值_。如果不存在，则只能得到 _标志名_。下一步，执行 5。

5.如果标志名不在所设置标志集合中，则出现错误。否则，执行 6。此时对错误进行判断，如果标志名为 "help" 或 "h"，则输出用法信息并返回。否则，直接返回错误。

6.从标志集合断言得到标志，如果断言出标志类型为 bool 型，则设置成步骤 4 中得到的值或设置为 true。不为 bool 型，执行 7。

7.如果步骤 4 中得到值，则直接进行设置。如果没有得到值且参数个数大于 0，则设置值。否则，返回错误。
