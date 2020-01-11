---
title: JS面试题
date: 2019-12-24 21:00:27
tags:
---

## ['1', '2', '3'].map(parseInt)

先说结论

``` js 
[1, NaN, NaN]
```

parseInt 函数解析一个字符串参数，返回一个指定基数的整数

``` js
const value = parseInt(string, [radix])
```

> radix 一个2-36的整数，表示字符串的基数，比如参数10表示使用10进制数值计算。默认为10进制


``` js
['1', '2', '3'].map((item, index)=>{
    return parseInt(item, index)
})

parseInt('1', 0) // 1 radix为0，会用10为基数解析
parseInt('2', 1) // NaN radix必须是2-36的整数，无法解析
parseInt('3', 2) // NaN, 3 不是二进制
```

## 介绍下 Set、Map区别

Set 是一种叫做集合的数据结构，主要用于数组重组
Set 成员是唯一且无序的，没有重复的值
Set 用 size 代替 数组的 length
Set 有如下操作方法：
 * add(value) 添加
 * delete(value) 删除
 * has(value) 判断集合中是否存在 value
 * clear() 清空合集

Map 是一种叫做字典的数据结构，主要用于数据存储

和 Set 的共同点：都可以存储不重复的值
不同点：合集是以 [value, key]，字典是以 [key, value] 形式存储

Map 也有 size 属性

Map 有如下操作方法
 * set(key, value)
 * get(key)
 * delete(key)
 * has(key)

Map 有如下方法
 * keys() 字典中所有键值
 * values() 字典中所有数值
 * entries() 字典中所有成员的迭代器
 * forEach() 遍历字典所有成员
