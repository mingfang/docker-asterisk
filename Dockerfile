FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV TERM xterm
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

# Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

RUN apt-get install -y build-essential
RUN apt-get install -y libncurses5-dev uuid uuid-dev libjansson-dev libxml2-dev sqlite sqlite3 libsqlite3-dev libtool unixodbc unixodbc-dev libasound2-dev libogg-dev libvorbis-dev libneon27-dev libsrtp0-dev libspandsp-dev libmyodbc libgnutls-dev

RUN apt-get install -y linux-headers-`uname -r`

RUN wget -O - http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz | tar zx && \
    cd dahdi* && \
    make -j4 all && \
    make install && \
    make config && \
    rm -rf dahdi*

RUN wget -O - http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.4-current.tar.gz | tar zx && \
    cd libpri* && \
    make -j4 && \
    make install && \
    rm -rf libpri*

RUN wget -O - http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz | tar zx && \
    cd asterisk* && \
    ./configure && \
    make -j4 && \
    make install && \
    make config && \
    make samples && \
    rm -rf asterisk*

RUN cd /var/lib/asterisk/sounds && \
    wget -O - http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz | tar zx && \
    wget -O - http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz | tar zx && \
    wget -O - http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-g722-current.tar.gz | tar zx && \
    wget -O - http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz | tar zx

# Add user asterisk
RUN useradd -m asterisk && \
    mkdir -p /var/log/asterisk && \
    chown -R asterisk. /var/log/asterisk && \
    mkdir -p /var/spool/asterisk && \
    chown -R asterisk. /var/spool/asterisk && \
    chown asterisk. /var/run/asterisk && \
    chown -R asterisk. /etc/asterisk && \
    chown -R asterisk. /var/lib/asterisk && \
    chown -R asterisk. /usr/lib/asterisk

# Add runit services
COPY sv /etc/service 

