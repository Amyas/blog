---
title: Jenkins+Docker构建前端自动化
date: 2019-07-23 13:59:57
tags:
  docker
---

## 本案例要实现的功能

本地Vue项目发起一个git提交，剩下的打包，自动化自动完成

## 准备工作

使用 `vue-cli` 生成一个 `vue-admin` 的项目，并上传到github中

``` bash
# 安装vue-cli
npm install -g @vue/cli

# 创建项目
vue create vue-admin
```

在根目录下创建 `Dockerfile` `Maker.Dockerfile` `nginx.conf` 三个文件

* Dockerfile: 项目打包、部署镜像
* Maker.Dockerfile: 项目依赖安装镜像
* nginx.conf: 部署nginx配置文件

### Dockerfile

``` bash
FROM vue_admin_maker AS builder

WORKDIR /app/

COPY . /app/

RUN ln -s /var/v/node_modules /app/node_modules

RUN npm run build

FROM nginx

WORKDIR /usr/share/nginx/html/

COPY ./nginx.conf /etc/nginx/

COPY --from=builder /app/dist /usr/share/nginx/html/

EXPOSE 8001
```

### Maker.Dockerfile

``` bash
FROM node

WORKDIR /var/v

ADD ./package.json /var/v/package.json

RUN npm install --registry=https://registry.npm.taobao.org
```

### nginx.conf

``` bash
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
  worker_connections  1024;
}


http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

  access_log  /var/log/nginx/access.log  main;

  sendfile        on;
  #tcp_nopush     on;

  keepalive_timeout  65;

  #gzip  on;

  server {
    listen       80;
    server_name  localhost;
    charset      utf-8;

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
        try_files $uri $uri/ /index.html;
    }
  }

}
```

## 安装Docker

``` bash
# 移除旧版本docker
sudo yum remove docker \
                        docker-client \
                        docker-client-latest \
                        docker-common \
                        docker-latest \
                        docker-latest-logrotate \
                        docker-logrotate \
                        docker-selinux \
                        docker-engine-selinux \
                        docker-engine

# 安装一些必要的系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# 安装软件源信息
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 更新yum缓存
sudo yum makecache fast

# 安装docker
sudo yum -y install docker-ce

# 启动docker
sudo systemctl start docker

# 重启docker
sudo systemctl restart docker

# 停止docker
sudo systemctl stop docker
```

>阿里云镜像加速
>您可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器

``` bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors":
    ["https://u9hmw9dm.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 安装Nginx

先创建一个nginx容器，将容器内的配置文件拷贝到主机上

```  bash
# 创建容器
docker run -d --name nginx nginx

# 创建nginx配置目录
mkdir -p /home/nginx_config

# 拷贝nginx容器内配置文件
docker cp nginx:/usr/share/nginx/html /home/nginx_config
docker cp nginx:/etc/nginx/nginx.conf /home/nginx_config
docker cp nginx:/etc/nginx/conf.d/default.conf /home/nginx_config

# 删除nginx容器
docker rm -f nginx
```

创建真正需要用到的nginx容器

``` bash
docker run -d --name web -p 80:80 \
 -v /home/nginx_config/html:/usr/share/nginx/html \
 -v /home/nginx_config/nginx.conf:/etc/nginx/nginx.conf \
 -v /home/nginx_config/default.conf:/etc/nginx/conf.d/default.conf \
nginx
```

default.conf配置修改为如下内容

``` nginx
# jenkins配置
server {
  listen        80;
  server_name   jenkins.amyas.cn;

  location / {
    proxy_pass  http://jenkins.amyas.cn:8080;
    index       index.html index.htm;
  }
}

# vue管理台配置
server {
  listen        80;
  server_name   admin.amyas.cn;

  location / {
    proxy_pass  http://admin.amyas.cn:8001;
    index       index.html index.htm;
  }
}
```

## 安装Jenkins

### 创建Jenkins容器

``` bash
docker run -d -name jenkins \
-p 8080:8080 \
-u root --privileged \
-v /home/jenkins_config:/var/jenkins_home \
jenkins/jenkins:lts

