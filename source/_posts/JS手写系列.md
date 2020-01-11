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

> 防抖是触发高频事件后n秒后函数执行一次，如果n秒内高频事件再次被触发，则重新计算时间

``` js
function debounce(fn, delay) {
    let timer = null
    return function (...args) {
        clearTimeout(timer)
        timer = setTimeout(() => {
            fn.apply(this, args)
        }, delay);
    }
}
```

# 节流

> 节流是触发高频事件后，n秒内函数只会执行一次，会稀释函数的执行频率

``` js
function throttle(fn, delay) {
    let previous = 0
    return function (...args) {
        let now = +new Date()
        if (now - previous > delay) {
            previous = now
            fn.apply(this, args)
        }
    }
}
```

# call

``` js
Function.prototype.call2 = function (context, ...args) {
    context = context ? Object(context) : window
    context.fn = this
    const res = context.fn(...args)
    delete context.fn
    return res
}
```

# apply

``` js
Function.prototype.apply2 = function (context, args) {
    context = context ? Object(context) : window
    context.fn = this
    const res = context.fn(...args)
    delete context.fn
    return res
}
```

# bind

``` js
Function.prototype.bind2 = function (context, ...args) {
    const self = this
    return function (...newArgs) {
        return self.apply(context, args.concat(newArgs))
    }
}
```

# 双向绑定

``` html
<body>
  <div id="app">
    <input type="text" v-model="number">
    <button v-click="increment">增加</button>
    <h3>当前值:{{number}}</h3>
  </div>
  <script>
    window.onload = function () {
      const app = new Mvvm({
        el: '#app',
        data: {
          number: 0
        },
        methods: {
          increment() {
            this.number++
          }
        }
      })
    }
    class Watcher {
      constructor(name, el, attr, vm, exp) {
        this.name = name
        this.el = el
        this.attr = attr
        this.vm = vm
        this.exp = exp
        this.update()
      }
      update() {
        this.el[this.attr] = this.vm.$data[this.exp]
      }
    }
    class Mvvm {
      constructor(options) {
        this._init(options)
      }
      _init(options) {
        this.$el = document.querySelector(options.el)
        this.$data = options.data
        this.$methods = options.methods
        this._binding = {}
        this._observer(this.$data)
        this._compile(this.$el)
      }
      _compile(root) {
        const $this = this
        const nodes = root.children
        Array.from(nodes).forEach(node => {
          if (node.hasAttribute('v-click')) {
            const attrVal = node.getAttribute('v-click')
            node.addEventListener('click', function () {
              $this.$methods[attrVal].call($this.$data)
            })
          }
          if (node.hasAttribute('v-model')) {
            const attrVal = node.getAttribute('v-model')
            this._binding[attrVal]._directives.push(new Watcher(
              'input',
              node,
              'value',
              this,
              attrVal
            ))
            node.addEventListener('input', function () {
              $this.$data[attrVal] = node.value
            })
          }
          const tplReg = /\{\{(.*)\}\}/
          if (tplReg.test(node.innerHTML)) {
            const attrVal = tplReg.exec(node.innerHTML)[1]
            this._binding[attrVal]._directives.push(new Watcher(
              'text',
              node,
              'innerHTML',
              this,
              attrVal
            ))
          }
        })
      }
      _observer(obj) {
        let value
        Object.keys(obj).forEach(key => {
          this._binding[key] = {
            _directives: []
          }
          value = obj[key]
          if (typeof value === 'object') {
            this._observer(value)
          }
          const binding = this._binding[key]
          Object.defineProperty(obj, key, {
            enumerable: true,
            configurable: true,
            get: function () {
              return value
            },
            set: function (newVal) {
              if (value !== newVal) {
                value = newVal
                binding._directives.forEach(item => item.update())
              }
            }
          })
        })
      }
    }
  </script>
</body>
```

# 自动计算rem

公式：当前元素设计图尺寸 / (设计图宽度 / 10) = rem

例如：

设计图宽：750px
元素宽：100px    rem = 100 / (750 / 10) = 1.33rem
元素高: 50px     rem = 50 / (750 / 10) = 0.66rem

``` js
(function () {
  function setRootSize() {
    const html = document.documentElement
    html.style.fontSize = html.clientWidth / 10 + 'px'
  }
  setRootSize()
  document.addEventListener('resize', setRootSize1)
})()
```
> 多种实现方案请查看[移动端适配解决方案](https://github.com/Amyas/mobile-rem-vw)

# promise