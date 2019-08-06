---
title: webpack学习总结
date: 2019-08-06 16:48:41
tags:
---

# webpack 实战

## entry

1. 单入口 string
2. 多入口打包到一个文件 array
3. 多入口打包到各自文件 object

``` js
// 单入口
entry: "./src/index.js",
// 多入口打包到一个文件中
entry: ["./src/index.js", "./src/base.js"],
// 多入口打包到各自文件中
entry: {
  index: "./src/index.js",
  base: "./src/base.js",
  // 这是一个入口，引用jquery
  // vendor: "jquery",
  common: "./src/common.js"
}
```

## output

``` js
output: {
  // 出入的文件夹，只能是绝对路径
  path: path.join(__dirname, "dist"),
  // 打包后的文件名
  // filename: "bundle.js"
  // 打包 hash 值的文件
  // :8 代表只取 hash 前8位
  filename: "[name].[hash:8].js"
}
```

## module

### 转换css文件

* style-loader：把 css 文件变成 style 标签插入 heade 中
* css-loader：解析处理 css 文件中的 url 路径，把 css 文件变成一个模块

``` js
{
  // 转换文件的匹配规则
  test: /\.css$/,
  // css-loader 用来解析处理 css 文件中的 url 路径，把 css 文件变成一个模块
  // style-loader 可以把 css 文件变成 style 标签插入 heade 中
  // 多个 loader 是有顺序要求的，从右往左执行转换
  loader: ["style-loader", "css-loader"]
}
```

## plugins

* html-webpack-plugin：产出 HTML 模板，将打包后的文件自动插入到模板

``` js
new HtmlWebpackPlugin({
  // 指定产出的html模板
  template: "./src/index.html",
  // 产出的文件名
  filename: "base.html",
  // 将引入的js文件添加 hash 值
  hash: true,
  // 产出的html引入哪些代码块(entry 指定的代码块名称)
  chunks: ["base", "common"],
  minify: {
    // 删除标签双引号
    removeAttributeQuotes: true
  },
  // 产出自定义变量
  // 通过 <p><%=htmlWebpackPlugin.options.content%></p> 方式使用
  title: "base",
  content: "这是一段自定义内容base"
})
```

* clean-webpack-plugin：清空指定文件夹，默认清空 dist 文件夹

``` js
new CleanWebpackPlugin()
```

## devServer

``` js
devServer: {
  contentBase: "./dist",
  host: "localhost",
  port: "8002",
  // 服务器返回给浏览器的时候是否启动gzip压缩
  compress: true
}
```

<!-- # webpack 优化

# webpack 源码

# webpack 手写 -->