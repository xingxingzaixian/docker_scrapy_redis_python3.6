FROM python:3.6

MAINTAINER xingxingzaixian "942274053@qq.com"

WORKDIR /app

ADD requirements.txt /app

ADD scrapyd.conf ~/.scrapyd.conf

ADD redis.conf /app/redis.conf

RUN wget http://download.redis.io/releases/redis-stable.tar.gz && tar xf redis-stable.tar.gz && cd redis-stable && make && make install

RUN mkdir /scrapyd && pip install -r requirements.txt

EXPOSE 6379 6800 80

CMD ["scrapyd", "redis-server /app/redis.conf']
