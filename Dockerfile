FROM python:3.6

MAINTAINER xingxingzaixian "942274053@qq.com"

WORKDIR /app

ADD requirements.txt /app

ADD redis.conf /app/redis.conf

RUN mkdir /etc/scrapyd

ADD scrapyd.conf /etc/scrapyd/scrapyd.conf

RUN wget http://download.redis.io/releases/redis-stable.tar.gz && tar xf redis-stable.tar.gz && cd redis-stable && make && make install

RUN wget https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz && tar xf ruby-2.5.1.tar.gz && cd ruby-2.5.1 && ./configure && make && make install

RUN wget https://rubygems.org/rubygems/rubygems-2.7.7.tgz && tar xf rubygems-2.7.7.tgz && cd rubygems-2.7.7 && ruby setup.rb && gem install redis

RUN mkdir /scrapyd && mkdir /app/redis-cluster && pip install -r requirements.txt

EXPOSE 6379 6800 80