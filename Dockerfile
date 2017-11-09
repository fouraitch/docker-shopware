FROM php:5.6-apache

ENV TERM xterm-256color

RUN echo 'Default index.html from docker image' > /var/www/html/index.html

RUN a2enmod rewrite

# general php setup
COPY files/php.ini /usr/local/etc/php/conf.d/php.ini

# install ioncube
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && mv ioncube_loaders_lin_x86-64.tar.gz /tmp/ && tar xvzfC /tmp/ioncube_loaders_lin_x86-64.tar.gz /tmp/ \
    && rm /tmp/ioncube_loaders_lin_x86-64.tar.gz \
    && mkdir -p /usr/local/ioncube \
    && cp /tmp/ioncube/ioncube_loader_lin_5.6.so /usr/local/ioncube \
    && rm -rf /tmp/ioncube
COPY files/00-ioncube.ini /usr/local/etc/php/conf.d/00-ioncube.ini

# install acpu
RUN pecl install apcu-4.0.11 \
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/10-apcu.ini

# install zendopcache
RUN docker-php-ext-enable opcache.so

# mysql driver
RUN docker-php-ext-install pdo_mysql

# to be capatible with production
RUN ln -s /usr/local/bin/php /usr/local/bin/php_cli

# install composer
RUN apt-get update && apt-get install -y zlib1g-dev libpng-dev && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN docker-php-ext-install zip gd
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

# enable mod proxy to forward requests to tgm
RUN a2enmod proxy proxy_http proxy_balancer ssl

RUN chown -R www-data /var/www/html