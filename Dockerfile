FROM python:3.6

MAINTAINER xingxingzaixian "942274053@qq.com"

WORKDIR /app

ADD requirements.txt /app

ADD scrapyd.conf ~/.scrapyd.conf

ADD redis.conf 

RUN wget http://download.redis.io/releases/redis-stable.tar.gz

RUN apt-get install gcc g++ make

RUN wget http://download.redis.io/releases/redis-stable.tar.gz && tar xf redis-stable.tar.gz && cd redis-stable && make MALLOC=libc && make install

RUN mkdir /scrapyd && pip install -r requirements.txt

RUN wget http://download.redis.io/releases/redis-stable.tar.gz && tar -xvf redis-stable.tar.gz && cd redis-stable && make && make PREFIX=/usr/local/redis install

EXPOSE 6379 6800 80

CMD ["scrapyd", "redis-server']
