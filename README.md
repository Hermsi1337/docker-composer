# Make your composer fly on Alpine

[![Build Status](https://travis-ci.com/Hermsi1337/docker-composer.svg?branch=master)](https://travis-ci.com/Hermsi1337/docker-composer)

## Overview
This is a Dockerfile/image to build a container for [composer](https://getcomposer.org/) based on PHP 7.1 or 7.2.
Most of the regular needed modules (apcu, opcache, php-redis, etc.) are built in and configured like suggested on [php.net](https://secure.php.net/).<br>

## Features
* intl
* zip
* soap
* mysqli
* pdo
* pdo_mysql
* pdo_pgsql
* mcrypt
* gd
* iconv
* xsl
* bcmath
* gmp
* php-redis
* memcached
* opcache ([configuration reference](https://secure.php.net/manual/en/opcache.installation.php))
* apcu ([configuration reference](https://secure.php.net/manual/en/apcu.configuration.php))
* imagick
* ssh2
* ioncube
* mcrypt (< php7.2)

## Basic Usage
This Image is intended to be used as an replacement for composer.

I recommend to create a file named `composer-docker` somwhere in your `$PATH`.
If you want to do it like me, do it like that:
   1. Create a file in `/usr/local/bin` which provides the `composer`-command with the following content:
        `$ vim /usr/local/bin/composer-docker`
        ```bash
        #!/bin/bash

        composer () {
            tty=
            tty -s && tty=--tty
            docker run \
                $tty \
                --interactive \
                --rm \
                --user "$(id -u)":"$(id -g)" \
                --volume /etc/passwd:/etc/passwd:ro \
                --volume /etc/group:/etc/group:ro \
                --volume "$(pwd)":/app \
                hermsi/alpine-composer "$@"
        }

        composer "$@"
        ```
   2. Create an alias in your `.bashrc` or `.zshrc`:
        `$ alias "composer"="sudo bash /usr/local/bin/composer-docker"`
 
After that you should be able to use `composer`-command directly in your shell.

## Versions and Tags
This image is currently available with PHP 7.1 and PHP 7.2.
Depending on your application you may want to change the image to use in your `composer-function`
* `hermsi/alpine-composer:php7.2`, `hermsi/alpine-composer:latest`
* `hermsi/alpine-composer:php7.1`
