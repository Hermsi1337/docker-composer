#!/usr/bin/env bash

set -e

LATEST="1.8"
STABLE="1.8"
README_URL="https://getcomposer.org/download/"

PHP_VERSIONS=("7.3" "7.2" "7.1")

DIRECTORIES=($(find "${TRAVIS_BUILD_DIR}" -maxdepth 1 -mindepth 1 -type d -name "php*" -o -name "conf.d" | sed -e 's#.*\/\(\)#\1#' | sort))

docker_push() {

    unset IMAGE
    IMAGE="${1}"

    echo "# Pushing tag: ${IMAGE##*:}"
    docker push "${IMAGE}" 1>/dev/null

}

unset PATCH_RELEASE_TAG
PATCH_RELEASE_TAG="$(w3m -dump 'https://getcomposer.org/download/' | grep -i 'Latest:' | awk '{print $4}')"
PATCH_RELEASE_TAG="${PATCH_RELEASE_TAG##v}"

unset MINOR_RELEASE_TAG
MINOR_RELEASE_TAG="${PATCH_RELEASE_TAG%.*}"

unset MAJOR_RELEASE_TAG
MAJOR_RELEASE_TAG="${MINOR_RELEASE_TAG%.*}"

unset STABLE_RELEASE_TAG
STABLE_RELEASE_TAG="stable"

unset LATEST_RELEASE_TAG
LATEST_RELEASE_TAG="latest"

echo "# # # # # # # # # # # # # # # # # #"

for PHP_VERSION in ${PHP_VERSIONS[@]}; do
    FULL_PHP_VERSION="$(w3m -dump "http://php.net/downloads.php" | grep -i "${PHP_VERSION}" | grep -i "changelog" | awk '{print $4}')"

    unset PHP_MINOR_RELEASE_TAG
    PHP_MINOR_RELEASE_TAG="${FULL_PHP_VERSION%.*}"

    unset PHP_MAJOR_RELEASE_TAG
    PHP_MAJOR_RELEASE_TAG="${FULL_PHP_VERSION%.*}"

    echo "# Building ..."
    echo "# ... Composer-Version: ${PATCH_RELEASE_TAG}"
    echo "# ... PHP-Version: ${FULL_PHP_VERSION}"

    docker build \
        --quiet \
        --no-cache \
        --pull \
        --build-arg PHP_VERSION="${FULL_PHP_VERSION}" \
        --build-arg COMPOSER_VERSION="${PATCH_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${LATEST_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${FULL_PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${STABLE_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${FULL_PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${FULL_PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${FULL_PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${PATCH_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${FULL_PHP_VERSION}" \
        --tag "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}" \
        --tag "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}" \
        --file "${TRAVIS_BUILD_DIR}/Dockerfile" \
        "${TRAVIS_BUILD_DIR}" 1>/dev/null

    if [[ "${TRAVIS_BRANCH}" == "master" ]] && [[ "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
        if [[ "${MINOR_RELEASE_TAG}" == "${STABLE}" ]]; then
            docker_push "${IMAGE_NAME}:${STABLE_RELEASE_TAG}"
            docker_push "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${FULL_PHP_VERSION}"
            docker_push "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}"
            docker_push "${IMAGE_NAME}:${STABLE_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}"
        fi

        if [[ "${MINOR_RELEASE_TAG}" == "${LATEST}" ]]; then
            docker_push "${IMAGE_NAME}:${LATEST_RELEASE_TAG}"
            docker_push "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${FULL_PHP_VERSION}"
            docker_push "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}"
            docker_push "${IMAGE_NAME}:${LATEST_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}"
        fi

        docker_push "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${FULL_PHP_VERSION}"
        docker_push "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${MAJOR_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}"

        docker_push "${IMAGE_NAME}:${MINOR_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${FULL_PHP_VERSION}"
        docker_push "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${MINOR_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}"

        docker_push "${IMAGE_NAME}:${PATCH_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${FULL_PHP_VERSION}"
        docker_push "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${PHP_MINOR_RELEASE_TAG}"
        docker_push "${IMAGE_NAME}:${PATCH_RELEASE_TAG}-php${PHP_MAJOR_RELEASE_TAG}"
    fi
done