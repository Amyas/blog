---
title: docker创建各种容器
date: 2019-07-29 17:17:46
tags:
  docker
---

## 创建Mysql容器
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag 

``` bash
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=myblog \
  -p 3306:3306 \
  -v /Users/amyas/mysql_data:/var/lib/mysql \
mysql:5.5 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci
```
> * MYSQL_ROOT_PASSWORD：mysql密码
> * MYSQL_DATABASE：指定数据库
> * character-set-server=utf8mb4、collation-server=utf8mb4_unicode_ci：指定字符集