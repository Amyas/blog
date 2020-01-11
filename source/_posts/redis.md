---
title: Redis学习总结
date: 2019-08-06 16:41:44
tags:
---

docker 进入 redis

``` bash
docker exec -it redis redis-cli
```

获取所有key

``` bash
keys *
```

取值

``` bash
get key
```

删除

``` bash
del key
```