FROM node

WORKDIR /home/hexo_blog

COPY . .

RUN npm install hexo-cli -g --registry=https://registry.npm.taobao.org && \
npm install --registry=https://registry.npm.taobao.org && \
hexo clean && hexo g