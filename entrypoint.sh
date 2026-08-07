#!/bin/bash
set -e
#
# Optional process for handling the hostname passed during activation
#
# The hostname parameter is set by default in the docker-compose.yaml file
#
# Disable the docker-compose.yaml parameter if the below provides a reliable
# way to parse and populate the system FQDN. 
#
# if [ -n "${HOSTNAME_OVERRIDE}" ]; then
#     hostname "${HOSTNAME_OVERRIDE}" || true
#     echo "${HOSTNAME_OVERRIDE}" > /etc/hostname
# fi
#
exec "$@"

