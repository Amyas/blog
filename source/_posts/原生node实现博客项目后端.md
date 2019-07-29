---
title: 原生实现博客项目后端
date: 2019-07-25 19:11:13
tags:
---

## 处理GET请求

``` js
const http = require("http");
const querystring = require("querystring");

const server = http.createServer((req, res) => {
  const url = req.url;
  req.query = querystring.parse(url.split("?")[1]);
  res.end(`hello world query:${JSON.stringify(req.query)}`);
});

server.listen(8080, () => {
  console.log("start server");
});
```

## 处理POST请求

``` js
const http = require("http");

const server = http.createServer((req, res) => {
  let rawData = "";
  req.on("data", chunk => {
    rawData += chunk;
  });
  req.on("end", () => {
    const postData = JSON.parse(rawData);
    res.end(`hello world postData:${JSON.stringify(postData)}`);
  });
});

server.listen(8080, () => {
  console.log("start server");
});
```

## 处理GET、POST综合实例

``` js
const http = require("http");
const querystring = require("querystring");

const server = http.createServer((req, res) => {
  const method = req.method;
  const url = req.url;
  const path = url.split("?")[0];
  const query = querystring.parse(url.split("?")[1]);

  // 设置返回格式为JSON
  res.setHeader("Content-type", "application/json");

  // 返回的数据
  const resData = {
    method,
    url,
    path,
    query
  };

  // 返回
  if (method === "GET") {
    res.end(JSON.stringify(resData));
  } else if (method === "POST") {
    let rawData = "";
    req.on("data", chunk => (rawData += chunk));
    req.on("end", () => {
      resData.postData = JSON.parse(rawData);
      res.end(JSON.stringify(resData));
    });
  }
});

server.listen(8080, () => {
  console.log("start server");
});
```

## 搭建开发环境

* 从0开始，不使用任何框架
* 使用 `nodemon` 检测文件变化，自动重启 node
* 使用 `cross-env` 设置环境变量，兼容 mac linxu、windows

1. 安装 nodemon cross-env

``` bash
yarn add nodemon cross-env
```

2. 创建app.js

``` js
const serverHandle = (req, res) => {
  // 设置返回格式 JSON
  res.setHeader("Content-type", "application/json");

  const resData = {
    name: "amyas",
    env: process.env.NODE_ENV
  };

  res.end(JSON.stringify(resData));
};

module.exports = serverHandle;
```

3. 创建bin/www.js

``` js
const http = require("http");

const PORT = 8080;
const serverHandle = require("../app");

const server = http.createServer(serverHandle);
server.listen(PORT, () => {
  console.log("server port: ", PORT);
});
```

4. 修改pacjage.json

``` json
"scripts": {
  "dev": "cross-env NODE_ENV=development nodemon ./bin/www.js",
  "pord": "cross-env NODE_ENV=production nodemon ./bin/www.js"
}
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/c7911eab28284d59083ea4a432dd457ca93de0ad)

> git 提交中 app.js 中 process 有错误，错误内容为 `ProcessingInstruction`，正确内容应为 `process`

## 初始化路由

路由目录:

|描述|接口|方法|URL参数|
|---|---|---|---|
|获取博客列表 |/api/blog/list     |GET    |`author` 作者，`keyword` 搜索关键字|
|获取博客详情 |/api/blog/detail   |GET    |id |
|新增博客     |/api/blog/new      |POST   | |
|更新博客     |/api/blog/update   |POST   | |
|删除博客     |/api/blog/del      |POST   |id|
|登录         |/api/user/login   |POST    | |

1. 创建博客相关路由

``` js
// /src/router/blog.js
module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "GET") {
    switch (path) {
      case "/api/blog/list":
        return { msg: "获取博客列表" };
      case "/api/blog/detail":
        return { msg: "获取博客详情" };
      default:
        break;
    }
  }

  if (method === "POST") {
    switch (path) {
      case "/api/blog/new":
        return { msg: "新增博客" };
      case "/api/blog/update":
        return { msg: "更新博客" };
      case "/api/blog/del":
        return { msg: "删除博客" };
      default:
        break;
    }
  }
};
```

2. 创建登录路由

``` js
// /src/router/user.js
module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "POST" && path === "/api/user/login") {
    return { msg: "获取博客列表" };
  }
};
```

3. 修改 app.js，获取路由相关内容

``` js
// /app.js
const handleBlogRouter = require("./src/router/blog");
const handleUserRouter = require("./src/router/user");

const serverHandle = (req, res) => {
  // 设置返回格式 JSON
  res.setHeader("Content-type", "application/json");

  const url = req.url;
  req.path = url.split("?")[0];

  const blogData = handleBlogRouter(req, res);
  if (blogData) {
    res.end(JSON.stringify(blogData));
    return;
  }

  const userData = handleUserRouter(req, res);
  if (userData) {
    res.end(JSON.stringify(userData));
    return;
  }

  // 未命中路由，返回 404
  res.writeHead(404, { "Content-type": "text/plain" });
  res.write("404 Not Fount\n");
  res.end();
};

