# docker_scrapy_redis_python3.6

## 简介
基于docker基础镜像python:3.11，安装scrapy/scrapyd，安装并配置redis集群，针对不同机器的集群配置

## 版本说明（2026 安全升级）

- 基础镜像由 `python:3.6` 升级为 `python:3.11`（Python 3.6 已于 2021 年停止官方维护）。
- 依赖已升级到修复已知 CVE 的最新版本：

| 依赖 | 版本 | 说明 |
|------|------|------|
| scrapy | 2.19.0 | 修复 CVE-2025-6176、CVE-2026-105782、CVE-2024-1892、CVE-2024-3572、CVE-2024-3574、CVE-2026-84366 等（需 >= 2.16） |
| requests | 2.34.2 | 修复 CVE-2026-25645（需 >= 2.33） |
| lxml | 6.1.3 | 修复 CVE-2026-41066（需 >= 6.1.0） |
| scrapy-redis | 0.9.1 | 已支持 `scrapy>=2.6.0`，取代废弃的 0.6.8 |
| scrapyd | 1.6.0 | 最新版，要求 `scrapy>=2.0.0` |
| redis | 5.0.8 | 满足 `scrapy-redis` 对 `redis>=4.2` 的要求 |

- 兼容性说明：`scrapy-redis 0.9.1` 的调度器按接口（鸭子类型）满足 Scrapy 2.16+ 的 `BaseScheduler` 校验，且引擎调用的
  `open(spider)` / `close(reason)` / `enqueue_request(request)` / `next_request()` / `has_pending_requests()` 签名与之一致。
- 配置兼容性：`SCHEDULER` / `SCHEDULER_*`、`DUPEFILTER_CLASS`、`REDIS_HOST` / `REDIS_PORT` / `REDIS_URL` / `REDIS_PARAMS`、
  `REDIS_ITEMS_KEY` / `REDIS_ITEMS_SERIALIZER`、`START_URLS_KEY` 等设置项与 0.6.8 保持一致；仅移除了
  `REDIS_START_URLS_BATCH_SIZE`，并新增 `MAX_IDLE_TIME`、`REDIS_START_URLS_AS_ZSET` 等可选设置。
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
