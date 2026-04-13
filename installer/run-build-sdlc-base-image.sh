#!/bin/bash
cd ../
docker docker rmi -f sdlc-base:python3.11-pg17.6
docker docker buildx build --platform linux/amd64 -f installer/Dockerfile-base -t sdlc-base:python3.11-pg17.6 .
docker rmi -f porsche-vector-model:v1.0.1
docker build -f installer/Dockerfile-vector-model -t porsche-vector-model:v1.0.1 .
