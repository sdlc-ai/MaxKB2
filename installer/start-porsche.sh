#!/bin/bash

if [ ! -d /opt/porsche/logs ]; then
    mkdir -p /opt/porsche/logs
fi
chmod -R 700 /opt/porsche/logs
if [ ! -d /opt/porsche/local ]; then
    mkdir -p /opt/porsche/local
    chmod 700 /opt/porsche/local
fi
mkdir -p /opt/porsche/python-packages

rm -f /opt/porsche-app/tmp/*
python /opt/porsche-app/main.py start