---
title: MongoDB学习总结
date: 2019-07-24 10:37:11
tags:
    MongoDB
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

### 游标

``` js
const db = connect('school')

// 返回的是一个游标，指向结果的一个指针
const cursor = db.students.find()

cursor.forEach(function(item) {
    printjson(item)
})
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

# $not取反和$nin相同
    db.student.find({age:{$not:{$in:[10,20]}}})
结果和上面$nin相同
```

### $gt 大于操作符、$gte 大于等于操作符

```
# 原数据:
    { "name" : "zfpx10", "age" : 10 }
    { "name" : "zfpx20", "age" : 20 }
    { "name" : "zfpx30", "age" : 30 }
    { "name" : "zfpx40", "age" : 40 }
    { "name" : "zfpx50", "age" : 50 }
    { "name" : "zfpx60", "age" : 60 }
    { "name" : "zfpx70", "age" : 70 }
    { "name" : "zfpx80", "age" : 80 }

# 执行查询操作:
    db.student.find({age:{$gt:50}})

# 查询结果:
    { "name" : "zfpx60", "age" : 60 }
    { "name" : "zfpx70", "age" : 70 }
    { "name" : "zfpx80", "age" : 80 }

# $gte是大于等于

# 可以配合 $not 使用取反，可以配合 $lt 取范围
```

### $lt 小于操作符、$lte 小于等于操作符

```
# 原数据:
    { "name" : "zfpx10", "age" : 10 }
    { "name" : "zfpx20", "age" : 20 }
    { "name" : "zfpx30", "age" : 30 }
    { "name" : "zfpx40", "age" : 40 }
    { "name" : "zfpx50", "age" : 50 }
    { "name" : "zfpx60", "age" : 60 }
    { "name" : "zfpx70", "age" : 70 }
    { "name" : "zfpx80", "age" : 80 }

# 执行查询操作:
    db.student.find({age:{$lt:50}})

# 查询结果:
    { "name" : "zfpx10", "age" : 10 }
    { "name" : "zfpx20", "age" : 20 }
    { "name" : "zfpx30", "age" : 30 }
    { "name" : "zfpx40", "age" : 40 }

# $lte是小于等于

# 可以配合 $not 使用取反，可以配合 $gt 取范围
```

### $all 匹配数组中包含所有字段的数据

```
# 原数据:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }

# 执行查询操作:
    db.student.find({hobby:{$all:['a','b']}})

# 查询结果:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }
```

### $size 获取指定数组长度的数组

```
# 原数据:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b" ] }

# 执行查询操作:
    db.student.find({hobby:{$size:3}})

# 查询结果:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
```

### $slice 显示查询结果数组的指定长度

```
# 原数据:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }

# 执行查询操作:
    db.student.find({hobby:{$size:3}},{hobby:{$slice:2}})

# 查询结果:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b" ] }

# $slice:-1 从最后一个开始 
```

### $where 万能查询

```
# 原数据:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }

# 执行查询操作:
    db.student.find({$where:"this.age === 10"})

# 查询结果:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
```

### $or 或

```
# 原数据:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }

# 执行查询操作:
    db.student.find({$or:[{name:'zfpx10'},{age:20}]})

# 查询结果:
    { "name" : "zfpx10", "age" : 10, "hobby" : [ "a", "b", "c" ] }
    { "name" : "zfpx20", "age" : 20, "hobby" : [ "a", "b", "d" ] }
```

### skip、limit 分页查询

```
var pageNumber = 1;
var pageSize = 3;
db.student.find().skip((pageNumber-1)*pageSize).limit(pageSize)
```

### sort 排序

```
正序：从小到大 1
倒序：从大到小 -1

db.student.find().sort(age:-1)
```

### explain 获取查询结果的详情分析

```
db.COLLECTION_NAME.find().explain(true)
```

## 索引

先插入100万数据，方便我们使用

``` js
var arr = []
for(var i = 1; i <= 1000000; i++) {
  arr.push({
    name:'zfpx' + i,
    age:i,
    random:Math.random()
  })
}
db.stus.insert(arr)
```

### 查看索引

```
db.COLLECTION_NAME.getIndexes()
```

### 删除索引

```
db.COLLECTION_NAME.dropIndex('INDEX_NAME')

# INDEX_NAME:索引名称
```

### 创建匿名索引

