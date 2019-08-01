---
title: 原生实现博客项目后端
date: 2019-07-25 19:11:13
tags:
---

# 开发博客项目之接口

要开发一个博客项目的 server 端，首先要实现技术方案设计中的各个 API 。本章主要讲解如何使用原生 nodejs 处理的 http 请求，包括路由分析和数据返回，然后代码演示各个 API 的开发 。但是本章尚未连接数据库，因此 API 返回的都是假数据。...

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

## 开发路由（删除博客和登录路由）

### 删除博客

``` js
// controller/blog.js
exports.removeBlog = id => {
  return true;
};
```

``` js
// router/blog.js
case "/api/blog/del":
  const delResult = removeBlog(req.query.id);
  if (delResult) {
    return new SuccessModel();
  } else {
    return new ErrorModel("删除博客失败");
  }
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/3053cafbfb54447d27cb321b3b10df37c5430234)

### 登录

``` js
// controller/user.js
exports.login = (username, password) => {
  if (username === "zhangsan" && password === "123") {
    return true;
  }
  return false;
};
```

``` js
// router/user.js
const { login } = require("../controller/user");
const { SuccessModel, ErrorModel } = require("../model/resModel");

module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "POST" && path === "/api/user/login") {
    const { username, password } = req.body;
    const result = login(username, password);
    if (result) {
      return new SuccessModel();
    }
    return new ErrorModel("登录失败");
  }
};
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/64a67842675ec09b7a13c2b8766a6b9a800af2bf)

# 开发博客项目之数据存储

API 实现了，就需要连接数据库，实现真正的数据存储和查询，不再使用假数据。本章主要讲解 mysql 使用，以及用 nodejs 连接 mysql ，最后将 mysql 应用到各个已经开发完的 API 中。

## 数据库操作（创建和增、删、改、查）

### 创建数据表

``` sql
-- 查询字符集
show variables like'character%';

-- 选择数据库
USE myblog;

-- 查看当前数据库下的表列列表
SHOW TABLES;

-- 创建users表
CREATE TABLE `myblog`.`users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `password` varchar(20) NOT NULL,
  `realname` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
);

-- 创建blogs表
CREATE TABLE `myblog`.`blogs`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) NOT NULL,
  `content` longtext NOT NULL,
  `createtime` bigint(20) NOT NULL DEFAULT '0',
  `author` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
);
```

### 增

``` sql
-- 插入users表的数据
INSERT INTO users (username,`password`,realname) VALUES('zhangsan', '123', '张三');
INSERT INTO users (username,`password`,realname) VALUES('lizi', '123', '李四');
INSERT INTO users (username,`password`,realname) VALUES('wangwu', '123', '王五');

-- 插入到blogs表的数据
INSERT INTO blogs (title, content, createtime, author) VALUES('文章标题1','文章内容1', 1564480904040, 'zhangsan');
INSERT INTO blogs (title, content, createtime, author) VALUES('文章标题2','文章内容2', 1564480963937, 'lisi');
```

### 删

``` sql
-- 如果无法更新删除，执行该命令，解除安全模式
SET SQL_SAFE_UPDATES = 0;

-- 删除 users 表下 username 等于 wangwu 的数据
DELETE FROM users WHERE username = 'wangwu';

-- 不建议直接删除数据，而是通过添加state，0为删除，这样不会真的删除数据
-- 这种方法叫：软删除
UPDATE users SET state= '0' WHERE username = 'lisi'
```

### 改

``` sql
-- 如果无法更新删除，执行该命令，解除安全模式
SET SQL_SAFE_UPDATES = 0;

-- 将之前写错的username = lizi 修改为 lisi
UPDATE users SET username = 'lisi' WHERE username = 'lizi';
```

### 查

``` sql
-- 查询users表下所有数据
SELECT * FROM users;

-- 查询users表下所有数据的id,username
SELECT id,username FROM users;

-- 查询users表下的所有数据，并且username等于zhangsan
SELECT * FROM users WHERE username = 'zhangsan';

-- 查询users表下的所有数据，并且username等于zhangsan并且password等于123
SELECT * FROM users WHERE username = 'zhangsan' AND `password` = '123';

-- 查询users表下的所有数据，并且username等于zhangsan或password等于123
SELECT * FROM users WHERE username = 'zhangsan' OR `password` = 123;

