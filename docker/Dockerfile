# Rory Schram's docker image for UHD library for USRP control

FROM        ubuntu:20.04
USER        root


# This will make apt-get install without question
ARG         DEBIAN_FRONTEND=noninteractive
ARG         UHD_TAG=v4.8.0.0
ARG         MAKEWIDTH=2

# Install security updates and required packages
RUN         apt-get update
# Install UHD dependencies
RUN apt-get -y install autoconf \
        automake \
        build-essential \
        ccache \
        cmake \
        cpufrequtils \
        doxygen \
        ethtool \
        g++ \
        git \
        inetutils-tools \
        libboost-all-dev \
        libncurses5 \
        libncurses5-dev \
        libusb-1.0-0 \
        libusb-1.0-0-dev \
        libusb-dev \
        python3-dev \
        python3-mako \
        python3-numpy \
        python3-requests \
        python3-scipy \
        python3-setuptools \
        python3-ruamel.yaml \
        sudo

RUN          rm -rf /var/lib/apt/lists/*

RUN          mkdir -p /usr/local/src
RUN          git clone https://github.com/EttusResearch/uhd.git /usr/local/src/uhd
RUN          cd /usr/local/src/uhd/ && git checkout $UHD_TAG
RUN          mkdir -p /usr/local/src/uhd/host/build
WORKDIR      /usr/local/src/uhd/host/build
RUN          cmake .. -DNEON_SIMD_ENABLE=OFF -DENABLE_PYTHON3=ON -DUHD_RELEASE_MODE=release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_FIND_ROOT_PATH=/usr
RUN          make -j $MAKEWIDTH
RUN          make install
RUN          uhd_images_downloader

# Set the root user's password (replace 'yourpassword' with a secure password)
RUN echo "root:root" | chpasswd

# Grant root user sudo privileges (already has full privileges in most cases)
RUN echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Create a new user (replace 'newuser' with your preferred username)

RUN useradd -m -s /bin/bash usrp && \
    echo "usrp:usrp" | chpasswd && \
    usermod -aG sudo usrp

# Set the new user to have passwordless sudo privileges (optional)
RUN echo "usrp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user (if needed)
USER usrp
WORKDIR /home/usrp

