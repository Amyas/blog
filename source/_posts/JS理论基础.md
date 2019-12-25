---
title: JS理论基础
date: 2019-12-25 13:29:36
tags:
---

# 原型和原型链

> * 构造函数
> * 原型规则
> * 原型链
> * instanceof

## 构造函数

``` js
// 构造函数要大写
function Foo(name, age){
    this.name = name
    this.age = age
    this.class = 'class-1'
    // return this 默认 return this 所以可以不写
}
var f = new Foo('zhangsan', 20)
```

## 原型规则

5条原型规则

**原型规则**是学习**原型链**的基础

* 所有的引用类型（数组，对象，函数），都具有对象特性，既可自由扩展出行（除了   Null 之外）
* 所有的引用类型（数组，对象，函数），都有一个**\_\_proto\_\_**（隐式原型）属性，属性值是一个普通的对象
* 所有的函数，都有一个**prototype**（显式原型）属性，属性值也是一个普通的对象
* 所有的引用类型（数组，对象，函数），**\_\_proto\_\_**属性值都指向它的构造函数的**prototype**属性值
* 当试图得到一个对象的某个属性时，如果这个对象本身没有这个属性，那么就会去它的**\_\_proto\_\_**（即它的构造构造函数的**prototype**）中徇众

示例如下：
``` js
var obj = {}
obj.a = 100
var arr = []
arr.a = 100
function fn(){}
fn.a = 100

console.log(obj.__proto__)
console.log(arr.__proto__)
console.log(fn.__proto__)

console.log(fn.prototype)

console.log(obj.__proto__ === Object.prototype)
```

``` js
// 构造函数
function Foo(name, age) {
    this.name = name
}
Foo.prototype.alertName = function(){
    alert(this.name)
}
// 创建示例
var f = new Foo('zhangsan')
f.printName = function(){
    console.log(this.name)
}
// 测试
f.printName()
f.alertName()
```

## 原型链

``` js
// 构造函数
function Foo(name, age) {
    this.name = name
}
Foo.prototype.alertName = function(){
    alert(this.name)
}
// 创建示例
var f = new Foo('zhangsan')
f.printName = function(){
    console.log(this.name)
}
// 测试
f.printName()
f.alertName()
f.toString()
```

{% asset_img 1.png %}

## instanceof

用于判断**引用类型**属于哪个**构造函数**的方法

* f instanceof Foo 的判断逻辑是：
* f 的 _proto__ 一层一层往上，能否对应到 Foo.prototype
* 再试着判断 f instanceof Object，也是正确的，

# 作用域和闭包

> * 执行上下文
> * this
> * 作用域
> * 作用域链
> * 闭包

## 执行上下文

* 范围：一段**\<script\>**或者一个函数
* 全局：变量定义，函数声明（script）
* 函数：变量定义，函数声明，this，arguments（函数）

``` js
console.log(a) // undefined
var a = 100

fn('zhangsan') // zhangsan 20
function fn(name) {
    age = 20
    console.log(name,age)
    var age
}
```

## this

> this 要在执行时才能确认值，定义是无法确认

* 作为构造函数执行
* 作为对象属性执行
* 作为普通函数执行
* call apply bind

``` js
var a = {
    name: 'A',
    fn: function(){
        console.log(this.name)
    }
}
a.fn() // this === a
a.fn.call({name: 'B'}) // this === {name: 'B'}
var fn1 = a.fn
fn1() // this === window
```


## 作用域

* JS没有块级作用域
* 只有函数和全局作用域

``` js
// 无块级作用域
if(true){
    var name = 'zhangsan'
}
console.log(name)

// 函数和全局作用域
var a = 100
function fn(){
    var a = 200
    console.log('fn', a)
}
console.log('global', a)
fn()
```

## 作用域链

``` js
var a = 100
function fn(){
    var b = 200

    // 当前作用域没有定义变量，既作用域链
    console.log(a)
    console.log(b)
}
fn()
```

``` js
var a = 100
function fn() {
    var a = 300
    console.log(a)
    return (function fn1() {
        console.log(a)
    })()
}
fn()
```

## 闭包

``` js
function fn1(){
    var a = 100
    return function(){
        console.log(a)
    }
}
var f1 = fn1()
f1()
```

# 页面加载

> * 加载资源的形式
> * 加载一个资源的过程
> * 浏览器渲染页面的过程

## 加载资源的形式

* 输入 url 加载 html
* 加载 html 中的静态资源 link script img video mp3

## 加载一个资源的过程

* 浏览器根据 DNS 服务器得到域名的 IP 地址
* 向这个 IP 的机器发送 http 请求
* 服务器收到，处理并返回 http 请求
* 浏览器得到返回内容

## 浏览器渲染页面的过程

* 根据 HTML 结构成成 DOM Tree
* 根据 CSS 生成 CSSOM
* 将 DOM 和 CSS 整合形成 RenderTree
* 根据 RenderTree 开始渲染和展示
* 遇到 script 标签，会执行并阻塞渲染

## 题目

### 从输入url到得到html的详细过程

* 浏览器根据 DNS 服务器得到域名的 IP 地址
* 向这个 IP 的机器发送 http 请求
* 服务器返回，处理并返回 http 请求
* 浏览器得到返回内容

### window.onload和DOMContentLoaded的区别

* window.onload: 页面全部加载完才会执行，包括图片，视频等
* DOMContentLoaded: DOM渲染完即可执行，此时图片，视频还没加载完

# 性能优化