-- 模糊查询
SELECT * FROM users WHERE username LIKE '%zhang%';

-- 正序查询（默认）
SELECT * FROM users WHERE `password` LIKE '%1%' ORDER BY id;

-- 倒叙查询
SELECT * FROM users WHERE `password` LIKE '%1%' ORDER BY id DESC;

-- 查询 users 表中 state 不等于 0 的数据
SELECT * FROM users where STATE <>'0';

-- 查询 blogs 中所有数据，并根据 createtime 倒叙排列
SELECT * FROM blogs ORDER BY createtime DESC;

-- 查询 blogs 中 author 等于 lisi 的所有数据，并根据 createtime 倒叙排列
SELECT * FROM blogs WHERE author = 'lisi' ORDER BY createtime DESC;

-- 查询 blogs 表中 title 中包含 '文章标题' 的所有数据，并根据 createtime 倒叙排列
SELECT * FROM blogs WHERE title LIKE '%文章标题%' ORDER BY createtime DESC;
```

## nodejs 操作 mysql（演示Demo）

``` js
const mysql = require("mysql");

// 创建连接对象
const conn = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "root",
  port: "3306",
  database: "myblog"
});

// 开始连接
conn.connect();

// 执行 sql 语句
const sql = "select * from users;";
conn.query(sql, (err, result) => {
  if (err) {
    console.log(err);
    return;
  }
  console.log(result);
});

// 关闭连接
conn.end();
```

## nodejs 封装 mysql

安装 mysql 依赖

``` bash
yarn add mysql
```

``` js
// conf/db.js
const env = process.env.NODE_ENV; // 环境变量

let MYSQL_CONF;

if (env === "development") {
  MYSQL_CONF = {
    host: "localhost",
    user: "root",
    password: "root",
    port: "3306",
    database: "myblog"
  };
}

if (env === "production") {
  MYSQL_CONF = {
    host: "localhost",
    user: "root",
    password: "root",
    port: "3306",
    database: "myblog"
  };
}

module.exports = {
  MYSQL_CONF
};
```

``` js
// db/mysql.js
const mysql = require("mysql");
const { MYSQL_CONF } = require("../conf/db");

// 创建链接对象
const con = mysql.createConnection(MYSQL_CONF);

// 开始连接
con.connect();

// 执行 sql 函数
function exec(sql) {
  return new Promise((resolve, reject) => {
    con.query(sql, (err, result) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(result);
    });
  });
}

module.exports = {
  exec
};
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/90bd56cbab303fecd87f7572dc6a9ecb934234d7)

## API对接mysql（博客列表、增，删，改，查，登录）

``` js
// controller/blog.js
const { exec } = require("../db/mysql");

exports.getList = (author, keyword) => {
  // 1=1 占位置，避免后续 and 或者 order by 拼接错误
  let sql = `select * from blogs where 1=1`;
  if (author) {
    sql += ` and author='${author}'`;
  }
  if (keyword) {
    sql += ` and title like '%${keyword}%'`;
  }
  sql += ` order by createtime desc;`;

  return exec(sql);
};

exports.getDetail = id => {
  let sql = `select * from blogs where id='${id}'`;
  return exec(sql).then(rows => {
    return rows[0];
  });
};

exports.createBlog = (data = {}) => {
  const { title, content, author } = data;
  const createtime = Date.now();

  let sql = `
    insert into blogs (title, content, createtime, author)
    values ('${title}', '${content}', ${createtime}, '${author}');
  `;

  return exec(sql).then(data => {
    return {
      id: data.insertId
    };
  });
};

exports.updateBlog = (id, data = {}) => {
  const { title, content } = data;
  let sql = `update blogs set title = '${title}', content = '${content}' where id = '${id}';`;
  return exec(sql).then(data => {
    if (data.affectedRows > 0) {
      return true;
    }
    return false;
  });
};

exports.removeBlog = (id, author) => {
  let sql = `delete from blogs where id='${id}' and author = '${author}';`;
  return exec(sql).then(data => {
    if (data.affectedRows > 0) {
      return true;
    }
    return false;
  });
};
```