module.exports = serverHandle;
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/d6c8e103f90caa53b3878eeaa6842cdf44d4149a)

## 开发路由（博客列表路由）

1. 修改app.js，解析 query

``` js
// app.js
const querystring = require("querystring");
const serverHandle = (req, res) => {
  // 解析 query
  req.query = querystring.parse(url.split("?")[1]);

...
```

2. 创建controller文件夹，新建blog.js

controller主要实现获取数据操作

``` js
// controller/blog.js
exports.getList = (author, keyword) => {
  // 先返回假数据（格式是正确的）
  return [
    {
      id: 1,
      title: "标题A",
      content: "内容A",
      createTime: 1564129277991,
      author: "作者A"
    },
    {
      id: 1,
      title: "标题B",
      content: "内容B",
      createTime: 1564129278991,
      author: "作者B"
    }
  ];
};
```

3. 新增response返回模块

该模块主要实现返回数据的格式

``` js
// model/resModel.js
class BaseModel {
  constructor(data, message) {
    if (typeof data === "string") {
      this.message = data;
      data = null;
      message = null;
    }
    if (data) {
      this.data = data;
    }
    if (message) {
      this.message = message;
    }
  }
}

class SuccessModel extends BaseModel {
  constructor(data, message) {
    super(data, message);
    this.errno = 0;
  }
}

class ErrorModel extends BaseModel {
  constructor(data, message) {
    super(data, message);
    this.errno = -1;
  }
}

module.exports = {
  SuccessModel,
  ErrorModel
};
```

4. 修改blog路由页

``` js
const { getList } = require("../controller/blog");
const { SuccessModel, ErrorModel } = require("../model/resModel");

module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "GET") {
    switch (path) {
      case "/api/blog/list":
        const author = req.query.author || "";
        const keyword = req.query.keyword || "";
        const listData = getList(author, keyword);
        return new SuccessModel(listData);

      case "/api/blog/detail":
        return { msg: "获取博客详情" };
      default:
        break;
    }
  }
  ...
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/73c618e84c810032369c76928a1d36dac5353be4)


## 开发路由（博客详情路由）

1. 在controller的blog.js中添加获取详情的假数据

``` js
exports.getDetail = id => {
  // 先返回假数据
  return {
    id: 1,
    title: "标题A",
    content: "内容A",
    createTime: 1564129277991,
    author: "作者A"
  };
};
```

2. 修改router中的blog.js，改为调用controller中的方法获取数据

``` js
module.exports = (req, res) => {
...
  case "/api/blog/detail":
    const id = req.query.id;
    const data = getDetail(id);
    return new SuccessModel(data);
...
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/1edc5cd6c7542f4f943e90df76818490d9b6033f)

## 开发路由（处理POST Data）

新增处理post data 方法

``` js
// app.js
const getPostData = req => {
  return new Promise((resolve, reject) => {
    if (req.method !== "POST") {
      resolve({});
      return;
    }
    if (req.headers["content-type"] !== "application/json") {
      resolve({});
      return;
    }
    let postData = "";
    req.on("data", chunk => {
      postData += chunk.toString();
    });
    req.on("end", () => {
      if (!postData) {
        resolve({});
        return;
      }
      resolve(JSON.parse(postData));
    });
  });
};

const serverHandle = async (req, res) => {
  ...
  // 解析 query
  req.query = querystring.parse(url.split("?")[1]);

  // 处理 post data
  const postData = await getPostData(req);
  req.body = postData;
  ...
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/8d59786e687df8fcd0a48e818b43928f7803baa2)

## 开发路由（新建和更新博客路由）

### 新建博客

1. controller 中的 blog.js 中添加 createBlog 方法

``` js
// controller/blog.js
exports.createBlog = (data = {}) => {
  // data是一个博客对象，包含 titlle content
  return {
    id: 3
  };
};
```

2. 修改 router 中的 blog.js 获取数据的方法

``` js
// router/blog.js
...
case "/api/blog/new":
  const data = createBlog(req.body);
  return new SuccessModel(data);
...
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/47ac54a3777294e6bfd749af4ba56610814165bc)

### 更新博客

``` js
// controller/blog.js
exports.updateBlog = (id, data = {}) => {
  return true;
};
```

``` js
// router/blog.js
...
case "/api/blog/update":
  const id = req.query.id;
  const result = updateBlog(id, req.body);
  if (result) {
    return new SuccessModel();
  } else {
    return new ErrorModel("更新博客失败");
  }
...
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/828040f9938f3b1d40f6150cb115fd88834fa884)