ARG PHP_VERSION
FROM siffra/laravel-base:latest-${PHP_VERSION}

LABEL maintainer="Luiz Benevenuto <luiz@siffra.com.br>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe && apt-get update -yqq && pecl channel-update pecl.php.net

###########################################################################
# Set Timezone
###########################################################################

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# Install additional locales:
###########################################################################

ARG INSTALL_ADDITIONAL_LOCALES=false
ARG ADDITIONAL_LOCALES

RUN if [ ${INSTALL_ADDITIONAL_LOCALES} = true ]; then \
    apt-get install -y locales git \
    && echo '' >> /usr/share/locale/locale.alias \
    && temp="${ADDITIONAL_LOCALES%\"}" \
    && temp="${temp#\"}" \
    && for i in ${temp}; do sed -i "/$i/s/^#//g" /etc/locale.gen; done \
    && locale-gen \
    ;fi

###########################################################################
# pgsql
###########################################################################

ARG INSTALL_PGSQL=false

RUN if [ ${INSTALL_PGSQL} = true ]; then \
    # Install the pgsql extension
    docker-php-ext-install pgsql \
    ;fi

###########################################################################
# GD:
###########################################################################

ARG INSTALL_GD=false

RUN if [ ${INSTALL_GD} = true ]; then \
    apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    ;fi

###########################################################################
# SOAP:
###########################################################################

ARG INSTALL_SOAP=false

RUN if [ ${INSTALL_SOAP} = true ]; then \
    # Install the soap extension
    rm /etc/apt/preferences.d/no-debian-php && \
    apt-get update -yqq && \
    apt-get -y install libxml2-dev php-soap && \
    docker-php-ext-install soap \
    ;fi

###########################################################################
# Exif:
###########################################################################

ARG INSTALL_EXIF=false

RUN if [ ${INSTALL_EXIF} = true ]; then \
    # Enable Exif PHP extentions requirements
    docker-php-ext-install exif \
    ;fi

###########################################################################
# Opcache:
###########################################################################

ARG INSTALL_OPCACHE=false

RUN if [ ${INSTALL_OPCACHE} = true ]; then \
    docker-php-ext-install opcache \
    ;fi

# Copy opcache configration
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# PHP REDIS EXTENSION
###########################################################################

ARG INSTALL_PHPREDIS=false

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    # Install Php Redis Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install -o -f redis-4.3.0; \
    else \
    pecl install -o -f redis; \
    fi \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    ;fi

###########################################################################
# MongoDB:
###########################################################################

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install mongo && \
    docker-php-ext-enable mongo \
    ;else \
    pecl install mongodb && \
    docker-php-ext-enable mongodb \
    ;fi \
    ;fi

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}"

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}
ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LC_CTYPE=${LOCALE}
ENV LANG=${LOCALE}

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
