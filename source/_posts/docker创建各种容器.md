---
title: docker创建各种容器
date: 2019-07-29 17:17:46
tags:
  docker
---

## 创建Mysql容器

``` bash
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=study \
  -v /Users/amyas/mysql_data:/var/lib/mysql \
mysql:5.5
```
> * MYSQL_ROOT_PASSWORD：mysql密码
> * MYSQL_DATABASE：指定数据库