``` js
// router/blog.js
module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "GET" && path === "/api/blog/list") {
    const author = req.query.author || "";
    const keyword = req.query.keyword || "";
    return getList(author, keyword).then(data => {
      return new SuccessModel(data);
    });
  }

  if (method === "GET" && path === "/api/blog/detail") {
    const id = req.query.id;
    return getDetail(id).then(data => {
      return new SuccessModel(data);
    });
  }

  if (method === "POST" && path === "/api/blog/new") {
    return createBlog(req.body).then(data => {
      return new SuccessModel(data);
    });
  }

  if (method === "POST" && path === "/api/blog/update") {
    return updateBlog(req.query.id, req.body).then(data => {
      if (data) {
        return new SuccessModel("更新成功");
      }
      return new ErrorModel("更新失败");
    });
  }

  if (method === "POST" && path === "/api/blog/del") {
    return removeBlog(req.query.id, req.query.author).then(data => {
      if (data) {
        return new SuccessModel("删除成功");
      }
      return new ErrorModel("删除失败");
    });
  }
};
```

``` js
// controller/user.js
const { exec } = require("../db/mysql");

exports.login = (username, password) => {
  const sql = `
    select username, realname from users where username='${username}' and password='${password}';
  `;
  return exec(sql).then(data => data[0] || {});
};
```

``` js
// router/user.js
module.exports = (req, res) => {
  const method = req.method;
  const path = req.path;

  if (method === "POST" && path === "/api/user/login") {
    const { username, password } = req.body;
    return login(username, password).then(data => {
      if (data.username) {
        return new SuccessModel(data);
      }
      return new ErrorModel("登录失败");
    });
  }
};
```

``` js
// app.js
...
const blogResult = handleBlogRouter(req, res);
if (blogResult) {
  blogResult.then(data => {
    res.end(JSON.stringify(data));
  });
  return;
}

const userRusult = handleUserRouter(req, res);
if (userRusult) {
  userRusult.then(data => {
    res.end(JSON.stringify(data));
  });
  return;
}
...
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/c3f7b0ac0e6b44dfec5ac8bc900f7e3e2d467c90)


# 博客项目之登录

用户登录是博客项目的主要功能之一，本章主要讲解如何使用原生 nodejs 实现登录。包括 cookie session 的介绍和使用，以及为了扩展性和性能使用 redis 来存储 session 。最后，通过 nginx 配置联调环境，和前端页面联调。本章内容较多，对于前端开发人员来说，新概念也较多，是本课程学习上的挑战。...

## nodejs 操作 redis （演示demo）

``` js
const redis = require("redis");

// 创建客户端
const redisClient = redis.createClient(6379, "127.0.0.1");

redisClient.on("error", err => {
  console.log(err);
});

// 测试
redisClient.set("myname", "zhangsan", redis.print);
redisClient.get("myname", (err, val) => {
  if (err) {
    console.log(err);
    return;
  }
  console.log(val);

  // 退出
  redisClient.quit();
});
```

## nodejs 将 session 存入 redis

添加redis配置信息

``` js
// conf/db.js
REIDS_CONF = {
  host: "localhost",
  port: 6379
};
```

封装 redis

``` js
// db/redis.js
const redis = require("redis");
const { REIDS_CONF } = require("../conf/db");

// 创建客户端
const redisClient = redis.createClient(REIDS_CONF.port, REIDS_CONF.host);

redisClient.on("error", err => {
  console.log(err);
});

function set(key, val) {
  if (typeof val === "object") {
    val = JSON.stringify(val);
  }
  redisClient.set(key, val, redis.print);
}

function get(key) {
  return new Promise((resolve, reject) => {
    redisClient.get(key, (err, val) => {
      if (err) {
        reject(err);
        return;
      }
      if (val == null) {
        resolve(null);
        return;
      }

      try {
        resolve(JSON.parse(val));
      } catch (error) {
        resolve(val);
      }
      resolve(val);
    });
  });
}

module.exports = {
  set,
  get
};
```

app.js 添加 处理 cookie 和 session 的逻辑

``` js
...
const { get, set } = require("./src/db/redis");
...

// cookie 过期时间
const getCookieExpires = () => {
  const d = new Date();
  d.setTime(d.getTime() + 24 * 60 * 60 * 1000);
  return d.toGMTString();
};

