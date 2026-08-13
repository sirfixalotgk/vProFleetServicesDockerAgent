#!/bin/bash
HOSTNAME=$(grep -v '^#' .env | grep HOSTNAME_OVERRIDE | cut -d '=' -f2 | cut -d "'" -f2) && \
DNS_SUFFIX=$(grep -v '^#' .env | grep DNS_SUFFIX | cut -d '=' -f2 | cut -d "'" -f2) && \
docker run -d -it --name vfs-agent \
    -v ./init.sh:/usr/local/bin/init.sh \
    -v ./PairingToken:/agent/PairingToken \
    -v ./data:/agent/.data \
    -v ./logs:/agent/logs \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -p 623:623 \
    -p 664:664 \
    -p 16992-16993:16992-16993 \
    --device=/dev/mei0 --privileged \
    --hostname="$HOSTNAME" \
    --dns-search="$DNS_SUFFIX" \
    --cgroupns=host \
    vfs-agent:1.2.5

