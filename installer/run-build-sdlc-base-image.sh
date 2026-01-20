#!/bin/bash
cd ../
docker rmi -f porsche-base:python3.11-pg17.6
docker build -f installer/Dockerfile-base -t porsche-base:python3.11-pg17.6 .
docker rmi -f porsche-vector-model:v1.0.1
docker build -f installer/Dockerfile-vector-model -t porsche-vector-model:v1.0.1 .
