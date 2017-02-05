FROM ubuntu:xenial
MAINTAINER Tom Christopoulos <tom.philly@gmail.com>

EXPOSE 179
ENV BUILD_PACKAGES="gcc autoconf automake build-essential gawk git libreadline-dev libtool make texinfo"
RUN apt-get update && apt-get install -y $BUILD_PACKAGES && \
    git clone https://github.com/tomchris/quagga-ldpd.git && \ 
    cd quagga-ldpd && \
    ./bootstrap.sh && \
    ./configure --enable-tcp-zebra \
                   --enable-mpls \
                   --enable-ldpd \
                   --sysconfdir=/etc/quagga \ 
                   --localstatedir=/var/run/quagga && \
    make && \
    make install && \
    ldconfig /usr/local/lib && \
    useradd -M quagga && \
    mkdir -p /etc/quagga && \
    mkdir -p /var/run/quagga && \
    chown quagga /etc/quagga && \
    chown quagga /var/run/quagga && \
    touch /var/run/zebra.pid && \
    chmod 755 /var/run/zebra.pid && \
    chown quagga.quagga /var/run/zebra.pid && \
    touch /var/run/ldpd.pid && \
    chmod 755 /var/run/ldpd.pid && \
    chown quagga.quagga /var/run/ldpd.pid && \
    touch /var/run/ldpd.vty && \
    chmod 755 /var/run/ldpd.vty && \
    chown quagga.quagga /var/run/ldpd.vty && \
    chmod 777 /var/run && \
    cp ./zebra/zebra.conf.sample /etc/quagga/zebra.conf && \
    cp ./ldpd/ldpd.conf.sample /etc/quagga/ldpd.conf && \
    apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD zebra -d -f /etc/quagga/zebra.conf && \
    ldpd -d -f /etc/quagga/ldpd.conf && \
    /bin/bash