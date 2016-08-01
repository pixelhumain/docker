FROM php:5.5

# PHP extensions come first, as they are less likely to change between Yii releases
RUN apt-get update \
    && apt-get -y install \
            g++ \
            libicu-dev \
            libmcrypt-dev \
            zlib1g-dev \
            php5-dev \
        --no-install-recommends \


    # Install PHP extensions
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install zip \
    && pecl install mongodb \
    && echo extension=mongo.so > /usr/local/etc/php/php.ini \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \

    && apt-get purge -y g++ \
    && apt-get autoremove -y \
    && rm -r /var/lib/apt/lists/* 


WORKDIR /code

CMD [ "php", "-S 127.0.0.1:8888" ]

