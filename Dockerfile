ARG         PHP_VERSION=${PHP_VERSION:-7.3}
FROM        hermsi/alpine-fpm-php:${PHP_VERSION}

LABEL       maintainer="https://github.com/hermsi1337"

ARG         COMPOSER_VERSION=${COMPOSER_VERSION:-1.9.1}
ENV         COMPOSER_HOME=/tmp \
            COMPOSER_ALLOW_SUPERUSER=1 \
            COMPOSER_VERSION=${COMPOSER_VERSION} \
            COMPOSER_INSTALLER_URL=https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer

COPY        --from=composer /docker-entrypoint.sh /docker-entrypoint.sh

RUN         apk add --no-cache bash \
            && \
            wget -O /tmp/installer.php ${COMPOSER_INSTALLER_URL} \
            && \
            php -r " \
                \$signature = '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5'; \
                \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
                if (!hash_equals(\$signature, \$hash)) { \
                    unlink('/tmp/installer.php'); \
                    echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
                    exit(1); \
                }" \
            && \
            php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version="${COMPOSER_VERSION}" \
            && \
            printf "# composer php cli ini settings\n\
                    date.timezone=UTC\n\
                    memory_limit=-1\n" \
            > "${PHP_INI_DIR}/php-cli.ini" \
            && \
            composer --ansi --version --no-interaction \
            && \
            rm -rf /tmp/* /var/cache/apk/* \
            && \
            find /tmp -type d -exec chmod -v 1777 {} +

WORKDIR     /app

ENTRYPOINT  ["/docker-entrypoint.sh"]
CMD         ["composer"]