# --name 容器名称
# -p 端口映射
# -u 覆盖容器内帐号
# --privileged 赋予最高权限
# -v 映射目录
```

### Jenkins配置

访问 <http://jenkins.amyas.cn>

查看jenkins默认密码

``` bash
cat /home/jenkins_config/secrets/initialAdminPassword
```

输入密码后点击 `继续`，稍等片刻后，点击 `安装推荐的的插件`，等待安装完成后，会跳到创建管理员页面，填写好自己的信息后，点击 `保存并完成` 后在配置路径的地方再次点击 `保存并完成`，然后点击 `开始使用Jenkins`

### Jenkins更换国内源

点击左侧菜单栏（系统管理或Manage Jenkins -> 插件管理或Manage Plugins -> 高级或Advanced -> 升级站点）URL修改为:<http://mirror.xmission.com/jenkins/updates/update-center.json>并点击提交

### Jenkins插件安装

点击左侧菜单栏（系统管理或Manage Jenkins -> 插件管理或Manage Plugins -> 可选插件或Available -> 搜索对应插件 -> 直接安装）

#### Publish Over SSH

通过这个插件实现自动部署

点击左侧菜单栏（系统管理或Manage Jenkins -> 全局配置或Configure System -> Publish over SSH）

点击 SSH Servers 新增 -> 点击高级 -> 勾选 Use password authentication, or use a different key

<div style="max-width:700px;">
{% asset_img 6.png 点击创建一个新任务 %}
</div>

填写完成后点击底部 Test Configuration 按钮，出现success表示成功

#### Generic Webhook Trigger

通过这个插件实现webhook

## Jenkins创建项目

1. 点击创建一个新任务

<div style="max-width:300px;">
{% asset_img 1.png 点击创建一个新任务 %}
</div>

2. 选择自由风格的软件项目，并起一个名字

<div style="max-width:300px;">
{% asset_img 2.png 选择自由风格的软件项目，并起一个名字 %}
</div>

至此，我们的准备工作就全部完成，接下来是自动部署相关的内容

## Jenkins实现Git钩子

当我们想git push代码时，jenkins能知道我们提交了代码，并将代码拉倒我们自己的服务器，这就是我们这一步主要做的工作

1. 打开我们刚创建的 `vue-admin` 项目，点击左侧配置 -> 源码管理 -> git

<div style="max-width:700px;">
{% asset_img 3.png 源码管理 %}
</div>

2. 添加触发器，点击构建触发器 -> 勾选Generic Webhook Trigger -> 配置token

<div style="max-width:700px;">
{% asset_img 4.png 添加触发器 %}
</div>

点击应用保存

3. Github配置webhook，点击Settings -> Webhooks -> Add Webhooks

<div style="max-width:700px;">
{% asset_img 5.png Github配置webhook %}
</div>

Payload URL 格式为:
``` bash
http://<User ID>:<API Token>@<Jenkins IP地址>:端口/generic-webhook-trigger/invoke?token=<Project Token>
```

* UserID 点击 Jenkins 右上角用户名查看
* API Token 点击 Jenkins 右上角用户名后，点击左侧设置，找到 API Token 进行添加
* Project Token 为第2步添加触发器时配置的token，不配置该项只要有一个项目触发webhook，所有项目都会执行自动构建，所以多项目请用该token区分

配置成功后，项目会自动构建一次，也可以通过在浏览器输入 Payload URL 执行构建操作

## Jenkins实现自动化部署

前面我们实现了git钩子，接下来我们让jenkins为我们打包项目和部署项目

点击 构建环境 -> 勾选 Send files or execute commands over SSH after the build runs

<div style="max-width:700px;">
{% asset_img 7.png 自动化部署 %}
</div>

``` bash
sudo docker stop vue_admin || true \
&& sudo docker rm vue_admin || true \
&& cd /home/jenkins_config/workspace/vue_admin  \
&& sudo docker build -t vue_admin_maker -f Maker.Dockerfile . \
&& sudo docker build -t vue_admin . \
&& sudo docker run -d --name vue_admin -p 8001:80 vue_admin
```