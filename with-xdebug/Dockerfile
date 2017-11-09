FROM fouraitch/docker-shopware:5.2

# setup xdebug
RUN pecl install xdebug-2.5.0
COPY files/20-xdebug.ini /usr/local/etc/php/conf.d/20-xdebug.ini
COPY files/00-ioncube.ini /usr/local/etc/php/conf.d/00-ioncube.ini