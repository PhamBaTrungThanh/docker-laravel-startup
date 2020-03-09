#!/bin/sh
#INITIALIZE LARAVEL
if [ ! -d "/var/www/vendor" ]; then \
    echo "BEGIN INITIALIZE LARAVEL, PLEASE WAIT"
    echo "========================================================"
    rm -rf .git
    composer create-project --prefer-dist laravel/laravel /var/laravel-www
    rsync -a --exclude '.git' /var/laravel-www/ /var/www
    php /var/www/artisan storage:link
    sed -i 's/# //g' docker-compose.yml
    sed -i 's/APP_URL=http:\/\/localhost/APP_HOST=\nAPP_PORT=\nAPP_URL="http:\/\/${APP_HOST}:${APP_PORT}"/g' .env
    sed -i 's/REDIS_HOST=127\.0\.0\.1/REDIS_HOST=redis/g' .env
    sed -i 's/DB_HOST=127\.0\.0\.1/DB_HOST=db/g' .env
    sed -i 's/DB_USERNAME=root/DB_USERNAME=homestead/g' .env
    sed -i 's/DB_PASSWORD=/DB_PASSWORD=secret/g' .env
    echo "INIT COMPLETE, PLEASE EDIT .env FILE AND RUN 'make start' TO START."
else
    # SYMLINK CONFIGURATION FILES.
    ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini
    # PRODUCTION LEVEL CONFIGURATION.
    if [[ "${PRODUCTION}" == "1" ]]; then
        sed -i -e "s/;log_level = notice/log_level = warning/g" /etc/php7/php-fpm.conf
        sed -i -e "s/clear_env = no/clear_env = yes/g" /etc/php7/php-fpm.d/www.conf
        sed -i -e "s/display_errors = On/display_errors = Off/g" /etc/php7/php.ini
    else
        sed -i -e "s/;log_level = notice/log_level = notice/g" /etc/php7/php-fpm.conf
        sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf
    fi

    # PHP & SERVER CONFIGURATIONS.
    if [[ ! -z "${PHP_MEMORY_LIMIT}" ]]; then
        sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}M/g" /etc/php7/conf.d/php.ini
    fi

    if [ ! -z "${PHP_POST_MAX_SIZE}" ]; then
        sed -i "s/post_max_size = 50M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php7/conf.d/php.ini
    fi

    if [ ! -z "${PHP_UPLOAD_MAX_FILESIZE}" ]; then
        sed -i "s/upload_max_filesize = 10M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php7/conf.d/php.ini
    fi


    find /etc/php7/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

    # START SUPERVISOR.
    exec /usr/bin/supervisord -n -c /etc/supervisord.conf
fi
