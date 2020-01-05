---
title: JS手写系列
date: 2020-01-04 12:39:38
tags:
---

# 深拷贝

```js
function cloneDeep(source) {
    if (!isObject(source)) return source
    const target = Array.isArray(source) ? [] : {}
    for (const key in source) {
        if (Object.prototype.hasOwnProperty.call(source, key)) {
            if (isObject(source[key])) {
                target[key] = cloneDeep(source[key])
            } else {
                target[key] = source[key]
            }
        }
    }
    return target
}

function isObject(obj) {
    return typeof obj === 'object' && obj !== null
}
```

# new

``` js
function create(){
    const obj = new Object()
    const Con = [].shift.call(arguments)
    obj.__proto__ = Con.prototype
    const ret = Con.apply(obj,arguments)
    return ret instanceof Object ? ret : obj
}
```

# 防抖

# 节流

# call

# apply

# bind

# 自动计算rem

# promise

# 双向绑定