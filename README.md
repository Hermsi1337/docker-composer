# Make your composer fly on Alpine

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
* mcrypt (< php7.2)

## Basic Usage
This Image is intended to be used as an replacement for composer.

I recommend to create a file named `composer` somwhere in your `$PATH`.
If you want to do it like me, do it like that:
   1. Create a file in `/usr/local/bin` which provides the `composer`-command with the following content:
        `$ vim /usr/local/bin/composer`
        ```bash
        #!/bin/bash

        composer () {
            tty=
            tty -s && tty=--tty
            docker run \
                $tty \
                --interactive \
                --rm \
                --user $(id -u):$(id -g) \
                --volume /etc/passwd:/etc/passwd:ro \
                --volume /etc/group:/etc/group:ro \
                --volume $(pwd):/app \
                hermsi/alpine-composer:php7.1 "$@"
        }

        composer $@
        ```
   2. Make that file executable:
        `$ chmod +x /usr/local/bin/composer`
   3. Set `UID` for executing the file as `root` without password-prompt. As you know, without `root` no `docker run`:
        `$ sudo chmod u+s /usr/local/bin/composer`

After that you should be able to use `composer`-command directly in your shell.
Also, you are able to set up composer in your desired IDE like PhpStorm.


Alternatively you can create an alias in your `.bashrc` or `.zshrc`:

```bash
composer () {
    tty=
    tty -s && tty=--tty
    docker run \
        $tty \
        --interactive \
        --rm \
        --user $(id -u):$(id -g) \
        --volume /etc/passwd:/etc/passwd:ro \
        --volume /etc/group:/etc/group:ro \
        --volume $(pwd):/app \
        hermsi/alpine-composer:7.1 $@
}
```