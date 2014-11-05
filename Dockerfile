FROM tutum/apache-php
MAINTAINER Nicholas Iaquinto <nickiaq@gmail.com>

# In case someone loses the Dockerfile
RUN rm -rf /etc/Dockerfile
ADD Dockerfile /etc/Dockerfile

# Add altered apache vhost (uses /app/public as root instead of /app)
RUN rm -rf /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN ln /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Enable neccessary existing extensions and increase upload size
RUN a2enmod rewrite && \
    sed -i.bak 's/upload_max_filesize = 2M/upload_max_filesize = 15M/g' /etc/php5/apache2/php.ini && \
    sed -i.bak 's/post_max_size = 8M/post_max_size = 15M/g' /etc/php5/apache2/php.ini
    
# Install neccessary php extensions and apc
RUN apt-get update && \
    apt-get install -y php5-curl php5-memcache memcached php-pear build-essential php5-tidy php5-curl apache2-dev php5-mcrypt php5-json git-core && apt-get clean && \
    pecl install apc && \
    echo 'extension=apc.so' >> /etc/php5/apache2/php.ini && \
    echo 'extension=memcache.so' >> /etc/php5/apache2/php.ini && \
    a2enmod expires && \
    a2enmod headers && \
    php5enmod mcrypt

# Install Composer
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && \
    mv /tmp/composer.phar /usr/local/bin/composer

# Install PHPUnit
RUN cd /tmp && curl https://phar.phpunit.de/phpunit.phar > phpunit.phar && \
    chmod +x phpunit.phar && \
    mv /tmp/phpunit.phar /usr/local/bin/phpunit

# Add normal user to get rid of pesky file ownership problems
RUN groupadd niaquinto && useradd -g niaquinto niaquinto && \
    sed -i.back 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=niaquinto/g' /etc/apache2/envvars && \
    sed -i.back 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=niaquinto/g' /etc/apache2/envvars

ENV LARAVEL_ENV development

EXPOSE 80
CMD /run.sh
