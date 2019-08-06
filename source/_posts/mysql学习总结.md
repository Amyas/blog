---
title: mysql学习总结
date: 2019-08-06 16:41:23
tags:
---

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

-- 插入users表的数据
INSERT INTO users (username,`password`,realname) VALUES('zhangsan', '123', '张三');
INSERT INTO users (username,`password`,realname) VALUES('lizi', '123', '李四');
INSERT INTO users (username,`password`,realname) VALUES('wangwu', '123', '王五');

-- 插入到blogs表的数据
INSERT INTO blogs (title, content, createtime, author) VALUES('文章标题1','文章内容1', 1564480904040, 'zhangsan');
INSERT INTO blogs (title, content, createtime, author) VALUES('文章标题2','文章内容2', 1564480963937, 'lisi');

-- 如果无法更新删除，执行该命令，解除安全模式
SET SQL_SAFE_UPDATES = 0;

-- 删除 users 表下 username 等于 wangwu 的数据
DELETE FROM users WHERE username = 'wangwu';

-- 不建议直接删除数据，而是通过添加state，0为删除，这样不会真的删除数据
-- 这种方法叫：软删除
UPDATE users SET state= '1' WHERE username = 'lisi'

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