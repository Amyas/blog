FROM hexo_blog_maker AS builder

FROM nginx

WORKDIR /usr/share/nginx/html

COPY --from=builder /home/hexo_blog/public /usr/share/nginx/html

EXPOSE 80