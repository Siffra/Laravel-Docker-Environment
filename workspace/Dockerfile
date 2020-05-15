ARG PHP_VERSION=7.4
ARG BASE_IMAGE_TAG_PREFIX=latest

FROM postgres:12 as postgresLatest
RUN echo ${PG_VERSION}

# Build EXA
FROM rust as exa_build

# Clone the git repo, checkout v0.8.0 (commit 877265b) and build the binary
RUN cd /root && git clone https://github.com/ogham/exa && cd exa && cargo build --release --no-default-features

# FINAL
FROM laradock/workspace:${BASE_IMAGE_TAG_PREFIX}-${PHP_VERSION} as Final

LABEL maintainer="Luiz Benevenuto <luiz@hy.st>"

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

###########################################################################
# Dockeruser non-root user:
###########################################################################

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} dockeruser && \
    useradd -u ${PUID} -g dockeruser -m dockeruser && \
    usermod -p "*" dockeruser -s /bin/bash && \
    apt-get install -yqq \
        apt-utils \
        locales \
        tzdata \
        tmux \
        xclip \
        curl \
        git \
        zsh \
        sudo \
        zsh-syntax-highlighting \
        powerline \
        fonts-powerline \
        # next lines are here becase there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
        libzip-dev zip unzip \
        # Install the zip extension
        php${PHP_VERSION}-zip \
        # nasm
        nasm && \
        php -m | grep -q 'zip'


###########################################################################
# Set Timezone
###########################################################################

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# User Aliases
###########################################################################

USER root

COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/dockeruser/aliases.sh

RUN sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/dockeruser/aliases.sh && \
    chown dockeruser:dockeruser /home/dockeruser/aliases.sh && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

USER dockeruser

RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc


###########################################################################
# Composer:
###########################################################################

USER root

# Add the composer.json
COPY ./composer.json /home/dockeruser/.composer/composer.json

# Make sure that ~/.composer belongs to dockeruser
RUN chown -R dockeruser:dockeruser /home/dockeruser/.composer

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

USER dockeruser

# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

RUN if [ ${COMPOSER_GLOBAL_INSTALL} = true ]; then \
    # run the install
    composer global install \
;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Non-root user : PHPUnit path
###########################################################################

# add ./vendor/bin to non-root user's bashrc (needed for phpunit)
USER dockeruser

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# PHP REDIS EXTENSION
###########################################################################
USER root
ARG INSTALL_PHPREDIS=false

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    apt-get update -yqq && \
    apt-get install -yqq php-redis \
;fi

###########################################################################
# Swoole EXTENSION
###########################################################################
USER root
ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
    # Install Php Swoole Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl -q install swoole-2.0.10; \
    else \
      if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install swoole-2.2.0; \
      else \
        pecl install swoole; \
      fi \
    fi && \
    echo "extension=swoole.so" >> /etc/php/${PHP_VERSION}/mods-available/swoole.ini && \
    ln -s /etc/php/${PHP_VERSION}/mods-available/swoole.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-swoole.ini \
    && php -m | grep -q 'swoole' \
;fi

###########################################################################
# Node / Yarn
###########################################################################
USER root
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt update && apt-get install -fy yarn

###########################################################################
# Prestissimo:
###########################################################################
USER dockeruser

ARG INSTALL_PRESTISSIMO=false

RUN if [ ${INSTALL_PRESTISSIMO} = true ]; then \
    # Install Prestissimo
    composer global require "hirak/prestissimo" \
;fi

###########################################################################
# ImageMagick:
###########################################################################

USER root

ARG INSTALL_IMAGEMAGICK=false

RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
    apt-get install -y imagemagick php-imagick \
;fi

###########################################################################
# pgsql client
###########################################################################

USER root

ARG INSTALL_PG_CLIENT=false

RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
    # Install the pgsql client
    apt-get install wget \
    && add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get -y install postgresql-client-10 \
;fi

###########################################################################
# SOAP:
###########################################################################

USER root

ARG INSTALL_SOAP=false

RUN if [ ${INSTALL_SOAP} = true ]; then \
  # Install the PHP SOAP extension
  apt-get -y install libxml2-dev php${PHP_VERSION}-soap \
;fi

###########################################################################
# ping:
###########################################################################

USER root

ARG INSTALL_PING=false

RUN if [ ${INSTALL_PING} = true ]; then \
    apt-get update -yqq && \
    apt-get -y install inetutils-ping \
;fi

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

##############################################################################################################################
USER dockeruser
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN ZSH_CUSTOM="$HOME/.oh-my-zsh" && \
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" && \
  ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" && \
  sed --follow-symlinks -i -r -e "s/^(ZSH_THEME=).*/\1\"spaceship\"/" ~/.zshrc

RUN echo 'ZSH_DISABLE_COMPFIX=true' >> ~/.zshrc
RUN echo 'SPACESHIP_TIME_SHOW=true' >> ~/.zshrc
RUN echo 'SPACESHIP_BATTERY_SHOW=true' >> ~/.zshrc
RUN echo 'DISABLE_UPDATE_PROMPT=true' >> ~/.zshrc
RUN echo 'SPACESHIP_USER_SHOW=always' >> ~/.zshrc
RUN echo 'SPACESHIP_HOST_SHOW=always' >> ~/.zshrc
RUN echo 'UPDATE_ZSH_DAYS=1' >> ~/.zshrc
RUN echo 'HIST_STAMPS="dd.mm.yyyy"' >> ~/.zshrc
RUN echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
RUN sed --follow-symlinks -i -e "s/\(source \$ZSH\/oh-my-zsh.sh\)/plugins\+\=\(git-flow docker zsh_reload docker-compose gitignore helm perl kubectl cpanm common-aliases nvm npm yarn node composer laravel5 redis-cli supervisor ubuntu sudo debian command-not-found\)\n\1/" ~/.zshrc
RUN echo 'export PATH="$PATH:$HOME/.yarn/bin"' >> ~/.zshrc

RUN echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
    echo "" >> ~/.zshrc

USER root
RUN usermod --shell /bin/zsh root && usermod --shell /bin/zsh dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dockeruser

COPY --from=exa_build /root/exa/target/release /usr/local/bin
COPY --from=postgresLatest /usr/lib/postgresql/12/bin/psql /usr/local/bin/psql_12
COPY --from=postgresLatest /usr/lib/postgresql/12/bin/pg_dump /usr/local/bin/pg_dump_12
COPY --from=postgresLatest /usr/lib/postgresql/12/bin/pg_restore /usr/local/bin/pg_restore_12

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

ARG APP_CODE_PATH_CONTAINER=/var/www
WORKDIR ${APP_CODE_PATH_CONTAINER}

