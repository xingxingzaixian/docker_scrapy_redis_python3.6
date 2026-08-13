# docker_scrapy_redis_python3.6

## 简介
基于docker基础镜像python:3.11，安装scrapy/scrapyd，安装并配置redis集群，针对不同机器的集群配置

## 版本说明（2026 安全升级）

- 基础镜像由 `python:3.6` 升级为 `python:3.11`（Python 3.6 已于 2021 年停止官方维护）。
- 依赖同步升级到修复已知 CVE 的安全版本，并保证 `scrapy-redis` 分布式功能兼容：
  - `scrapy==2.9.0`：支持 Python 3.11，且是 `scrapy-redis 0.6.8` 兼容的最高版本（scrapy 2.6+ 与 scrapy-redis 0.6.8 存在不兼容，故不宜继续升高）。
  - `scrapyd==1.2.1`、`redis==5.0.8`、`lxml==5.3.0`、`requests==2.32.4`（修复 CVE-2026-25645 等）。
  - `scrapy-redis==0.6.8` 保持不变。
- 若本地爬虫代码依赖旧版 API，升级后请重新构建镜像并对现有爬虫做回归测试。

## 运行命令

1. 拉取镜像
docker build -t scrapy_redis https://github.com/xingxingzaixian/docker_scrapy_redis_python3.6.git

2. 创建自定义网络
docker network create --subnet=172.18.0.0/16 mynetwork

3. 运行容器
1) docker run -itd --name redis-16379 --net mynetwork --ip 172.18.0.2 -p 16379:6379 -p 16800:6800 scrapy_redis:latest /bin/bash 
2) docker run -itd --name redis-16380 --net mynetwork --ip 172.18.0.3 -p 16384:6379 -p 16800:6800 scrapy_redis:latest /bin/bash
3) docker run -itd --name redis-16381 --net mynetwork --ip 172.18.0.4 -p 16380:6379 -p 16800:6800 scrapy_redis:latest /bin/bash
4) docker run -itd --name redis-16382 --net mynetwork --ip 172.18.0.5 -p 16381:6379 -p 16800:6800 scrapy_redis:latest /bin/bash
5) docker run -itd --name redis-16383 --net mynetwork --ip 172.18.0.6 -p 16382:6379 -p 16800:6800 scrapy_redis:latest /bin/bash
6) docker run -itd --name redis-16384 --net mynetwork --ip 172.18.0.7 -p 16383:6379 -p 16800:6800 scrapy_redis:latest /bin/bash

4. 修改redis启动配置
1) docker exec -d redis-16379 sed -i "s/localhost/172.18.0.2/g" /app/redis.conf
2) docker exec -d redis-16380 sed -i "s/localhost/172.18.0.3/g" /app/redis.conf
3) docker exec -d redis-16381 sed -i "s/localhost/172.18.0.4/g" /app/redis.conf
4) docker exec -d redis-16382 sed -i "s/localhost/172.18.0.5/g" /app/redis.conf
5) docker exec -d redis-16383 sed -i "s/localhost/172.18.0.6/g" /app/redis.conf
6) docker exec -d redis-16384 sed -i "s/localhost/172.18.0.7/g" /app/redis.conf

5. 启动scrapyd和redis服务
1) docker exec -d redis-16379 redis-server /app/redis.conf
2) docker exec -d redis-16380 redis-server /app/redis.conf
3) docker exec -d redis-16381 redis-server /app/redis.conf
4) docker exec -d redis-16382 redis-server /app/redis.conf
5) docker exec -d redis-16383 redis-server /app/redis.conf
6) docker exec -d redis-16384 redis-server /app/redis.conf

6. 启动Redis集群
docker exec -d redis-16379 /app/redis-stable/src/redis-trib.rb create --replicas 1 172.18.0.2:16379 172.18.0.3:16380 172.18.0.4:16381 172.18.0.5:16382 172.18.0.6:16383 172.18.0.7:16384
