#!/bin/bash

mkdir -p /opt/porsche/data/postgresql
docker-entrypoint.sh postgres -c max_connections=${POSTGRES_MAX_CONNECTIONS}
