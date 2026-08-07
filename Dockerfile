# Intel(R) vPro Fleet Services activation container
#
# This Dockerfile will download packages and applications
# from publicly available sources to create and launch a
# Docker container.
#
# The ensueing container hosts the Local Manageability Service
# as well as the requisite services and applications to interface
# directly with the Management Engine and provision AMT.
#
# The following items must exist in the same directory that this
# Dockerfile and the corresponding docker-compose.yaml file 
# reside in:
#  - PairingToken         (The pairing token file for the endpoint
#                          group this device will be a member of)
#  - entrypoint.sh        (Pre-init items can be added to this script)
#  - init.sh              (Part of this package)
#  - init-script.sh       (Part of this package)
#  - docker-compose.yaml  (Part of this package, optional)
#  - data                 (folder that holds host specific pairing info)
#  - logs                 (agent logs created during the activation process)
#  - .env                 (use to set variables to be used with this container)
#                         NOTE: must be edited to reflect proper hostname/FQDN value
#
# NOTE: This container MUST be launched with the privilege option and have
#       access to /dev/mei0.
#
FROM ubuntu:24.04
#
ENV DEBIAN_FRONTEND=noninteractive
#
# Install systemd and other requisite packcages as well as
# clean package cache
#
RUN apt-get update \
    && apt-get install -y \
    systemd \
    systemd-sysv \
    network-manager \
    whoopsie \
    dbus \
    iproute2 \
    iputils-ping \
    net-tools \
    curl \
    wget \
    libxerces-c3.2 \
    libace-7.1.2t64 \
    libxerces-c3.2t64 \
    vim \
    strace \
    jq \
    ca-certificates \
    && apt-get clean \
    && rm -fR /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
# Install Intel(R) Local Manageability Service (LMS)
#
RUN wget -O /tmp/lms.deb \ 
    https://github.com/rgl/lms-binaries/releases/download/v0.0.20260715/lms-2625.0.0-ubuntu-24.04.deb && \
    apt-get install -y /tmp/lms.deb 
#
# Download and extract the Intel(R) vPro Fleet Services agent
#
# Install is executed via the init.sh script when the container starts
#
RUN wget -O /tmp/agent.tar.gz \
    https://downloadmirror.intel.com/923996/IntelvProFleetServicesAgent-1.2.5-linux-x64.tar.gz && \
    mkdir /agent && tar -zxvf /tmp/agent.tar.gz -C /agent && chmod 755 /agent/IntelvProFleetServicesAgent
#
# Download and extract the remote provisioning client (RPC) from the Device Management ToolKit repository
#
RUN wget -O /tmp/rpc.tar.gz \
    https://github.com/device-management-toolkit/rpc-go/releases/download/v2.52.3/rpc_linux_x64.tar.gz && \
    tar -zxvf /tmp/rpc.tar.gz -C /usr/local/bin && chmod 755 /usr/local/bin/rpc_linux_x64 && \
    ln -s /usr/local/bin/rpc_linux_x64 /usr/local/bin/rpc
#
# Remove temp and unnecessary systemd target items that conflict with containers\
#
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /tmp/*
#
# Copy into and setup some scripts in the container
#
# Add the entry point script and make sure it is executable
#
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh
#
# Add a startup service that executes a script named init.sh
#
# Additional items that need to be launched at startup should be added
# to the /usr/local/bin/init.sh source script and the image rebuilt
#
# Optional: remove init.sh from list of volumes to mount and allow the
#           copied version to execute
#
COPY init.sh /usr/local/bin/init.sh
COPY init-script.service /etc/systemd/system/init-script.service
RUN chmod 755 /usr/local/bin/init.sh \
    && systemctl enable init-script.service
#
# Set entry point script
#
# NOTE: CMD below passes to entrypoint.sh when the last line in script is exec "$@"
#
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#
# Set /sbin/init as the binary that the entry point script executes
#
CMD ["/sbin/init"]
