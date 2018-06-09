# docker_scrapy_redis_python3.6

## 简介
基于docker基础镜像python:3.6，安装scrapy/scrapyd，安装并配置redis集群，针对不同机器的集群配置

## 运行命令

1. 拉取镜像
docker build -t scrapy_redis https://github.com/xingxingzaixian/docker_scrapy_redis_python3.6.git

2. 创建自定义网络
docker network create --subnet=172.18.0.0/16 mynetwork

2. 运行容器
docker run -it --name scrapy_redis --net mynetwork --ip 172.18.0.2 -p 16379:6379 scrapy_redis:latest sh -c "redis-server /app/redis.conf && scrapyd" 
