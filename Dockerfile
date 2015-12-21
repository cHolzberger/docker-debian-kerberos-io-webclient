FROM mosaiksoftware/debian
MAINTAINER  Chrisitan Holzberger <ch@mosaiksoftware.de>

##### START CUSTOM SCRIPT####
RUN apt-get update && apt-get install	-y apt-transport-https curl
COPY config/source.list /etc/apt/sources.list

RUN	curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - 
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449

RUN set-selections php5

# Web Interface
COPY ./kerberos-web /var/www
COPY composer.phar /
RUN cd /var/www && rm .git && php /composer.phar install && chmod -R 777 /var/www && \
	cd /var/www/public &&  npm -g install bower && bower --allow-root install

# supervisor config

COPY ./config/supervisord.conf /etc/supervisord.conf
COPY ./config/nginx-default /etc/nginx/sites-enabled/default
COPY ./config/kerberos-app.php /var/www/app/config/app.php
EXPOSE 80
VOLUME /var/www/public/capture/

# allow easy config file additions to php-fpm.conf
CMD exec /usr/bin/supervisord -n -c /etc/supervisord.conf
