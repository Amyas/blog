---
title: MongoDB学习总结
date: 2019-07-24 10:37:11
tags:
---

## 常用操作

### 使用数据库

``` bash
use db_name
```

> * db_name: 数据库名称
> * 注：如果此数据库存在，则切换到此数据库下,如果此数据库还不存在也可以切过来,但是并不能立刻创建数据库

### 查看数据库

``` bash
# 查看所有数据库
show dbs
# 查看当前数据库
db
```

### 删除数据库

``` bash
db.dropDatabase()
```

### 关闭数据库

``` bash
use admin
db.shutdownServer()
```

### 删除集合

``` bash
db.COLLECTION_NAME.drop()
```

### 查看数据库下的集合列表

``` bash
show collections

```

## JS脚本操作集合

### 执行方法

``` bash
# mongo内
load(‘path/js_name.js’)
# mongo外
mongo path/js_name.js
```

### 添加

``` js
const db = connect('school')
const stud = []
const start = Date.now()
for(let i = 0; i < 1000; i++){
  stud.push({
    name:'zfpx' + i,
    age:i
  })
}
db.students.insert(stud)
print(`耗时: ${(Date.now() - start) / 1000}s`)
```

### 更新

``` js
const command = {
// 要操作的集合
findAndModify: 'students',
  // 查询条件
  query: { name: 'zfpx' },
  // 要更新的数据
  update:{ $set: { age: 100} },
  // 指定返回的字段 1 || true返回 0 || false不返回
  fields: { age: 1, _id: 0 },
  // 是否排序 按age字段正序排列 1,2,3,4
  sort: { age: 1},    
  // new为true返回更新后的文档，如果为false返回更新前的文档
  new: true
}
// 连接数据库
const db = connect('school')
// 返回结果
const result = db.runCommand(command)
// 打印结果
printjson(result)
```


## 插入文档

### 方法

``` bash
# 插入数据，如果_id相同会报错
insert()
# 插入数据，如果_id相同并且该数据已经存在，就更新数据，不存在就新增
save()
```

### 用法

``` bash
db.COLLECTION_NAME.insert(docuemnt)
db.COLLECTION_NAME.save(docuemnt)
```

### 实例

#### 向student集合中添加数据

``` bash
db.student.insert({_id:1,name:’amyas'})
```

#### 向student集合中添加数据，如果已经存在就更新，不存在就新增数据

``` bash
db.student.save({_id:1,name:’amyas1'})
```

## 更新文档

### 方法

``` bash
update()
```

### 用法

``` bash
db.COLLECTION_NAME.update(
  <query>,
  <update>,
  <option>
)
```

> 参数说明
> * query: update的查询条件
> * update: update的对象和一些操作符(入$set,$inc)
>   * $set: 只修改传入的数据
>   * $unset: 删除传入的指定字段
>   * $inc: 在查找额数据基础上添加
>   * $push: 向数组中添加数据，会重复添加相同值
>   * $addToSet: 向数组中添加数据，不会添加重复的值
>   * $each: 配合$push或$addToSet使用，向数组中同时添加多条数据
>   * $pop: 删除数组中的最后一位
> * options: 可选参数
>   * upsert: 如果未找到要update的记录，是否插入当前记录，true:插入，false:不插入





### 实例

#### 替换查找到的数据中的所有内容

```
# 原数据:
    { "name" : "amyas", "age" : 19 }
# 执行更新操作:
    db.student.update({name:’amyas’,{name:’tom'}})
# 更新后:
    { "name" : "tom" }
```

#### $set 只修改指定的字段

```
# 原数据:
    { "name" : "amyas", "age" : 19 }
# 执行更新操作:
    db.student.update({name:'amyas'},{$set:{name:'tom'}})
# 更新后:
    { "name" : "tom", "age" : 19 }
```

#### $unset 只删除指定字段

```
# 原数据:
    { "name" : "amyas", "age" : 19 }
# 指定更新操作:
    db.student.update({name:'amyas'},{$unset:{age:1}})
# 更新后:
    { "name" : "amyas" }
```

#### $inc 在number类型的字段基础上做加法

```
# 原数据:
    { "name" : "amyas", "age" : 10 }
# 执行更新操作:
    db.student.update({name:'amyas'},{$inc:{age:10}})
# 更新后:
    { "name" : "amyas", "age" : 20 }
```

#### $push 向数组中添加数据，会重复添加相同值

``` 
# 原数据:
    { "name" : "amyas", "hobby" : [ "play" ] }
# 执行更新操作:
    db.student.update({name:'amyas'},{$push:{hobby: 'play'}})
# 更新后:
    { "name" : "amyas", "hobby" : [ "play", "play" ] }
```

