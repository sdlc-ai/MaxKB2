#!/bin/bash

if [ ! -d /opt/porsche/data/redis ]; then
    mkdir -p /opt/porsche/data/redis
    chmod 700 /opt/porsche/data/redis
fi
if [ ! -d /opt/porsche/logs ]; then
    mkdir -p /opt/porsche/logs
    chmod 700 /opt/porsche/logs
fi
if [ ! -f /opt/porsche/conf/redis.conf ]; then
  mkdir -p /opt/porsche/conf
  touch /opt/porsche/conf/redis.conf
  chmod 700 /opt/porsche/conf/redis.conf
  cat <<EOF > /opt/porsche/conf/redis.conf
bind 0.0.0.0
port 6379
databases 16
maxmemory 1G
aof-use-rdb-preamble yes
save 30 1
save 10 10
save 5 20
dbfilename dump.rdb
rdbcompression yes
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
maxmemory-policy allkeys-lru
loglevel warning
logfile /opt/porsche/logs/redis.log
dir /opt/porsche/data/redis
requirepass ${REDIS_PASSWORD}
EOF
fi

redis-server /opt/porsche/conf/redis.conf