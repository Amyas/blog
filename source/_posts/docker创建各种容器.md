---
title: docker创建各种容器
date: 2019-07-29 17:17:46
tags:
  docker
---

## Mysql

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
> * --character-set-server=utf8mb4：指定字符集
> * --collation-server=utf8mb4_unicode_ci：指定字符集

## Mongo

``` bash
docker run -d --name mongo \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=123456 \
  -p 27017:27017 \
  -v /home/mongo_data:/data_db \
mongo
```

> * MONGO_INITDB_ROOT_USERNAME：账号
> * MONGO_INITDB_ROOT_PASSWORD：密码

登录 mongo

``` bash
# 进入 mongo
docker exec -it mongo mongo
# 进入 admin
use admin
# 登录
db.auth("user","pass")
# 查看用户
show users
```

## Redis

``` bash
docker run -d --name redis \
  -p 6379:6379 \
  -v /Users/amyas/redis_data:/data \
redis \
redis-server --appendonly yes \
--requirepass "123456"
```

> * redis-server --appendonly yes：redis 持久化配置
> * --requirepass：设置密码

密码登录redis

``` bash
# 进入 redis
docker exec -it redis redis-cli
# 密码登录
auth 123456
```