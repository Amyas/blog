---
title: CSS面试题
date: 2019-12-24 19:51:35
tags:
---

## BFC原理及应用

### 原理

BFC 就是 `块级格式化上下文`，是页面盒模型布局中的一种 CSS 渲染模式，相当于一个独立的容器，里面的元素和外部的元素互不影响

通俗的说，可以把 BFC 理解为一个封闭的箱子，箱子内部的元素如何排布，都不会影响到外部。

触发 BFC 的方式有：

* body根元素
* 浮动元素 float 除 none 以外的值
* 绝对定位元素 absolute / fixed
* display 为 inline-block / flex / table
* overflow 除 visible 以外的值 hidden / auto / scroll

### 应用

同一 BFC 下外边距会发生重叠

``` html
<style>
    .container {}
    .container>div {
        width: 100px;
        height: 100px;
        background-color: red;
        margin: 100px;
    }
</style>
<body>
    <div class="container">
        <div></div>
        <div></div>
    </div>
</body>
```

{% asset_img 1.png BFC%}

从效果上看，两个盒子同处一个 BFC 容器下，所以第一个 DIV 的下边距和第二个 DIV 的上边距发生了重叠，所以两个盒子的距离只有 100px，而不是 200px

首先，这不是 CSS 的 BUG，我们可以理解为一种规范，如果想要避免外边距重叠，我们可以放在不同的 BFC 容器中。

``` html
<style>
    .container {
        overflow: hidden;
    }

    .container>div {
        width: 100px;
        height: 100px;
        background-color: red;
        margin: 100px;
    }
</style>
<body>
    <div class="container">
        <div></div>
    </div>
    <div class="container">
        <div></div>
    </div>
</body>
```

这个时候，两个盒子的边距就变成了 200px

{% asset_img 2.png BFC%}

## 怎么让一个DIV水平垂直居中

``` html
<div class="parent">
    <div class="child"></div>
</div>
```

``` css
.parent {
    display: flex;
    justify-content: center;
    align-items: center;
}
```

``` css
.parent {
    position: relative;
}
.child {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
}
```

``` css
.child {
    position: absolute;
    left: 50%;
    top: 50%;
    margin-left: -25px;
    margin-top: -25px;
    width: 50px;
    height: 50px;
}
```

``` css
.parent {
    display: flex;
}
.child {
    margin: auto;
}
```

## 已知如下代码，如何修改才能让图片宽度为 300px ？注意下面代码不可修改。

``` html
<img src="1.jpg" style="width:480px!important;”>
```

解决方法：

``` html
<img src="1.jpg" style="width:480px!important; max-width: 300px">
<img src="1.jpg" style="width:480px!important; transform: scale(0.625, 1);" >
<img src="1.jpg" style="width:480px!important; width:300px!important;">
```

``` css
box-sizing: border-box;
padding: 0 90px;
```

## 如何解决移动端 Retina 屏 1px 像素问题

``` css
div {
    position: relative;
    width: 100px;
    height: 100px;
    background-color: red;
}

div::after {
    content: "";
    position: absolute;
    left: 0;
    top: 0;
    border: 1px solid #000000;
    width: 200%;
    height: 200%;
    transform: scale(0.5);
    transform-origin: left top;
}
```

## 如何用 css 或 js 实现多行文本溢出省略效果，考虑兼容性

单行

``` css
div {
    overflow: hidden; 
    text-overflow: ellipsis; 
    white-space: nowrap; 
}
```

多行

``` css
div {
    display: -webkit-box; 
    -webkit-box-orient: vertical; 
    -webkit-line-clamp: 3; //行数 
    overflow: hidden; 
}
```