const serverHandle = async (req, res) => {
...

  // 解析 cookie
  req.cookie = {};
  const cookie = req.headers.cookie || "";
  cookie.split(";").forEach(item => {
    if (!item) return;

    const [key, val] = item.split("=");
    req.cookie[key] = val;
  });

  // 解析 session 使用 redis
  let needSetCookie = false;
  let userId = req.cookie.userid;
  if (!userId) {
    needSetCookie = true;
    userId = `${Date.now()}_${Math.random()}`;
    // 初始化 redis 中的 session 值
    set(userId, {});
  }

  // 获取 session
  req.sessionId = userId;
  const sessionData = await get(req.sessionId);
  if (sessionData == null) {
    // 初始化 redis 中的 session 值
    set(req.sessionId, {});
    // 设置 session
    req.session = {};
  } else {
    req.session = sessionData;
  }
...

...
blogResult.then(data => {
    if (needSetCookie) {
      res.setHeader(
        "Set-Cookie",
        `userid=${userId}; path=/; httpOnly; expires=${getCookieExpires()}`
      );
    }
    res.end(JSON.stringify(data));
  });
...

...
userRusult.then(data => {
    if (needSetCookie) {
      res.setHeader(
        "Set-Cookie",
        `userid=${userId}; path=/; httpOnly; expires=${getCookieExpires()}`
      );
    }
    res.end(JSON.stringify(data));
  });
...
```

登录将用户信息同步到 redis session 中

``` js
...
const { set, get } = require("../db/redis");
...
module.exports = (req, res) => {
..
  if (method === "GET" && path === "/api/user/login") {
    const { username, password } = req.query;
    return login(username, password).then(data => {
      if (data.username) {
        // 设置 session
        req.session.username = data.username;
        req.session.realname = data.realname;

        // 同步 session
        set(req.sessionId, req.session);

        return new SuccessModel(data);
      }
      return new ErrorModel("登录失败");
    });
  }
};
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/84d80b64f90d42249dcdec7c03acb316745cf044)

## 统一的登录验证

``` js
// router/blog.js

...
// 统一的登录验证函数
const loginCheck = req => {
  if (!req.session.username) {
    return Promise.resolve(new ErrorModel("尚未登录"));
  }
};
...
  if (method === "POST" && path === "/api/blog/new") {
    const loginCheckResult = loginCheck(req);
    if (loginCheckResult) {
      // 未登录
      return loginCheckResult;
    }
    req.body.author = req.session.username;
    ...
  }

  if (method === "POST" && path === "/api/blog/update") {
    const loginCheckResult = loginCheck(req);
    if (loginCheckResult) {
      // 未登录
      return loginCheck;
    }
    ...
  }

  if (method === "POST" && path === "/api/blog/del") {
    const loginCheckResult = loginCheck(req);
    if (loginCheckResult) {
      // 未登录
      return loginCheck;
    }
    req.query.author = req.session.username;
    ...
  }
```

### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/e72ef250f6407d73afb57b7ef8821da93760f2dc)


## 前后端联调

### 后端修改

axios传的content-type和直接浏览器请求有差异，所有优化getPostData

``` js
// app.js
...
const getPostData = req => {
  return new Promise((resolve, reject) => {
    ...
    const contentType = req.headers["content-type"].toLowerCase();
    if (contentType.indexOf("application/json") === -1) {
      resolve({});
      return;
    }
    ...
  });
};
...
```

前后端端口都使用8080会冲突，所以这里将后端端口改为8081

``` js
// bin/www.js
const PORT = 8081;
```

管理员列表校验登录和只返回属于自己的文章

``` js
// router/blog.js
...
if (method === "GET" && path === "/api/blog/list") {
  let author = req.query.author || "";
  const keyword = req.query.keyword || "";
  if (req.query.isadmin) {
    // 管理员界面
    const loginCheckResult = loginCheck(req);
    if (loginCheckResult) {
      // 未登录
      return loginCheckResult;
    }
    // 强制查询自己的博客
    author = req.session.username;
  }
  return getList(author, keyword).then(data => {
    return new SuccessModel(data);
  });
}
...
```

更新文章时，只可以更新自己的文章

``` js
// router/blog.js
if (method === "POST" && path === "/api/blog/update") {
  ...
  req.body.author = req.session.username;
  return updateBlog(req.query.id, req.body).then(data => {
  ...
}
```

