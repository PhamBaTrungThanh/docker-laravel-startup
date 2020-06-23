FROM nginx:1.17.8-alpine

LABEL maintainer="Pham Ba Trung Thanh <phambatrungthanh@gmail.com>"

# IMAGE ARGUMENTS WITH DEFAULTS.
ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.9
ARG COMPOSER_HASH=a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1

ARG USER_ID
ARG GROUP_ID

USER root

RUN apk add --update --no-cache curl ca-certificates \
    supervisor \
    shadow \
    rsync \
    sqlite \
    sudo

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
# make sure you can use HTTPS


# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
    echo "@php https://dl.bintray.com/php-alpine/v${ALPINE_VERSION}/php-${PHP_VERSION}" >> /etc/apk/repositories

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update php-fpm@php \
    php@php \
    php-bcmath@php \
    php-curl@php \
    php-exif@php \
    php-pcntl@php \
    php-openssl@php \
    php-pdo@php \
    php-gd@php \
    php-iconv@php \
    php-mysqli@php \
    php-mysqlnd@php \
    php-pdo_mysql@php \
    php-pdo_sqlite@php \
    php-sqlite3@php \
    php-mbstring@php \
    php-phar@php \
    php-session@php \
    php-dom@php \
    php-ctype@php \
    php-zlib@php \
    php-redis@php \
    php-json@php \
    php-posix@php \
    php-xmlreader@php \
    php-zip@php \
    php-zlib@php \
    php-xml@php && \
    ln -s /usr/bin/php7 /usr/bin/php
 
# FIX iconv EXTENSIONS
RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/php7/php.ini

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD start.sh /start.sh
ADD supervisord/supervisord.conf /etc/supervisord.conf
ADD php/php.ini /etc/php7/php.ini
ADD nginx/app.conf /etc/nginx/conf.d/laravel.conf

# IF USER_ID IS SET, RECREATE www-data WITH USER_ID:GROUP_ID
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    if  getent passwd www-data > /dev/null 2>&1 ; then userdel -f www-data; fi &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /home/www-data &&\
    chown --changes --silent --no-dereference --recursive \
    ${USER_ID}:${GROUP_ID} \
    /home/www-data \
    /var/www \
    /var/log/php7 \
    /var/log/nginx/error.log \
    /var/log/nginx/access.log \
    ;fi

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"


RUN composer global require laravel/installer

# SET THE WORK DIRECTORY.
WORKDIR /var/www

RUN laravel new
RUN chmod 755 /start.sh


ENTRYPOINT  ["/start.sh"]
