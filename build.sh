#!/bin/sh
sudo docker stop hexo_blog || true \
&& sudo docker rm hexo_blog || true \
&& sudo docker build -t hexo_blog_maker -f Maker.Dockerfile . \
&& sudo docker build -t hexo_blog . \
&& sudo docker run -d --name hexo_blog -p 8002:80 hexo_blog