# Laravel Docker Container

This docker image for developing Laravel applications and is based on tutum/apache-php. Note that the container is not meant/vetted for production.

## Usage

The default command starts an instance of the apache web server, which serves the project mounted at /app. However, this is typically not altogether that useful without a database. So, for demonstration purposes, let's assume you are running a plain-jane MySQL database. For example:

```bash
# Start the MySQL Instance
docker run -v $PWD/mysql:/var/lib/mysql -e MYSQL_PASS=supersecretpassword -d -p 3306:3306 --name laravel-mysql tutum/mysql

# Start the Apache Server
docker run -h development --name laravel-apache -d -p 80:80 -v $PWD/app --link laravel-mysql:db laravel
```

## Fancy Features: Composer, Artisan & PHPUnit

In addition to the typical Apache server, this container also has Composer, Artisan, and PHPUnit at-the-ready. (I know, I know, this violates the "one process/task" per container principle. But, we needed composer anyways. Artisan is already there. And, adding PHPUnit means one less image junking up your `/var/lib/docker` folder and/or `/` or `/var` partition). So, here are some more examples:

```bash
# Composer
docker run -h development \ 
           --name laravel-composer \
           -u usernamehereplz \
           --rm -it \
           --entrypoint /usr/local/bin/composer \
           --link laravel-mysql:db \
           -v $PWD:/app \
           laravel
                 # ^ composer args go here at the end

# Artisan
docker run -h development \ 
           --name laravel-artisan \
           -u usernamehereplz \
           --rm -it \
           --entrypoint /usr/bin/php \
           --link laravel-mysql:db \
           -v $PWD:/app \
           laravel artisan
           # artisan args  ^ here at the end

# PHPUnit
docker run -h testing \
           --name laravel-phpunit \
           -u usernamehereplz \
           --rm -it \
           --entrypoint /usr/local/bin/phpunit \
           --link laravel-mysql:db \
           -v $PWD:/app \
           laravel
                 # ^ phpunit args go here at the end
```

## Get the Image

To build this image yourself, run...
 
```bash
docker build github.com/niaquinto/docker-laravel
```

Or, you can pull the image from the central docker repository by using... 
 
```bash
docker pull niaquinto/laravel
```
