FROM ubuntu:22.04

ARG REPOFILE=https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra-lts.sources
ARG VIRTUAL_GL=https://github.com/VirtualGL/virtualgl/releases/download/3.1.3/virtualgl_3.1.3_amd64.deb
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update -y && \
    apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates wget gpg \
        openssh-server supervisor vim sudo tzdata && \
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    cd /etc/apt/sources.list.d && wget $REPOFILE && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y xserver-xorg xpra \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools \
        gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
        gstreamer1.0-qt5 gstreamer1.0-pulseaudio intel-media-va-driver-non-free \
        libva-dev vainfo && \
    wget -O "/tmp/virtualgl.deb" $VIRTUAL_GL && \
    dpkg -i /tmp/virtualgl.deb && \
    rm -f /tmp/virtualgl.deb && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

COPY ./supervisor/*.conf /etc/supervisor/conf.d/

RUN useradd -m -s /bin/bash lzc && \
    usermod -aG sudo,audio,video,games,users,xpra,pulse,pulse-access lzc && \
    echo "lzc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/lzc/.ssh && chown lzc:lzc /home/lzc/.ssh && \
    touch /home/lzc/.ssh/authorized_keys && chown lzc:lzc /home/lzc/.ssh/authorized_keys && \
    chmod 700 /home/lzc/.ssh && \
    mkdir -p /run/user && chmod 777 /run/user && \
    mkdir -p /run/xpra && chmod 777 /run/xpra && \
    mkdir -p /run/dbus

EXPOSE 22
USER lzc
WORKDIR /home/lzc
VOLUME ["/home/lzc/.ssh"]

CMD ["sudo", "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]