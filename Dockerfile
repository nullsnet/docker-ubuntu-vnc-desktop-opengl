FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

# nvidia driver dependencies / x11
RUN apt-get update -qq &&\
    apt-get install -qqy \
                    dbus-x11 \
                    x11vnc \
                    openbox \
                    novnc \
                    websockify \
                    supervisor \
                    at-spi2-core \
                    xorg \
                    pkg-config \
                    libglvnd-dev \
                    kmod \
                    curl \
                    ca-certificates \
                    gnupg \
                    --no-install-recommends &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# nvidia driver
ARG DRIVER_VERSION=470.57.02
RUN curl -fSsl -O https://us.download.nvidia.com/tesla/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run &&\
    sh NVIDIA-Linux-x86_64-$DRIVER_VERSION.run -x && \
    cd NVIDIA-Linux-x86_64-$DRIVER_VERSION && \
    ./nvidia-installer  --silent \
                        --no-kernel-module \
                        --install-compat32-libs \
                        --no-nouveau-check \
                        --no-nvidia-modprobe \
                        --no-rpms \
                        --no-backup \
                        --no-check-for-alternate-installs \
                        --no-libglx-indirect \
                        --no-install-libglvnd &&\
    cd ../ &&\
    rm -rf NVIDIA-Linux-x86_64-$DRIVER_VERSION NVIDIA-Linux-x86_64-$DRIVER_VERSION.run

# chrome dependencies
RUN apt-get update -qq &&\
    apt-get install -qqy \
                    fonts-ipafont \
                    fonts-ipaexfont \
                    fonts-liberation \
                    wget \
                    xdg-utils \
                    libnss3 \
                    libasound2 \
                    libnspr4 \
                    libsnmp35 \
                    libsnmp-base \
                    --no-install-recommends &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# chrome
RUN curl -fSsl -O  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&\
    apt-get install -qqy ./google-chrome-stable_current_amd64.deb &&\
    rm google-chrome-stable_current_amd64.deb

ENV DISPLAY=:0

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["bash", "/entrypoint.sh"]