#### $addToSet 向数组中添加数据，存在重复值就不添加

```
# 原数据:
    { "name" : "amyas", "hobby" : [  "play" ] }
# 执行更新操作:
    db.student.update({name:'amyas'},{$addToSet:{hobby: 'play'}})
# 更新后:
    { "name" : "amyas", "hobby" : [ "play" ] }
```

#### $each 向数组中同时添加多条数据

```
# 配合$push、$addToSet使用
# 原数据:
    { "name" : "amyas", "hobby" : [ ] }
# 执行更新操作:
    db.student.update({name:'amyas'},{$push:{hobby:{$each:['play','book']}}})
# 更新后:
    { "name" : "amyas", "hobby" : [ "play", "book" ] }
```

#### $pop 删除数组中的最后一位

```
# 原数据:
    { "name" : "amyas", "hobby" : [ "play", "book", "school", "car" ] }
# 执行更新操作:
    db.student.update({name:'amyas'},{$pop:{hobby:1}})
# 更新后:
    { "name" : "amyas", "hobby" : [ "play", "book" ] }
```

#### 修改数组中指定索引的元素

```
# 原数据:
    { "name" : "amyas", "hobby" : [ "play", "book", "school" ] }
# 执行更新操作:
    db.student.update({name:'amyas'},{$set:{'hobby.2':'news'}})
# 更新后:
    { "name" : "amyas", "hobby" : [ "play", "book", "news", "car" ] }
```

#### upsert 有该记录就修改，没有就插入该记录

```
# 原数据:
    无
    
# 执行更新操作:
    db.student.update({name:'amyas'},{$set:{age:1}},{upsert:true})

# 更新后:
    { "name" : "amyas", "age" : 1 }
```

#### multi 批量修改符合条件的数据

```
# 原数据:
    { "name" : "amyas", "age" : 10 }
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 10 }

# 执行更新操作:
    db.student.update({age:10},{$set:{age:20}},{multi:true})

# 更新后:
    { "name" : "amyas", "age" : 20 }
    { "name" : "tom", "age" : 20 }
    { "name" : "jack", "age" : 20 }
```

## 删除文档

### 方法

```
remove()
```

### 用法

```
db.COLLECTION_NAME.remove(
  <query>,
  {
    justOne: <boolean>    
  }
)
```
> 参数说明
> * query: （可选） 删除记录的条件
> * justOne : （可选）如果设为 true 或 1，则只删除一个文档，如果不设置该参数，或使用默认值 false，则删除所有匹配条件的文档。


### 实例

#### 删除所有匹配的记录

```
# 原数据:
    { "name" : "amyas", "age" : 10 }
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 20 }

# 执行删除操作:
    db.student.remove({age:10})

# 删除后:
    { "name" : "jack", "age" : 20 }
```

#### justOne 删除匹配记录的第一条

```
原数据:
    { "name" : "amyas", "age" : 10 }
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 10 }

执行删除操作:
    db.student.remove({age:10},{justOne:true})

删除后:    
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 10 }

```

## 查询文档

### 方法

```
# 返回所有符合条件的数据
find()
# 返回符合条件的第一条数据
findOne()
# 查看数据总数
count()
```

### 用法

```
db.COLLECTION_NAME.find(query,projection)
db.COLLECTION_NAME.findOne(query,projection)
db.COLLECTION_NAME.count()
```

> 参数说明:
> * query: 可选，使用查询操作符指定查询条件
>* projection: 可选，默认返回所有字段，设置后只返回指定字段

### 实例

#### 返回查询结果的指定字段

```
#原数据:
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 10 }

# 执行查询操作:
    db.student.find({},{age:1})

# 查询结果:
    { "age" : 10 }
    { "age" : 10 }
```

#### 返回除了指定字段外的字段

```
# 原数据:
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 10 }

# 执行查询操作:
    db.student.find({},{age:0})

# 查询结果:
    { "name" : "tom" }
    { "name" : "jack" }
```

#### $in 返回符合具体条件的数据

```
# 原数据:
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 20 }
    { "name" : "amyas", "age" : 30 }

# 执行查询操作:
    db.student.find({age:{$in:[10,30]}})

# 查询结果:
    { "name" : "tom", "age" : 10 }
    { "name" : "amyas", "age" : 30 }
```

#### $nin 返回除了具体条件外的数据

```
# 原数据:
    { "name" : "tom", "age" : 10 }
    { "name" : "jack", "age" : 20 }
    { "name" : "amyas", "age" : 30 }

# 执行查询操作:
    db.student.find({age:{$nin:[10,20]}})

# 查询结果:
    { "name" : "amyas", "age" : 30 }
```