``` js
// controller/blog.js
...
exports.updateBlog = (id, data = {}) => {
  const { title, content, author } = data;
  let sql = `update blogs set title = '${title}', content = '${content}' where id = '${id}' and author = '${author';`;
  ...
};
...
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/33f30b0068057925045da61396765a86cbacb07b)


### 前端新增

内容较多且简单，直接看git吧

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/67237dd88b8e21a45672fdce5e2289bb3f327d4d)

# 博客项目之日志

日志记录和日志分析是 server 端的重要模块，前端涉及较少。本章主要讲解如何使用原生 nodejs 实现日志记录、日志内容分析和日志文件拆分。其中包括 stream readline 和 crontab 等核心知识点。

## node 文件操作

``` js
const fs = require("fs");
const path = require("path");

const filename = path.resolve(__dirname, "data.txt");

// 读取文件内容
fs.readFile(filename, (err, data) => {
  if (err) {
    console.log(err);
    return;
  }

  // 默认 data 为二进制buffer，需要转换成字符串
  console.log(data.toString());
});

// 写入文件
const content = "这是新写入的内容\n";
const option = {
  flag: "a" //a = append 追加写入，覆盖写入用 'w' write
};
fs.writeFile(filename, content, option, err => {
  if (err) {
    console.log(err);
    return;
  }
});

// 判断文件是否存在
fs.exists(filename, exist => {
  console.log(exist);
});
```

## stream

### 写入访问日志

封装写日志方法

``` js
// utils/log.js
const fs = require("fs");
const path = require("path");

// 生成 write Stream
function createWriteStream(filename) {
  const fullFileName = path.join(__dirname, "../../logs", filename);
  const writeStream = fs.createWriteStream(fullFileName, {
    flags: "a"
  });
  return writeStream;
}

// 写访问日志
const accessWriteStream = createWriteStream("access.log");
function access(log) {
  if (process.env.NODE_ENV === "production") {
    accessWriteStream.write(log + "\n");
    return;
  }
  console.log(log);
}

module.exports = {
  access
};
```

调用写日志方法

``` js
// app.js
const { access } = require("./src/utils/log");
...
const serverHandle = async (req, res) => {
  // 记录 access log
  access(
    `${req.method} -- ${req.url} -- ${
      req.headers["user-agent"]
    } -- ${Date.now()}`
  );
  ...
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/24f33783be1a6d4d23f85c8e3e6575de2d2543c7)

### 日志拆分

使用 crontab 定时拆分日志

``` sh
#!/bin/sh
cd /Users/amyas/amyas/project/node_web_server/node/logs
cp access.log $(date +%Y-%m-%d).access.log
echo "" > access.log
```

### 分析日志

``` js
// utils/readline.js
const fs = require("fs");
const path = require("path");
const readline = require("readline");

// 文件地址
const fileName = path.join(__dirname, "../../logs", "access.log");

// 创建 read stream
const readStream = fs.createReadStream(fileName);

// 创建 readline 对象
const rl = readline.createInterface({
  input: readStream
});

// 逐行读取
rl.on("line", lineData => {
  if (!lineData) {
    return;
  }

  const [method, url, userAgent, date] = lineData.split(" -- ");
  console.log("method:", method);
  console.log("url:", url);
  console.log("userAgent", userAgent);
  console.log("date", new Date(+date).toString());
});

rl.on("close", () => {
  console.log("读取完成");
});
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/fa8d12b6692fbce9333add7b62c55b7489d8d7c6)

# 博客项目之安全

安全是 server 端需要考虑的重点内容，本章主要讲解 nodejs 如何防范 sql 注入

## sql 注入

登录 sql 注入

``` js
select username, realname from users where username='${username}' and password='${password}';
```

> 如果 username 传入的是 `lisi' -- `，后面的 `and password...` 就会无效，攻击者不需要密码就可以登录成功，进行操作

解决方案：
  * 使用 mysql 的 escape 方法处理传入的字段
  * 将 sql 中字段的 '' 删除

``` js
// controller/user.js
const { exec, escape } = require("../db/mysql");
// escape = mysql.escape

exports.login = (username, password) => {
  username = escape(username);
  password = escape(password);
  const sql = `
    select username, realname from users where username=${username} and password=${password};
  `;
  return exec(sql).then(data => data[0] || {});
};
```

这样如果传入 `' -- `，将会被反斜线转义

``` sql
select username, realname from users where username='lizi\' -- `' and password='1';
```

#### [本小节内容Git提交记录](https://github.com/Amyas/node_web_server/commit/6813c179fc2f393ab3bb4f85d79e72d52f464573)