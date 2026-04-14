#!/bin/bash
cd ../
docker rmi -f sdlc-base:python3.11-pg17.6
docker buildx build --platform linux/amd64 -f installer/Dockerfile-base -t sdlc-base:python3.11-pg17.6 .
docker rmi -f sdlc-vector-model:v1.0.1
docker build -f installer/Dockerfile-vector-model -t sdlc-vector-model:v1.0.1 .
