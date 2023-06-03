FROM ubuntu:focal AS elraro-ubuntu-focal
LABEL maintainer="Elraro (elraro at elraro dot eu)"

### Set defaults
ENV S6_OVERLAY_VERSION=2.2.0.3 \
    DEBUG_MODE=FALSE \
    TIMEZONE=Etc/GMT \
    DEBIAN_FRONTEND=noninteractive \
    ENABLE_CRON=TRUE \
    ENABLE_SMTP=TRUE

### Dependencies addon
RUN set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
            apt-transport-https \
            aptitude \
            bash \
            ca-certificates \
            curl \
            dirmngr \
            dos2unix \
            gnupg \
            less \
            logrotate \
            msmtp \
            nano \
            net-tools \
            netcat-openbsd \
            procps \
            sudo \
            tzdata \
            vim-tiny \
            wget \
            software-properties-common \
            && \
    apt-get update && \
    curl -ksSLo /usr/local/bin/MailHog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_arm && \
    curl -ksSLo /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_arm && \
    chmod +x /usr/local/bin/MailHog && \
    chmod +x /usr/local/bin/mhsendmail && \
    useradd -r -s /bin/false -d /nonexistent mailhog && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /root/.gnupg /var/log/* /etc/logrotate.d && \
    mkdir -p /assets/cron && \
    rm -rf /etc/timezone && \
    ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

### Networking configuration
EXPOSE 1025 8025 10050/TCP

### Add folders
ADD debian-buster/install /


###https://github.com/tiredofit/docker-nodejs/tree/10/debian
FROM elraro-ubuntu-focal AS elraro-nodejs-10-ubuntu-focal
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Environment variables
ENV ENABLE_CRON=FALSE \
    ENABLE_SMTP=FALSE

### Add users
RUN adduser --home /app --gecos "Node User" --disabled-password nodejs && \
\
### Install NodeJS
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y \
            nodejs \
            && \
    \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*



###https://github.com/tiredofit/docker-freepbx
FROM elraro-nodejs-10-ubuntu-focal
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### https://dba.stackexchange.com/questions/316286/mongodb-install-on-arm
### OMG!
### Set defaults
ENV ASTERISK_VERSION=18.17.1 \
    BCG729_VERSION=1.1.1 \
    PHP_VERSION=7.4 \
    SPANDSP_VERSION=20180108 \
    RTP_START=18000 \
    RTP_FINISH=20000

### Pin libxml2 packages to Debian repositories
RUN c_rehash && \
### Install dependencies
    set -x && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y

### Install development dependencies
RUN set -x && \
    ASTERISK_BUILD_DEPS='\
                        autoconf \
                        automake \
                        bison \
                        binutils-dev \
                        build-essential \
                        doxygen \
                        flex \
                        graphviz \
                        libasound2-dev \
                        libbluetooth-dev \
                        libc-client2007e-dev \
                        libcfg-dev \
                        libcodec2-dev \
                        libcorosync-common-dev \
                        libcpg-dev \
                        libcurl4-openssl-dev \
                        libedit-dev \
                        libfftw3-dev \
                        libgmime-2.6-dev \
                        libgsm1-dev \
                        libical-dev \
                        libiksemel-dev \
                        libjansson-dev \
                        libldap2-dev \
                        liblua5.2-dev \
                        libmariadb-dev \
                        libmariadbclient-dev \
                        libmp3lame-dev \
                        libncurses5-dev \
                        libneon27-dev \
                        libnewt-dev \
                        libogg-dev \
                        libopus-dev \
                        libosptk-dev \
                        libpopt-dev \
                        libradcli-dev \
                        libresample1-dev \
                        libsndfile1-dev \
                        libsnmp-dev \
                        libspeex-dev \
                        libspeexdsp-dev \
                        libsqlite3-dev \
                        libsrtp2-dev \
                        libssl-dev \
                        libtiff-dev \
                        libtool-bin \
                        libunbound-dev \
                        liburiparser-dev \
                        libvorbis-dev \
                        libvpb-dev \
                        libxml2-dev \
                        libxslt1-dev \
                        linux-headers-raspi \
                        portaudio19-dev \
                        python-dev \
                        subversion \
                        unixodbc-dev \
                        uuid-dev \
                        zlib1g-dev' && \
### Install runtime dependencies
    apt-get install --no-install-recommends -y \
                    $ASTERISK_BUILD_DEPS \
                    apache2 \
                    composer \
                    fail2ban \
                    ffmpeg \
                    flite \
                    freetds-dev \
                    git \
                    g++ \
                    iptables \
                    lame \
                    libavahi-client3 \
                    libbluetooth3 \
                    libc-client2007e \
                    libcfg7 \
                    libcpg4 \
                    libgmime-2.6 \
                    libical3 \
                    libiodbc2 \
                    libiksemel3 \
                    libicu66 \
                    libicu-dev \
                    libneon27 \
                    libosptk4 \
                    libresample1 \
                    libsnmp35 \
                    libspeexdsp1 \
                    libsrtp2-1 \
                    libunbound8 \
                    liburiparser1 \
                    libvpb1 \
                    locales \
                    locales-all \
                    make \
                    cmake \
                    gcc \
                    mariadb-client \
                    mariadb-server \
                    mpg123 \
                    php${PHP_VERSION} \
                    php${PHP_VERSION}-curl \
                    php${PHP_VERSION}-cli \
                    php${PHP_VERSION}-mysql \
                    php${PHP_VERSION}-gd \
                    php${PHP_VERSION}-mbstring \
                    php${PHP_VERSION}-intl \
                    php${PHP_VERSION}-bcmath \
                    php${PHP_VERSION}-ldap \
                    php${PHP_VERSION}-xml \
                    php${PHP_VERSION}-zip \
                    php${PHP_VERSION}-sqlite3 \
                    php-pear \
                    pkg-config \
                    sipsak \
                    sngrep \
                    socat \
                    sox \
                    sqlite3 \
                    tcpdump \
                    tcpflow \
                    unixodbc \
                    uuid \
                    wget \
                    whois \
                    xmlstarlet

### Add users
RUN set -x && \
    addgroup --gid 2600 asterisk && \
    adduser --uid 2600 --gid 2600 --gecos "Asterisk User" --disabled-password asterisk

### Build MariaDB connector
RUN set -x && \
    cd /usr/src && \
    git clone https://github.com/MariaDB/mariadb-connector-odbc.git && \
    cd mariadb-connector-odbc && \
    git checkout tags/3.1.18 && \
    mkdir build && \
    cd build && \
    cmake ../ -LH -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_SSL=OPENSSL && \
    cmake --build . --config Release && \
    make install

### Build SpanDSP
RUN set -x && \
    mkdir -p /usr/src/spandsp && \
    curl -kL http://sources.buildroot.net/spandsp/spandsp-${SPANDSP_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/spandsp && \
    cd /usr/src/spandsp && \
    ./configure --prefix=/usr && \
    make && \
    make install

### Build Asterisk
RUN set -x && \
    cd /usr/src && \
    mkdir -p asterisk && \
    curl -sSL http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk && \
    cd /usr/src/asterisk/ && \
    make distclean && \
    contrib/scripts/get_mp3_source.sh && \
    cd /usr/src/asterisk && \
    ./configure \
        --with-jansson-bundled \
        --with-pjproject-bundled \
        --with-bluetooth \
        --with-codec2 \
        --with-crypto \
        --with-gmime \
        --with-iconv \
        --with-iksemel \
        --with-inotify \
        --with-ldap \
        --with-libxml2 \
        --with-libxslt \
        --with-lua \
        --with-ogg \
        --with-opus \
        --with-resample \
        --with-spandsp \
        --with-speex \
        --with-sqlite3 \
        --with-srtp \
        --with-unixodbc \
        --with-uriparser \
        --with-vorbis \
        --with-vpb \
        && \
    \
    make menuselect/menuselect menuselect-tree menuselect.makeopts && \
    menuselect/menuselect --disable BUILD_NATIVE \
                          --enable-category MENUSELECT_ADDONS \
                          --enable-category MENUSELECT_APPS \
                          --enable-category MENUSELECT_CHANNELS \
                          --enable-category MENUSELECT_CODECS \
                          --enable-category MENUSELECT_FORMATS \
                          --enable-category MENUSELECT_FUNCS \
                          --enable-category MENUSELECT_RES \
                          --enable BETTER_BACKTRACES \
                          --disable MOH-OPSOUND-WAV \
                          --enable MOH-OPSOUND-GSM \
                          --disable app_voicemail_imap \
                          --disable app_voicemail_odbc \
                          --disable res_digium_phone \
                          --disable codec_g729a && \
    make && \
    make install && \
    make install-headers && \
    make config

#### Add G729 codecs
RUN set -x && \
    git clone https://github.com/BelledonneCommunications/bcg729 /usr/src/bcg729 && \
    cd /usr/src/bcg729 && \
    git checkout tags/$BCG729_VERSION && \
    cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/lib && \
    make && \
    make install

RUN set -x && \
    mkdir -p /usr/src/asterisk-g72x && \
    curl https://bitbucket.org/arkadi/asterisk-g72x/get/master.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk-g72x && \
    cd /usr/src/asterisk-g72x && \
    ./autogen.sh && \
    ./configure --prefix=/usr --with-bcg729 && \
    make && \
    make install

### Cleanup
RUN set -x && \
    mkdir -p /var/run/fail2ban && \
    cd / && \
    rm -rf /usr/src/* /tmp/* /etc/cron* && \
    apt-get purge -y $ASTERISK_BUILD_DEPS && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

### FreePBX hacks
RUN set -x && \
    sed -i -e "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    a2disconf other-vhosts-access-log.conf && \
    a2enmod rewrite && \
    a2enmod headers && \
    rm -rf /var/log/* && \
    mkdir -p /var/log/asterisk && \
    mkdir -p /var/log/apache2 && \
    mkdir -p /var/log/httpd

### Setup for data persistence
RUN set -x && \
    mkdir -p /assets/config/var/lib/ /assets/config/home/ && \
    mv /home/asterisk /assets/config/home/ && \
    ln -s /data/home/asterisk /home/asterisk && \
    mv /var/lib/asterisk /assets/config/var/lib/ && \
    ln -s /data/var/lib/asterisk /var/lib/asterisk && \
    ln -s /data/usr/local/fop2 /usr/local/fop2 && \
    mkdir -p /assets/config/var/run/ && \
    mv /var/run/asterisk /assets/config/var/run/ && \
    mv /var/lib/mysql /assets/config/var/lib/ && \
    mkdir -p /assets/config/var/spool && \
    mv /var/spool/cron /assets/config/var/spool/ && \
    ln -s /data/var/spool/cron /var/spool/cron && \
    ln -s /data/var/run/asterisk /var/run/asterisk && \
    rm -rf /var/spool/asterisk && \
    ln -s /data/var/spool/asterisk /var/spool/asterisk && \
    rm -rf /etc/asterisk && \
    ln -s /data/etc/asterisk /etc/asterisk

### Networking configuration
EXPOSE 80 443 4445 4569 5060/udp 5160/udp 5061 5161 8001 8003 8008 8009 8025 ${RTP_START}-${RTP_FINISH}/udp

### Files add
ADD freepbx-15/install /

#S6 installation
RUN set -x && \
    curl -ksSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.gz | tar xfz - -C / && \
    ln -s /usr/bin/sh /bin/sh && \
    ln -s /usr/bin/bash /bin/bash

### Entrypoint configuration
ENTRYPOINT ["/init"]
