---
title: "细说 原型链"
slug: prototype-chain
date: 2019-03-15
draft: true
autoThumbnailImage: false
coverImage: /images/cover.jpeg
metaAlignment: center
categories:
  - javascript
tags:
  - javascript
keywords:
  - javascript
---

原型链算是 JavaScript 中比较难以理解的部分之一，今天就和大家分享一下我说理解的原型链。

<!--more-->

## \_\_proto\_\_、prototype 和 constructor

函数对象通过复制原型对象创建实例对象。

- \_\_proto\_\_ 指向创建该对象的原型。
- prototype 指向函数对象用于创建实例对象的原型。
- constructor 指向原型对象关联的构造函数。

我们先看一个简单的例子，此例来着于 [@mqyqingfeng](https://github.com/mqyqingfeng/Blog/issues/2)。此例很容易理解，就不详细解释，若不明白，可去阅读 [@mqyqingfeng](https://github.com/mqyqingfeng/Blog/issues/2) 的文章。

```javascript
function Person() {}
preson = new Person();
console.log(preson.__proto__ === Person.prototype);
console.log(Person === Person.prototype.constructor);
```

![prototype-1](/images/2019/03/prototype-1.png)

下面是一个更复杂的例子。

我们有时需要实现自定义错误，下面的代码就实现了一个简单的自定义错误。函数对象 CustomError F 的 prototype 指向函数对象 Error F 的实例对象 error。那么 CustomError 创建出的实例对象 ce 会拥有 error 的性质和方法，由于 error 复制于 Error P，而 Error P 的 constructor 指向 Error F，所以需要将 `CustomError.prototype.constructor` 指回 CustomError F。尝试下面的代码，如果将 `CustomError.prototype.constructor = CustomError;` 注释掉会发生什么？

```javascript
function CustomError(message) {
  this.message = message || "default message";
  this.name = "CustomError";
}
CustomError.prototype = new Error();
CustomError.prototype.constructor = CustomError;

customerror = new CustomError();
console.log(customerror.constructor);
console.log(CustomError.prototype.constructor);
console.log(customerror.__proto__.__proto__ === Error.prototype);
```

![prototype-2](/images/2019/03/prototype-2.png)

## Function 与函数对象

既然被称作是函数对象，那么你们肯定可以猜到，它和函数的关系。函数对象 是由函数 Function 创建的。又由前面的介绍，我们很容易得到下面的结论。此图借鉴于我的 [小弟 (da ge)](https://github.com/fengyfei)。此图省略了所有的 constructor 的线、Array 等的实例原型对象及其关系。主要关注 函数对象 与 Function 函数对象及 Function 原型对象的关系，它们都通过三种颜色的线围成了一个圈。

```javascript
console.log(Object.__proto__ === Function.prototype);
console.log(Function.__proto__ === Function.prototype);
console.log(Function === Function.prototype.constructor);
```

![prototype-3](/images/2019/03/prototype-3.png)

## 一切皆 Object

所有对象都继承于 Object，于是就有了下面这张图。

![prototype-4](/images/2019/03/prototype-4.png)

这张图是怎么来的呢？

我们想一下，一开始没有 Object，没有 Function，没有 Array，什么都没有。

因为万物皆空，所以 JavaScript 创建了 null 作为一切的开头。接着以 null 作为原型创建了 Object P，然后以 Object P 作为原型创建了 Function P，然后以 Function P 作为原型创建了 Function F，然后以 Function P 作为原型创建 Object F，并将 Object F 与 Object P 关联上，至此完成初始化。Function F 创建函数对象 Func F 时，会自动创建原型对象 Func P。

因此可以解释 `null instanceof Object === false`。

![prototype-5](/images/2019/03/prototype-5.png)
