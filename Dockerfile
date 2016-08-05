FROM nginx

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install packages
RUN apt-get update && apt-get install -my \
  curl \
  supervisor \
  wget \
  php5-curl \
  php5-fpm \
  php5-gd \
  php5-memcached \
  php5-mysql \
  php5-mcrypt \
  php5-sqlite \
  php5-xdebug \
  php5-mongo \
  php-apc
  
# * Ensure that PHP5 FPM is run as root.
# * Pass all docker environment
# * Get access to FPM-ping page /ping
# * Get access to FPM_Status page /status
# * Prevent PHP Warning: 'xdebug' already loaded.
# * XDebug loaded with the core
RUN sed -i "s/user = www-data/user = root/" /etc/php5/fpm/pool.d/www.conf && \
sed -i "s/group = www-data/group = root/" /etc/php5/fpm/pool.d/www.conf && \
sed -i '/^;clear_env = no/s/^;//' /etc/php5/fpm/pool.d/www.conf && \
sed -i '/^;ping\.path/s/^;//' /etc/php5/fpm/pool.d/www.conf && \
sed -i '/^;pm\.status_path/s/^;//' /etc/php5/fpm/pool.d/www.conf && \
sed -i '/.*xdebug.so$/s/^/;/' /etc/php5/mods-available/xdebug.ini

# Add configuration files
COPY front-conf/nginx.conf /etc/nginx/
COPY front-conf/supervisord.conf /etc/supervisor/conf.d/
COPY front-conf/php.ini /etc/php5/fpm/conf.d/40-custom.ini
COPY front-conf/communecter.conf /etc/nginx/conf.d/

EXPOSE 80 443 9000

ENTRYPOINT ["/usr/bin/supervisord"]
