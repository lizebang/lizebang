---
title: "Dart 快速入门"
slug: dart-quick-start
date: 2019-02-20
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - dart
tags:
  - dart
keywords:
  - dart
---

Dart 快速入门指南，是我阅读 [A Tour of the Dart Language](https://www.dartlang.org/guides/language/language-tour) 的笔记。

<!--more-->

## A basic Dart program

下面是一段最基本的 Dart 代码：

```dart
// Define a function.
printInteger(int aNumber) {
  print('The number is $aNumber.'); // Print to console.
}

// This is where the app starts executing.
main() {
  var number = 42; // Declare and initialize a variable.
  printInteger(number); // Call a function.
}
```

## Important Concepts

学习 Dart 时需要牢记的 **概念** 和 **事实**：

- 一切能用变量声明的东西都是对象，所有对象都是一个类的实例。甚至 **数字**、**函数** 和 **null** 都是对象。所有对象都是从 [Object](https://api.dartlang.org/stable/dart-core/Object-class.html) 类继承而来。

- 虽然 Dart 是强类型的，但是可以选择使用类型注解，因为 Dart 能推断类型。当你想表明不需要任何类型时，请使用 [特殊类型 dynamic](https://www.dartlang.org/guides/language/effective-dart/design#do-annotate-with-object-instead-of-dynamic-to-indicate-any-object-is-allowed)。

- Dart 支持范型，如 List<int>（整数列表）或 List<dynamic>（任何类型对象的列表）。

- Dart 支持顶级函数（如 main()），也可以将函数绑定到 **类** 或 **对象**（分别称为 **静态方法** 和 **实例方法**）。

- 同样，Dart 支持顶级变量，也可以将变量绑定到 **类** 或 **对象**（**静态变量** 和 **实例变量**）。实例对象有时也被称为 **字段** 或 **属性**。

- 不同于 Java，Dart 没有关键字 public、protected、private。如果一个标识符以下划线（`_`）开始，则它是私有的。有关详细信息，请查看 [库和可见性](https://www.dartlang.org/guides/language/language-tour#libraries-and-visibility)。

- 标识符可以以 **字母** 或 **下划线** 开始，后面可以是这些字符加上数字的任意组合。

- Dart 具有 **表达式 expression**（具有运行时值）和 **语句 statements**（不具有运行时值）。例如，[条件表达式](https://www.dartlang.org/guides/language/language-tour#conditional-expressions) `condition ? expr1 : expr2` 的值为 expr1 或 expr2。将其与没有值的 [if-else 语句](https://www.dartlang.org/guides/language/language-tour#if-and-else) 进行比较。语句通常包含一个或多个表达式，但是表达式不能直接包含一个语句。

- Dart 工具可以报告两种问题：**警告** 和 **错误**。警告只是指示你的代码可能不起作用，但它们不会阻止你的程序执行。错误可以是编译时，也可以是运行时。编译时的错误直接阻止代码的执行，运行时的错误会导致在代码执行时引发 [异常](https://www.dartlang.org/guides/language/language-tour#exceptions)。

## Keywords

下面的单词在 Dart 中具有特殊的含义。

| [abstract](https://www.dartlang.org/guides/language/language-tour#abstract-classes) 2         | [dynamic](https://www.dartlang.org/guides/language/language-tour#important-concepts) 2            | [implements](https://www.dartlang.org/guides/language/language-tour#implicit-interfaces) 2               | [show](https://www.dartlang.org/guides/language/language-tour#importing-only-part-of-a-library) 1 |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [as](https://www.dartlang.org/guides/language/language-tour#type-test-operators) 2            | [else](https://www.dartlang.org/guides/language/language-tour#if-and-else)                        | [import](https://www.dartlang.org/guides/language/language-tour#using-libraries) 2                       | [static](https://www.dartlang.org/guides/language/language-tour#class-variables-and-methods) 2    |
| [assert](https://www.dartlang.org/guides/language/language-tour#assert)                       | [enum](https://www.dartlang.org/guides/language/language-tour#enumerated-types)                   | [in](https://www.dartlang.org/guides/language/language-tour#for-loops)                                   | [super](https://www.dartlang.org/guides/language/language-tour#extending-a-class)                 |
| [async](https://www.dartlang.org/guides/language/language-tour#asynchrony-support) 1          | [export](https://www.dartlang.org/guides/libraries/create-library-packages) 2                     | [interface](https://stackoverflow.com/questions/28595501/was-the-interface-keyword-removed-from-dart) 2  | [switch](https://www.dartlang.org/guides/language/language-tour#switch-and-case)                  |
| [await](https://www.dartlang.org/guides/language/language-tour#asynchrony-support) 3          | [extends](https://www.dartlang.org/guides/language/language-tour#extending-a-class)               | [is](https://www.dartlang.org/guides/language/language-tour#type-test-operators)                         | [sync](https://www.dartlang.org/guides/language/language-tour#generators) 1                       |
| [break](https://www.dartlang.org/guides/language/language-tour#break-and-continue)            | [external](https://stackoverflow.com/questions/24929659/what-does-external-mean-in-dart) 2        | [library](https://www.dartlang.org/guides/language/language-tour#libraries-and-visibility) 2             | [this](https://www.dartlang.org/guides/language/language-tour#constructors)                       |
| [case](https://www.dartlang.org/guides/language/language-tour#switch-and-case)                | [factory](https://www.dartlang.org/guides/language/language-tour#factory-constructors) 2          | [mixin](https://www.dartlang.org/guides/language/language-tour#adding-features-to-a-class-mixins) 2      | [throw](https://www.dartlang.org/guides/language/language-tour#throw)                             |
| [catch](https://www.dartlang.org/guides/language/language-tour#catch)                         | [false](https://www.dartlang.org/guides/language/language-tour#booleans)                          | [new](https://www.dartlang.org/guides/language/language-tour#using-constructors)                         | [true](https://www.dartlang.org/guides/language/language-tour#booleans)                           |
| [class](https://www.dartlang.org/guides/language/language-tour#instance-variables)            | [final](https://www.dartlang.org/guides/language/language-tour#final-and-const)                   | [null](https://www.dartlang.org/guides/language/language-tour#default-value)                             | [try](https://www.dartlang.org/guides/language/language-tour#catch)                               |
| [const](https://www.dartlang.org/guides/language/language-tour#final-and-const)               | [finally](https://www.dartlang.org/guides/language/language-tour#finally)                         | [on](https://www.dartlang.org/guides/language/language-tour#catch) 1                                     | [typedef](https://www.dartlang.org/guides/language/language-tour#typedefs) 2                      |
| [continue](https://www.dartlang.org/guides/language/language-tour#break-and-continue)         | [for](https://www.dartlang.org/guides/language/language-tour#for-loops)                           | [operator](https://www.dartlang.org/guides/language/language-tour#overridable-operators) 2               | [var](https://www.dartlang.org/guides/language/language-tour#variables)                           |
| [covariant](https://www.dartlang.org/guides/language/sound-problems#the-covariant-keyword) 2  | [Function](https://www.dartlang.org/guides/language/language-tour#functions) 2                    | [part](https://www.dartlang.org/guides/libraries/create-library-packages#organizing-a-library-package) 2 | [void](https://medium.com/dartlang/dart-2-legacy-of-the-void-e7afb5f44df0)                        |
| [default](https://www.dartlang.org/guides/language/language-tour#switch-and-case)             | [get](https://www.dartlang.org/guides/language/language-tour#getters-and-setters) 2               | [rethrow](https://www.dartlang.org/guides/language/language-tour#catch)                                  | [while](https://www.dartlang.org/guides/language/language-tour#while-and-do-while)                |
| [deferred](https://www.dartlang.org/guides/language/language-tour#lazily-loading-a-library) 2 | [hide](https://www.dartlang.org/guides/language/language-tour#importing-only-part-of-a-library) 1 | [return](https://www.dartlang.org/guides/language/language-tour#functions)                               | [with](https://www.dartlang.org/guides/language/language-tour#adding-features-to-a-class-mixins)  |
| [do](https://www.dartlang.org/guides/language/language-tour#while-and-do-while)               | [if](https://www.dartlang.org/guides/language/language-tour#if-and-else)                          | [set](https://www.dartlang.org/guides/language/language-tour#getters-and-setters) 2                      | [yield](https://www.dartlang.org/guides/language/language-tour#generators) 3                      |

避免使用这些单词作为标识符。但是，如有必要，标有 **数字** 的关键字在有些情况下可以是标识符：

- 带有 1 的单词是 **上下文关键字**，仅在特定位置具有意义。它们在任何地方都是有效的标识符。
- 带有 2 的单词是 **内置标识符**，为了简化将 JavaScript 代码移植到 Dart 的任务，这些关键字在大多数地方都是有效的标识符，但它们不能用作 **类名** 或 **类型名**，也不能用作 **导包前缀**。
- 带有 3 的单词是，是 Dart 1.0 发布后新加的保留字，它们用于 [异步支持](https://www.dartlang.org/guides/language/language-tour#asynchrony-support) 相关的特性。在任何带有 **async**、**async\*** 或 **sync\*** 的方法体内使用 `await` 或 `yield` 作为标识符。
- 所有其他单词都是 **保留字**，它们不能被用来作为标识符。

## Variables

变量存储的是 **引用**。指明具体类型被称为 **类型注解**。

使用 `var` 声明变量，Dart 推断出相应的类型，并且对象的类型不能被修改。

如果对象不限于单个类型，则请使用 `Object` 或 `dynamic` 类型。

```dart
var name = 'Bob';
dynamic name = 'Bob';
Object name = 'Bob';
String name = 'Bob';
```

`Object` 和 `dynamic` 的使用场景，请遵循 [设计指南](https://www.dartlang.org/guides/language/effective-dart/design#do-annotate-with-object-instead-of-dynamic-to-indicate-any-object-is-allowed)。

> 指南大意：指明允许任何对象时，使用 `Object` 而不是 `dynamic`

> 在 Dart 中有两种类型允许所有值：`Object` 和 `dynamic`。如果只是想声明允许所有对象，请使用 `Object`。例如，`log()` 方法中可以接收任何对象作为参数，并且调用其 `toString()` 方法。

> 使用 `dynamic` 传达出一种更复杂的信号。它可能意味着 Dart 的类型系统不够精细，无法表示允许的类型集。或者，值来自于交互操作或不属于静态类型系统的范围。或者，你明确想要程序中某一时刻运行时的动态。

### Default value

未初始化的变量初始化为 `null`。即使是数字类型的变量最初也是 `null`，因为数字和其他所有类型一样都是对象。

```dart
int lineCount;
assert(lineCount == null);
```

### Final and const

一个 `final` 变量只能赋值一次，一个 `const` 变量是编译时常量。顶级的 `final` 变量或类中的 `final` 变量在第一次使用的时候初始化。

```dart
final name = 'Bob'; // Without a type annotation
final String nickname = 'Bobby';
// name = 'Alice'; // Error: a final variable can only be set once.
```

> 注意：实例变量可以是 `final` 的，但不能是 `const` 的。

如果 `const` 变量在类中，请使用 `static const`。`const` 可以用字面量或其他 `const` 变量进行初始化。

`const` 不仅仅用于声明常量，还可以用于创建常量值，以及声明创建常量值的构造函数。任何变量都可以有一个常量值。

```dart
const bar = 1000000; // Unit of pressure (dynes/cm2)
const double atm = 1.01325 * bar; // Standard atmosphere
```

`const` 变量的值不能被修改。但是有 `const` 变量的非 `const` 且非 `final` 变量的值可以被修改。

```dart
var foo = const [];
final bar = const [];
const baz = []; // Equivalent to `const []`

foo = [1, 2, 3]; // Was const []

// baz = [42]; // Error: Constant variables can't be assigned a value.
```

## Built-in types

Dart 支持下面的类型：

- numbers
- strings
- booleans
- lists（也称为 arrays）
- maps
- runes（用于在 string 中表示 Unicode 字符）
- symbols

### Numbers

Dart 支持两种类型的数字：

- `int` 整数值，在 Dart VM 中，其取值为 -2^63 ~ 2^63。编译成 JavaScript 时，其取值为 -2^53 ~ 2^53。
- `double` 64 位双精度浮点数，使用 IEEE 754 标准。

```dart
var x = 1;
var hex = 0xDEADBEEF;

var y = 1.1;
var exponents = 1.42e5;

double z = 1; // Equivalent to double z = 1.0.
```

`int` 和 `double` 都是 [num](https://api.dartlang.org/stable/dart-core/num-class.html) 的子类。num 类定义了基本的运算符，+、-、\*、/、abs()、ceil()、floor() 等函数，还可以使用 [dart:math](https://api.dartlang.org/stable/dart-math/dart-math-library.html) 库。

字符串与数字可以相互转换。

```dart
// String -> int
var one = int.parse('1');
assert(one == 1);

// String -> double
var onePointOne = double.parse('1.1');
assert(onePointOne == 1.1);

// int -> String
String oneAsString = 1.toString();
assert(oneAsString == '1');

// double -> String
String piAsString = 3.14159.toStringAsFixed(2);
assert(piAsString == '3.14');
```

int 型还支持位移操作、AND、OR（<<、>>、&、|）。

```dart
assert((3 << 1) == 6); // 0011 << 1 == 0110
assert((3 >> 1) == 1); // 0011 >> 1 == 0001
assert((3 | 4) == 7); // 0011 | 0100 == 0111
```

数字字面量为编译时常量。算术表达式只要其操作数是常量，则表达式结果也是编译时常量。

```dart
const msPerSecond = 1000;
const secondsUntilRetry = 5;
const msUntilRetry = secondsUntilRetry * msPerSecond;
```

### Strings

Dart 的字符串是 UTF-16 编码的字符序列，可以使用单引号或者双引号来创建。

```dart
var s1 = 'Single quotes work well for string literals.';
var s2 = "Double quotes work just as well.";
var s3 = 'It\'s easy to escape the string delimiter.';
var s4 = "It's even easier to use the other delimiter.";
```

通过语法 `${expression}` 可以在字符串中使用表达式。

```dart
var s = 'string interpolation';

assert('Dart has $s, which is very handy.' ==
    'Dart has string interpolation, ' +
        'which is very handy.');
assert('That deserves all caps. ' +
        '${s.toUpperCase()} is very handy!' ==
    'That deserves all caps. ' +
        'STRING INTERPOLATION is very handy!');
```

`+` 运算符可以将多个字符串连接起来，把多个字符串放到一起也可以实现同样的功能。

```dart
var s1 = 'String '
    'concatenation'
    " works even over line breaks.";
assert(s1 ==
    'String concatenation works even over '
    'line breaks.');

var s2 = 'The + operator ' + 'works, as well.';
assert(s2 == 'The + operator works, as well.');
```

使用三个单引号或者双引号也可以创建多行字符串对象。

```dart
var s1 = '''
You can create
multi-line strings like this one.
''';

var s2 = """This is also a
multi-line string.""";
```

通过提供前缀 `r` 可以创建一个原始字符串。

```dart
var s = r'In a raw string, not even \n gets special treatment.';
```

字符串字面量是编译时常量。带有字符串插值的字符串，如果插值表达式引用的是编译时常量，则其结果也是编译时常量。

```dart
// These work in a const string.
const aConstNum = 0;
const aConstBool = true;
const aConstString = 'a constant string';

// These do NOT work in a const string.
var aNum = 0;
var aBool = true;
var aString = 'a string';
const aConstList = [1, 2, 3];

const validConstString = '$aConstNum $aConstBool $aConstString';
// const invalidConstString = '$aNum $aBool $aString $aConstList';
```

### Booleans

Dart 中，只有两个对象是布尔类型的：true 和 false 所创建的对象。这两个对象也是编译时常量。

```dart
// Check for an empty string.
var fullName = '';
assert(fullName.isEmpty);

// Check for zero.
var hitPoints = 0;
assert(hitPoints <= 0);

// Check for null.
var unicorn;
assert(unicorn == null);

// Check for NaN.
var iMeantToDoThis = 0 / 0;
assert(iMeantToDoThis.isNaN);
```

### Lists

Dart 中的数组就是 [List](https://api.dartlang.org/stable/dart-core/List-class.html) 对象。

```dart
var list = [1, 2, 3];
assert(list.length == 3);
assert(list[1] == 2);

list[1] = 1;
assert(list[1] == 1);
```

在 list 字面量之前添加 const 关键字，可以创建一个编译时常量。

```dart
var constantList = const [1, 2, 3];
// constantList[1] = 1; // Uncommenting this causes an error.
```

### Maps

Dart 提供 map 字面量和 [Map](https://api.dartlang.org/stable/dart-core/Map-class.html) 类型。

```dart
var gifts = {
  // Key:    Value
  'first': 'partridge',
  'second': 'turtledoves',
  'fifth': 'golden rings'
};

var nobleGases = {
  2: 'helium',
  10: 'neon',
  18: 'argon',
};
```

使用 Map 构造器创建相同的对象。

```dart
var gifts = Map();
gifts['first'] = 'partridge';
gifts['second'] = 'turtledoves';
gifts['fifth'] = 'golden rings';

var nobleGases = Map();
nobleGases[2] = 'helium';
nobleGases[10] = 'neon';
nobleGases[18] = 'argon';
```

map 基本操作

```dart
var gifts = {'first': 'partridge'};
gifts['fourth'] = 'calling birds'; // Add a key-value pair

var gifts = {'first': 'partridge'};
assert(gifts['first'] == 'partridge');

var gifts = {'first': 'partridge'};
assert(gifts['fifth'] == null);

var gifts = {'first': 'partridge'};
gifts['fourth'] = 'calling birds';
assert(gifts.length == 2);
```

和 List 一样，在 map 字面量之前添加 const 关键字，就可以创建一个编译时常量。

```dart
final constantMap = const {
  2: 'helium',
  10: 'neon',
  18: 'argon',
};

// constantMap[2] = 'Helium'; // Uncommenting this causes an error.
```

### Runes

Dart 中，runes 是字符串中的 UTF-32 码位。

Unicode 为每一个字母、数字、符号等都定义了一个唯一的数值。由于 Dart 字符串是 UTF-16 编码的序列，所以在字符串中表示 32 位 Unicode 值就需要特殊的语法。

通常使用 `\uXXXX` 和 `\u{XXXX}` 的方式来表示 Unicode 码位，XXXX 是 4 个十六进制数。

```dart
var clapping = '\u{1f44f}';
print(clapping);
print(clapping.codeUnits);
print(clapping.runes.toList());

Runes input = new Runes(
    '\u2665  \u{1f605}  \u{1f60e}  \u{1f47b}  \u{1f596}  \u{1f44d}');
print(new String.fromCharCodes(input));
```

> 注意：使用 list 操作 runes 时需要小心。[在 Dart 中如何翻转字符串](http://stackoverflow.com/questions/21521729/how-do-i-reverse-a-string-in-dart)

> `String.fromCharCodes(input.runes.toList().reversed)`

### Symbols

Dart 中使用 [Symbol](https://api.dartlang.org/stable/dart-core/Symbol-class.html) 对象声明运算符或者标识符。Symbol 对于按 name 引用的 APIs 非常有用。

若要获取标识符 symbol，请使用 symbol 字面量，`#` 后面跟着标识符。

> 注解：为了优化代码，存在 Minification 的处理。其目的是重命名 Web 程序中的标识符 name，以减少下载大小。但是 Minification 只更改标识符 name 不会更改标识符 symbol。

Symbol 字面量是编译时常量。

```dart
#radix
#bar
```

## Functions

Dart 是真正面向对象的语言，即使函数也是对象并且具有一种类型 [Function](https://api.dartlang.org/stable/dart-core/Function-class.html)。这意味着函数可以赋值给变量或者作为参数传递给其他函数。你还可以像一个函数一样调用 Dart 类的实例。有关详细信息，请查看 [Callable classes](https://www.dartlang.org/guides/language/language-tour#callable-classes)。

参数列表类型可以省略，但并不推荐。

```dart
bool isNoble(int atomicNumber) {
  return _nobleGases[atomicNumber] != null;
}

isNoble(atomicNumber) {
  return _nobleGases[atomicNumber] != null;
}
```

`=> expr` 语法是 `{ return expr; }` 的缩写。`=>` 有时也被称为 **箭头** 语法。

> 使用 `=>` 时，后面只能跟一条表达式，不能是一条语句。

```dart
bool isNoble(int atomicNumber) => _nobleGases[atomicNumber] != null;
```

函数有两种类型的参数：必需的和可选的。必需的参数在参数列表前面，可选参数在后面。

### Optional parameters

可选参数可以是基于命名的，也可以是基于位置的，但不能同时使用两种可选参数。

#### Optional named parameters

定义时，可以使用 `{param1, param2, ...}` 的方式指明命名参数。调用时，可以使用 `paramName: value` 的方式指明命名参数。

任何 Dart 代码都可以使用 [@required](https://pub.dartlang.org/documentation/meta/latest/meta/required-constant.html) 通过 `{param1, @required param2, ...}` 的方法来指明必须参数。

```dart
// Sets the [bold] and [hidden] flags ...
void enableFlags({bool bold, bool hidden}) {...}

enableFlags(bold: true, hidden: false);
```

[Required](https://pub.dartlang.org/documentation/meta/latest/meta/required-constant.html) 定义在 [meta](https://pub.dartlang.org/packages/meta) 包中。可以直接导入 `package:meta/meta.dart`，也可以导入一个导出 `meta` 的包。

```dart
const Scrollbar({Key key, @required Widget child})
```

#### Optional positional parameters

将函数参数包装在 `[]` 中，就变成可选的位置参数。

```dart
String say(String from, String msg, [String device]) {
  var result = '$from says $msg';
  if (device != null) {
    result = '$result with a $device';
  }
  return result;
}

assert(say('Bob', 'Howdy') == 'Bob says Howdy');

assert(say('Bob', 'Howdy', 'smoke signal') == 'Bob says Howdy with a smoke signal');
```

#### Default parameter values

函数中可以使用 `=` 为命名参数和位置参数定义默认参数。默认值必须是编译时常量。如果没有提供默认值，则默认值为 `null`。

```dart
// Sets the [bold] and [hidden] flags ...
void enableFlags({bool bold = false, bool hidden = false}) {...}
```

```dart
String say(String from, String msg,
    [String device = 'carrier pigeon', String mood]) {
  var result = '$from says $msg';
  if (device != null) {
    result = '$result with a $device';
  }
  if (mood != null) {
    result = '$result (in a $mood mood)';
  }
  return result;
}
```

```dart
assert(say('Bob', 'Howdy') == 'Bob says Howdy with a carrier pigeon');

void doStuff(
    {List<int> list = const [1, 2, 3],
    Map<String, String> gifts = const {
      'first': 'paper',
      'second': 'cotton',
      'third': 'leather'
    }}) {
  print('list:  $list');
  print('gifts: $gifts');
}
```

### The main() function

每个应用都必须具有一个 `main()` 函数，它是应用的入口。main() 函数返回值为 void，并具有一个可选的 List<String> 参数。

```dart
void main() {
  querySelector('#sample_text_id')
    ..text = 'Click me!'
    ..onClick.listen(reverseText);
}
```

> 注意：`..` 语法被称为 [cascade](https://www.dartlang.org/guides/language/language-tour#cascade-notation-)。使用 cascades，你可以对单个对象成员执行多个操作。

```dart
// Run the app like this: dart args.dart 1 test
void main(List<String> arguments) {
  print(arguments);

  assert(arguments.length == 2);
  assert(int.parse(arguments[0]) == 1);
  assert(arguments[1] == 'test');
}
```

可以使用 [args library](https://pub.dartlang.org/packages/args) 定义和分析命令行参数。

### Functions as first-class objects

可以将函数作为参数传递给另一个函数。

```dart
void printElement(int element) {
  print(element);
}

var list = [1, 2, 3];

// Pass printElement as a parameter.
list.forEach(printElement);
```

也可以将函数赋值给一个变量。

```dart
var loudify = (msg) => '!!! ${msg.toUpperCase()} !!!';
assert(loudify('hello') == '!!! HELLO !!!');
```

### Anonymous functions

我们将没有命名的函数称为 **匿名函数**，有时也称为 **lambda 函数** 或 **闭包函数**。你可以将一个匿名函数赋值给一个变量，以便添加到集合中或从集合中删除。

匿名函数看起来和命名函数一样 -- 零个或更多的参数，用逗号分隔，也可以是可选参数，后面跟着函数体：

```dart
([[Type] param1[, ...]]) {
  codeBlock;
};
```

```dart
var list = ['apples', 'bananas', 'oranges'];
list.forEach((item) {
  print('${list.indexOf(item)}: $item');
});
```

### Lexical scope

Dart 是静态作用域语言，这意味着变量的作用域是静态确定的。通过 “括号内能访问括号外的变量” 的规则可以查看变量是否在作用域内。

```dart
bool topLevel = true;

void main() {
  var insideMain = true;

  void myFunction() {
    var insideFunction = true;

    void nestedFunction() {
      var insideNestedFunction = true;

      assert(topLevel);
      assert(insideMain);
      assert(insideFunction);
      assert(insideNestedFunction);
    }
  }
}
```

### Lexical closures

**闭包** 是一个函数对象，即使该函数在其原始范围之外被调用，它也能访问其作用域中的变量。

```dart
// Returns a function that adds [addBy] to the
// function's argument.
Function makeAdder(num addBy) {
  return (num i) => addBy + i;
}

void main() {
  // Create a function that adds 2.
  var add2 = makeAdder(2);

  // Create a function that adds 4.
  var add4 = makeAdder(4);

  assert(add2(3) == 5);
  assert(add4(3) == 7);
}
```

### Testing functions for equality

```dart
void foo() {} // A top-level function

class A {
  static void bar() {} // A static method
  void baz() {} // An instance method
}

void main() {
  var x;

  // Comparing top-level functions.
  x = foo;
  assert(foo == x);

  // Comparing static methods.
  x = A.bar;
  assert(A.bar == x);

  // Comparing instance methods.
  var v = A(); // Instance #1 of A
  var w = A(); // Instance #2 of A
  var y = w;
  x = w.baz;

  // These closures refer to the same instance (#2),
  // so they're equal.
  assert(y.baz == x);

  // These closures refer to different instances,
  // so they're unequal.
  assert(v.baz != w.baz);
}
```

1.第一处断言

![assert one](/images/2019/02/dart-tour-functions-1.png)

2.第二处断言

![assert two](/images/2019/02/dart-tour-functions-2.png)

3.第三处断言

![assert three](/images/2019/02/dart-tour-functions-3.png)

4.第四处断言

![assert four](/images/2019/02/dart-tour-functions-4.png)

### Return values

所有函数都返回一个值。如果没有指定返回值，则把语句 `return null;` 隐式附加到函数体。

```dart
foo() {}

assert(foo() == null);
```

## Operators

下表是 Dart 中的定义的运算符。很多运算符都可以重载，详情参考 [Overridable operators](https://www.dartlang.org/guides/language/language-tour#overridable-operators)。

| 类型           | 运算符                                                                                                      |
| -------------- | ----------------------------------------------------------------------------------------------------------- |
| 一元后缀       | **expr++**、**expr--**、**()**、**[]**、**.**、**?.**                                                       |
| 一元前缀       | **-expr**、**!expr**、**~expr**、**++expr**、**--expr**                                                     |
| 乘除           | **\***、**/**、**%**、**~/**                                                                                |
| 加减           | **+**、**-**                                                                                                |
| 按位移         | **<<**、**>>**                                                                                              |
| 按位与         | **&**                                                                                                       |
| 按位异或       | **^**                                                                                                       |
| 按位或         | **\|**                                                                                                      |
| 关系和类型测试 | **>=**、**>**、**<=**、**<**、**as**、**is**、**is!**                                                       |
| 值等测试       | **==**、**!=**                                                                                              |
| 逻辑与         | **&&**                                                                                                      |
| 逻辑或         | _\|\|_                                                                                                      |
| 如果不为空     | **??**                                                                                                      |
| 三元条件式     | **expr1 ? expr2 : expr3**                                                                                   |
| 级联操作       | **..**                                                                                                      |
| 赋值           | **=**、**\*=**、**/=**、**~/=**、**%=**、**+=**、**-=**、**<<=**、**>>=**、**&=**、**^=**、**\|=**、**??=** |

当使用运算符时，就创建了 **表达式**。

```dart
a++
a + b
a = b
a == b
c ? a : b
a is T
```

运算符表按照优先级顺序排列，上面的运算符优先级要高于下面的运算符，左面的运算符优先级要高于右面的运算符。

```dart
// Parentheses improve readability.
if ((n % i == 0) && (d % i == 0)) ...

// Harder to read, but equivalent.
if (n % i == 0 && d % i == 0) ...
```

> 警告：对于有两个操作数的运算符，左边的操作数决定了运算符的功能。

### Arithmetic operators

Dart 支持通常的算数运算符。

| 运算符    | 含义               |
| --------- | ------------------ |
| **+**     | 加号               |
| **–**     | 减号               |
| **-expr** | 负号               |
| **\***    | 乘号               |
| **/**     | 除号               |
| **~/**    | 除号，返回整数结果 |
| **%**     | 取模               |

```dart
assert(2 + 3 == 5);
assert(2 - 3 == -1);
assert(2 * 3 == 6);
assert(5 / 2 == 2.5); // Result is a double
assert(5 ~/ 2 == 2); // Result is an int
assert(5 % 2 == 1); // Remainder

assert('5/2 = ${5 ~/ 2} r ${5 % 2}' == '5/2 = 2 r 1');
```

Dart 还支持前缀和后缀的递增、递减操作。

| 运算符    | 含义                                    |
| --------- | --------------------------------------- |
| **++var** | **var = var + 1**（表达式值为 var + 1） |
| **var++** | **var = var + 1**（表达式值为 var）     |
| **--var** | **var = var - 1**（表达式值为 var - 1） |
| **var--** | **var = var - 1**（表达式值为 var）     |

```dart
var a, b;

a = 0;
b = ++a; // Increment a before b gets its value.
assert(a == b); // 1 == 1

a = 0;
b = a++; // Increment a AFTER b gets its value.
assert(a != b); // 1 != 0

a = 0;
b = --a; // Decrement a before b gets its value.
assert(a == b); // -1 == -1

a = 0;
b = a--; // Decrement a AFTER b gets its value.
assert(a != b); // -1 != 0
```

### Equality and relational operators

| 运算符 | 含义     |
| ------ | -------- |
| **==** | 等于     |
| **!=** | 不等     |
| **>**  | 大于     |
| **<**  | 小于     |
| **>=** | 大于等于 |
| **<=** | 小于等于 |

测试两个对象是否表示相同的内容，使用 `==` 运算符。（在极少数情况下，需要使用 [identical()](https://api.dartlang.org/stable/dart-core/identical.html) 函数来判断两对象是否完全相同）`==` 的工作原理如下：

1.x 或 y 为 null 时，两个都为 null 返回 true，只有一个为 false。

2.返回 x.==(y) 的结果。（你可以从写运算符方法，请查看 [Overridable operators](https://www.dartlang.org/guides/language/language-tour#overridable-operators)）

```dart
assert(2 == 2);
assert(2 != 3);
assert(3 > 2);
assert(2 < 3);
assert(3 >= 3);
assert(2 <= 3);
```

### Type test operators

`as`、`is`、`is!` 运算符在运行时判定对象。

| 运算符  | 含义                                                                                                              |
| ------- | ----------------------------------------------------------------------------------------------------------------- |
| **as**  | 类型转换（也用于 [导包前缀](https://www.dartlang.org/guides/language/language-tour#specifying-a-library-prefix)） |
| **is**  | 如果对象是指定的类型返回 true                                                                                     |
| **is!** | 如果对象是指定的类型返回 false                                                                                    |

如果 obj 实现了 T 的接口，则 `obj is T` 返回 true。`obj is Object` 永远是 true。

使用 `as` 运算符将对象强制转换为指定类型。一般情况下，你可以把 as 当做用 is 判定类型后调用所判定对象的函数的缩写形式。例如：

```dart
if (emp is Person) {
  // Type check
  emp.firstName = 'Bob';
}

(emp as Person).firstName = 'Bob';
```

> 注意：如果 emp 为 null 或者不是 Person 类型时，is 大括号中的代码不会执行，而 as 则会抛出一个异常。

### Assignment operators

`=` 运算符用于赋值操作。`??=` 运算符用于在对象为 null 时进行赋值操作。

```dart
// Assign value to a
a = value;
// Assign value to b if b is null; otherwise, b stays the same
b ??= value;
```

| **=**  | **–=**  | **/=**  | **%=**  | **>>=** | **^=**  |
| ------ | ------- | ------- | ------- | ------- | ------- |
| **+=** | **\*=** | **~/=** | **<<=** | **&=**  | **\|=** |

`a op= b` 等价于 `a = a op b`

```dart
var a = 2; // Assign using =
a *= 3; // Assign and multiply: a = a * 3
assert(a == 6);
```

### Logical operators

逻辑运算符用于操作布尔值。

| 运算符    | 含义                                         |
| --------- | -------------------------------------------- |
| **!expr** | 取反操作（true 变成 false，false 变成 true） |
| **\|\|**  | 逻辑或                                       |
| **&&**    | 逻辑与                                       |

```dart
if (!done && (col == 0 || col == 3)) {
  // ...Do something...
}
```

### Bitwise and shift operators

按位和移位运算符可以单独操作数字的某一位。

| 运算符    | 含义     |
| --------- | -------- |
| **&**     | 按位与   |
| **\|**    | 按位或   |
| **^**     | 按位异或 |
| **~expr** | 按位取反 |
| **<<**    | 按位左移 |
| **>>**    | 按位右移 |

```dart
final value = 0x22;
final bitmask = 0x0f;

assert((value & bitmask) == 0x02); // AND
assert((value & ~bitmask) == 0x20); // AND NOT
assert((value | bitmask) == 0x2f); // OR
assert((value ^ bitmask) == 0x2d); // XOR
assert((value << 4) == 0x220); // Shift left
assert((value >> 4) == 0x02); // Shift right
```

### Conditional expressions

Dart 中有两个运算符可以代替 `if-else` 语句。

- `condition ? expr1 : expr2`
  如果 condition 为 true，则返回 expr1，否则返回 expr2。
- `expr1 ?? expr2`
  如果 expr1 不为 null，则返回 expr1，否则返回 expr2。

```dart
var visibility = isPublic ? 'public' : 'private';

String playerName(String name) => name ?? 'Guest';

// Slightly longer version uses ?: operator.
String playerName(String name) => name != null ? name : 'Guest';
```

```dart
// Very long version uses if-else statement.
String playerName(String name) {
  if (name != null) {
    return name;
  } else {
    return 'Guest';
  }
}
```

### Cascade notation (..)

级联运算符 `..` 可以在同一对象进行一系列操作，可以连续调用多个函数，也可以连续访问多个字段。

```dart
querySelector('#confirm') // Get an object.
  ..text = 'Confirm' // Use its members.
  ..classes.add('important')
  ..onClick.listen((e) => window.alert('Confirmed!'));

var button = querySelector('#confirm');
button.text = 'Confirm';
button.classes.add('important');
button.onClick.listen((e) => window.alert('Confirmed!'));

final addressBook = (AddressBookBuilder()
      ..name = 'jenny'
      ..email = 'jenny@example.com'
      ..phone = (PhoneNumberBuilder()
            ..number = '415-555-0100'
            ..label = 'home')
          .build())
    .build();
```

函数返回 void 时，不能使用级联运算符。

```dart
var sb = StringBuffer();
sb.write('foo')
  ..write('bar'); // Error: method 'write' isn't defined for 'void'.
```

> 严格来说，“两个点” 的级联语法不是一个运算符，只是一个 Dart 的特殊语法。

### Other operators

| 运算符 | 名称             | 含义                                                                   |
| ------ | ---------------- | ---------------------------------------------------------------------- |
| **()** | 函数调用         | 表示函数调用                                                           |
| **[]** | 列表访问         | 访问 list 指定索引处的值                                               |
| **.**  | 成员访问         | 访问表达式的属性                                                       |
| **?.** | 有条件的成员访问 | 类似 `.`，但左边的操作数可以为 null。左边的操作数为 null 时，返回 null |

更多有关 `.`、`?.`、`..` 的信息，请查看 [Classes](https://www.dartlang.org/guides/language/language-tour#classes)。

## Control flow statements

Dart 中的控制流语句有：

- `if` 和 `else`
- `for` 循环
- `while` 和 `do-while` 循环
- `break` 和 `continue`
- `switch` 和 `case`
- `assert`

你还可以使用 `try-catch` 和 `throw` 来影响控制流，请查看 [Exceptions](https://www.dartlang.org/guides/language/language-tour#exceptions)。

### If and else

Dart 支持 if 语句以及可选的 else 语句。你也可以使用 [conditional expressions](https://www.dartlang.org/guides/language/language-tour#conditional-expressions)。

与 JavaScript 不同，条件必须是布尔类型的值。

```dart
if (isRaining()) {
  you.bringRainCoat();
} else if (isSnowing()) {
  you.wearJacket();
} else {
  car.putTopDown();
}
```

### For loops

可以使用标准的 for 循环进行迭代。

```dart
var message = StringBuffer('Dart is fun');
for (var i = 0; i < 5; i++) {
  message.write('!');
}
```

Dart 的 for 循环内部的闭包函数能捕获索引的值，这避免了 JavaScript 中常见的陷阱。

```dart
var callbacks = [];
for (var i = 0; i < 2; i++) {
  callbacks.add(() => print(i));
}
callbacks.forEach((c) => c());

candidates.forEach((candidate) => candidate.interview());
```

如果要迭代的对象是可迭代的，则可以使用 [forEach](https://api.dartlang.org/stable/dart-core/Iterable/forEach.html) 方法。如果不需要知道当前的迭代计数器，使用 `forEach()` 是很好的选择。

类似 List 和 Set 这样的可迭代类也支持 `for-in` 形式的 [遍历](https://www.dartlang.org/guides/libraries/library-tour#iteration)。

```dart
var collection = [0, 1, 2];
for (var x in collection) {
  print(x); // 0 1 2
}
```

### While and do-while

`while` 在循环体之前判断条件。

```dart
while (!isDone()) {
  doSomething();
}
```

`do-while` 在循环体之前判断条件。

```dart
do {
  printLine();
} while (!atEndOfPage());
```

### Break and continue

使用 `break` 停止循环。

```dart
while (true) {
  if (shutDownRequested()) break;
  processIncomingRequests();
}
```

使用 `continue` 跳到下一个循环迭代。

```dart
for (int i = 0; i < candidates.length; i++) {
  var candidate = candidates[i];
  if (candidate.yearsExperience < 5) {
    continue;
  }
  candidate.interview();
}
```

```dart
candidates
    .where((c) => c.yearsExperience >= 5)
    .forEach((c) => c.interview());
```

### Switch and case

Dart 中的 switch 语句使用 `==` 比较 integer、string 或编译时常量。比较对象必须是同一个类的实例（并且不是其子类），并且该类不得重写 == 运算符。[Enumerated types](https://www.dartlang.org/guides/language/language-tour#enumerated-types) 非常适合在 switch 语句中使用。

每个非空的 case 语句都必须有一个 break 语句。另外还可以通过 continue、throw 或 return 语句结束非空 case 语句。

当没有匹配到 case 语句时，将执行 default 语句。

```dart
var command = 'OPEN';
switch (command) {
  case 'CLOSED':
    executeClosed();
    break;
  case 'PENDING':
    executePending();
    break;
  case 'APPROVED':
    executeApproved();
    break;
  case 'DENIED':
    executeDenied();
    break;
  case 'OPEN':
    executeOpen();
    break;
  default:
    executeUnknown();
}
```

非空的 case 语句中省略 break 语句，编译时会出现一个错误。

```dart
var command = 'OPEN';
switch (command) {
  case 'OPEN':
    executeOpen();
    // ERROR: Missing break

  case 'CLOSED':
    executeClosed();
    break;
}
```

空的 case 语句中可以省略 break 语句，然后将执行下一个 case 语句。

```dart
var command = 'CLOSED';
switch (command) {
  case 'CLOSED': // Empty case falls through.
  case 'NOW_CLOSED':
    // Runs for both CLOSED and NOW_CLOSED.
    executeNowClosed();
    break;
}
```

如果想要向下执行，则可以使用 continue 和标签。

```dart
var command = 'CLOSED';
switch (command) {
  case 'CLOSED':
    executeClosed();
    continue nowClosed;
  // Continues executing at the nowClosed label.

  nowClosed:
  case 'NOW_CLOSED':
    // Runs for both CLOSED and NOW_CLOSED.
    executeNowClosed();
    break;
}
```

每个 case 语句可以有局部变量，这些变量仅在语句的范围内可见。

### Assert

如果判断结果为 false，则使用 `assert` 语句终止正常的执行。

```dart
// Make sure the variable has a non-null value.
assert(text != null);

// Make sure the value is less than 100.
assert(number < 100);

// Make sure this is an https URL.
assert(urlString.startsWith('https'));
```

> 注解：assert 语句只会在开发环境下起作用，不会在生产环境下起作用。像 [dart](https://www.dartlang.org/server/tools/dart-vm) 和 [dart2js](https://webdev.dartlang.org/tools/dart2js) 之类的工具，可以通过命令行标志 `--enable-asserts` 支持 assert。

若要将消息附加到断言结果中，请添加一个字符串作为第二个参数。

```dart
assert(urlString.startsWith('https'), 'URL ($urlString) should start with "https".');
```

assert 的第一个参数可以是任何解析为布尔值的表达式。如果解析式的值为 true，则断言成功并继续执行。如果为 false，则断言失败并抛出一个异常 [AssertionError](https://api.dartlang.org/stable/dart-core/AssertionError-class.html)。

## Exceptions

代码中可以抛出和捕获异常。异常是错误，它指明某些不期望发生的情况。如果异常未被捕获，则引发异常的隔离区会被挂起，且隔离区和它的程序通常会被终止。

与 Java 不同的是，所有的 Dart 异常都是非检查的异常。方法不声明可能引发的异常，并且不需要捕获所有的异常。

Dart 提供了 [Exception](https://api.dartlang.org/stable/dart-core/Exception-class.html) 和 [Error](https://api.dartlang.org/stable/dart-core/Error-class.html) 类型，以及许多预定义的子类型。当然也可以定义自己的异常。Dart 程序可以抛出任何非空的对象作为异常，不仅仅是 Exception 和 Error 对象。

### Throw

因为抛出异常是一个表达式，所以可以在 => 语句中使用，也可以在其他能允许使用表达式的地方抛出异常。

```dart
throw FormatException('Expected at least 1 section');

throw 'Out of llamas!';

void distanceTo(Point other) => throw UnimplementedError();
```

> 注意：生产质量代码通常会抛出实现 Error 或 Exception 的类型。

### Catch

捕获异常可以阻止异常继续传递（除非 rethrow 这个异常）。捕获异常给你了一个处理它的机会。

```dart
try {
  breedMoreLlamas();
} on OutOfLlamasException {
  buyMoreLlamas();
}
```

若要处理可能抛出多种类型异常的代码，可以指定多个 catch 语句。第一个匹配所抛出类型的 catch 语句处理此异常。如果 catch 语句没有指定类型，则此语句可以处理所有抛出的类型。

```dart
try {
  breedMoreLlamas();
} on OutOfLlamasException {
  // A specific exception
  buyMoreLlamas();
} on Exception catch (e) {
  // Anything else that is an exception
  print('Unknown exception: $e');
} catch (e) {
  // No specified type, handles all
  print('Something really unknown: $e');
}
```

可以使用 `on`、`catch` 或 **同时使用**。当需要指定类型时，请使用 `on`。当需要处理异常对象时，请使用 `catch`。

catch() 可以指定一个或两个参数。第一个是抛出的异常，第二个是堆栈跟踪信息（[StackTrace](https://api.dartlang.org/stable/dart-core/StackTrace-class.html) 对象）。

```dart
try {
  // ···
} on Exception catch (e) {
  print('Exception details:\n $e');
} catch (e, s) {
  print('Exception details:\n $e');
  print('Stack trace:\n $s');
}
```

若要处理部分异常，同时让其传递，请使用 `rethrow` 关键字。

```dart
void misbehave() {
  try {
    dynamic foo = true;
    print(foo++); // Runtime error
  } catch (e) {
    print('misbehave() partially handled ${e.runtimeType}.');
    rethrow; // Allow callers to see the exception.
  }
}

void main() {
  try {
    misbehave();
  } catch (e) {
    print('main() finished handling ${e.runtimeType}.');
  }
}
```

### Finally

若要确保在某些代码执行，不管是否有异常抛出都会执行，可以使用 finally 语句来实现。如果没有 catch 语句捕获到异常，则在执行完 finally 语句后，传递异常。

```dart
try {
  breedMoreLlamas();
} finally {
  // Always clean up, even if an exception is thrown.
  cleanLlamaStalls();
}
```

finally 语句在任何匹配的 catch 语句之后运行。

```dart
try {
  breedMoreLlamas();
} catch (e) {
  print('Error: $e'); // Handle the exception first.
} finally {
  cleanLlamaStalls(); // Then clean up.
}
```

请通过阅读 **标准库入门** 的 [Exceptions](https://www.dartlang.org/guides/libraries/library-tour#exceptions) 部分了解更多内容。

## Classes

Dart 是一个面向对象编程语言，同时支持基于 mixin 的继承机制。每个对象都是一个类的实例，所有的类都继承于 [Object](https://api.dartlang.org/stable/dart-core/Object-class.html)。

### Using class members

使用句点 `.` 可以引用实例变量或方法：

```dart
var p = Point(2, 2);

// Set the value of the instance variable y.
p.y = 3;

// Get the value of y.
assert(p.y == 3);

// Invoke distanceTo() on p.
num distance = p.distanceTo(Point(4, 4));
```

使用 `?.` 可以避免当左边对象为 null 时候抛出异常：

```dart
// If p is non-null, set its y value to 4.
p?.y = 4;
```

### Using constructors

可以使用 **构造函数** 创建对象。构造函数的名字可以是 **ClassName** 或 **ClassName.identifier**。Dart2 中关键字 `new` 不是必要的。

```dart
var p1 = Point(2, 2);
var p2 = Point.fromJson({'x': 1, 'y': 2});
var p1 = new Point(2, 2);
var p2 = new Point.fromJson({'x': 1, 'y': 2});
```

### Getting an object’s type

### Instance variables

### Constructors

### Methods

### Abstract classes

### Implicit interfaces

### Extending a class

### Enumerated types

### Adding features to a class: mixins

### Class variables and methods

## Generics

### Why use generics?

### Using collection literals

### Using parameterized types with constructors

### Generic collections and the types they contain

### Restricting the parameterized type

### Using generic methods

## Libraries and visibility

### Using libraries

### Implementing libraries

## Asynchrony support

### Handling Futures

### Declaring async functions

### Handling Streams

## Generators

## Callable classes

## Isolates

## Typedefs

## Metadata

## Comments

### Single-line comments

### Multi-line comments

### Documentation comments

## Summary

```

```
