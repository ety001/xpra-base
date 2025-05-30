FROM debian:bookworm-slim

ARG REPOFILE=https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/bookworm/xpra-lts.sources

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y ca-certificates wget gpg openssh-server supervisor vim sudo && \
    wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    cd /etc/apt/sources.list.d && wget $REPOFILE && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y xserver-xorg xpra && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

ADD ./sshd.conf /etc/supervisor/conf.d/sshd.conf

RUN useradd -m -s /bin/bash lzc && \
    usermod -aG sudo lzc && \
    echo "lzc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/lzc/.ssh && chown lzc:lzc /home/lzc/.ssh && \
    touch /home/lzc/.ssh/authorized_keys && chown lzc:lzc /home/lzc/.ssh/authorized_keys && \
    chmod 700 /home/lzc/.ssh

EXPOSE 22
USER lzc
VOLUME ["/home/lzc/.ssh"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