```
db.stus.ensureIndex({age:1})
# 1为升序
# -1为降序

修改默认索引名称为nameIndex
db.stus.ensureIndex({age:1},{name:'ageIndex'})
```

### unique 唯一索引

```
# 设置唯一索引的字段，不能重复
db.ids.ensureIndex({id:1},{unique:true})
```

### 过期索引

过期后数据自动清除
删除时间不精确，每60秒查询一次，删除也需要时间，所有有误差

```
# 必须是日期才可以
db.logs.ensureIndex({time:1},{expireAfterSeconds:10})
```

### text 全文索引

```
# 原始数据
{ "content" : "i am a boy" }
{ "content" : "i am a girl" }
{ "content" : "i am a boy girl" }
{ "content" : "i am a boygirl" }

# 创建索引
db.article.ensureIndex({content:'text'})

# 查询
# 所有包含boy的数据（boygirl找不到，只能找单词）
db.article.find({$text:{$search:'boy'}})
{ "content" : "i am a boy" }
{ "content" : "i am a boy girl" }

# 既包含boy又包含girl
db.article.find({$text:{$search:'boy girl'}})
{ "content" : "i am a boy" }
{ "content" : "i am a boy girl" }
{ "content" : "i am a girl" }

# 只包含boy不包含girl
db.article.find({$text:{$search:'boy -gril'}})
{ "content" : "i am a boy" }
{ "content" : "i am a boy girl" }
```

## Mongoose

### 安装mongoose

``` bash
yarn add mongoose
```

### 使用mongoose

``` js
const mongoose = require("mongoose");
const conn = mongoose.createConnection("mongodb://user:pass@ip:port/database");

// 实例
const conn = mongoose.createConnection("mongodb://127.0.0.1:27017/zfpx");
// 连接失败
conn.on("err", function(err) {
  console.log("err:", err);
});

// 连接成功
conn.on("open", function() {
  console.log("start");
});

// user 用户名 没有设置可以不写
// pass 密码 没有设置可以不写
// ip IP地址
// port 端口号 没有设置可以不写，走默认端口27017
// database 数据库
```

### Schema 模型

Schema是数据库集合的骨架模型，定义了集合中的字段的名称和类型以及默认值等信息

### Schema.Type

NodeJS中的基本数据类型都属于Schema.Type，另外Mongoose还定义了自己的类型，基本属性类型有：

* 字符串(String)
* 日期型(Date)
* 数值型(Number)
* 布尔型(Boolean)
* null
* 数组
* 内嵌文档(JSON)

### 定义Schema

``` js
const Schema = mongoose.Schema;
const PersonSchema = new Schema({
  name: String, //姓名
  binary: Buffer, //二进制
  living: Boolean, //是否活着
  birthday: Date, //生日
  age: Number, //生日
  _id: Schema.Types.ObjectId, //主键
  _fk: Schema.Types.ObjectId, //外键,其他关联表的主键
  array: [], //数组
  arrOfString: [String], //字符串数组
  arrOfNumber: [Number], //数字数组
  arrOfDate: [Date], //日期数组
  arrOfBuffer: [Buffer], //二进制数组
  arrOfBoolean: [Boolean], //布尔值数组
  arrOfObjectId: [Schema.Types.ObjectId], //对象ID数组
  nested: {
    // 内嵌文档
    name: String
  }
});
```

### Model

Model是由通过Schema构造而成，除了具有Schema定义的数据库骨架以外，还可以操作数据库

``` js
const Person = mongoose.model("Person", PersonSchema);

const data = {
  name: "zfpx",
  age: 9,
  home: "beijing"
};

const person = new Person(data);

person.save((err, doc) => {
  console.log(err); // err = null 表示没有错误
  console.log(doc); // doc = 保存成功后的文档
});
```

### 基础操作

#### 插入数据

``` js
const persons = [];
for (let i = 0; i < 10; i++) {
  persons.push({
    name: "zfpx" + i,
    age: i
  });
}
Person.create(persons, function(err, docs) {
  console.log(err);
  console.log(docs);
});
```

#### 关联查询

``` js
Student.create({ name: "zfpx" })
  .then(student => {
    Score.create({
      stuid: student._id,
      grade: 100
    });
  })

Score.findById("5d39870a09af1ef81996993d")
  .populate("stuid")
  .exec()
  .then(res => {
    console.log(res);
  });
```
