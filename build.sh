#!/bin/bash
docker compose down -v
docker image prune -a -f
docker buildx prune -a -f
rm -fR data/*
rm -fR logs/*
docker build -t vfs-agent:1.2.5 .
