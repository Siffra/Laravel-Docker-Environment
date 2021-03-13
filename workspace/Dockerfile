ARG PHP_VERSION=8.0
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

ARG PHP_VERSION

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
ENV DOCKER_USER=dockeruser

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} ${DOCKER_USER} && \
    useradd -l -u ${PUID} -g ${DOCKER_USER} -m ${DOCKER_USER} -G docker_env && \
    usermod -p "*" ${DOCKER_USER} -s /bin/bash && \
    apt-get install -yqq \
    apt-utils \
    aptitude \
    locales \
    tzdata \
    tmux \
    xclip \
    curl \
    wget \
    git \
    git-flow \
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

COPY .p10k.zsh    /root/.p10k.zsh
COPY ./aliases.sh /root/aliases.sh
COPY ./.tmux.conf /root/.tmux.conf
COPY .p10k.zsh    /home/${DOCKER_USER}/.p10k.zsh
COPY ./aliases.sh /home/${DOCKER_USER}/aliases.sh
COPY ./.tmux.conf /home/${DOCKER_USER}/.tmux.conf

RUN sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/${DOCKER_USER}/aliases.sh && \
    chown ${DOCKER_USER}:${DOCKER_USER} -R /home/${DOCKER_USER} && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
    echo "" >> ~/.bashrc

USER ${DOCKER_USER}

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
    pecl install swoole; \
    && echo "extension=swoole.so" >> /etc/php/${PHP_VERSION}/mods-available/swoole.ini && \
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
# MongoDB:
###########################################################################

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install mongo && \
      echo "extension=mongo.so" >> /etc/php/${PHP_VERSION}/mods-available/mongo.ini && \
      ln -s /etc/php/${PHP_VERSION}/mods-available/mongo.ini /etc/php/${PHP_VERSION}/cli/conf.d/30-mongo.ini \
    ;else \
      pecl install mongodb && \
      echo "extension=mongodb.so" >> /etc/php/${PHP_VERSION}/mods-available/mongodb.ini && \
      ln -s /etc/php/${PHP_VERSION}/mods-available/mongodb.ini /etc/php/${PHP_VERSION}/cli/conf.d/30-mongodb.ini \
    ;fi \
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
# SOAP:
###########################################################################

USER root

ARG INSTALL_SOAP=false

RUN if [ ${INSTALL_SOAP} = true ]; then \
    # Install the PHP SOAP extension
    apt-get -y install libxml2-dev php${PHP_VERSION}-soap \
    ;fi

###########################################################################
# telnet:
###########################################################################

USER root

ARG INSTALL_TELNET=false

RUN if [ ${INSTALL_TELNET} = true ]; then \
    apt-get update -yqq && \
    apt-get -y install telnet \
    ;fi

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

##############################################################################################################################
USER dockeruser
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# RUN ZSH_CUSTOM="$HOME/.oh-my-zsh" && \
#     git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" && \
#     ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" && \
#     sed --follow-symlinks -i -r -e "s/^(ZSH_THEME=).*/\1\"spaceship\"/" ~/.zshrc

RUN echo 'ZSH_DISABLE_COMPFIX=true' >> ~/.zshrc
RUN echo 'UPDATE_ZSH_DAYS=1' >> ~/.zshrc
RUN echo 'HIST_STAMPS="dd.mm.yyyy"' >> ~/.zshrc
RUN echo 'DISABLE_UPDATE_PROMPT=true' >> ~/.zshrc

# RUN echo 'SPACESHIP_TIME_SHOW=true' >> ~/.zshrc
# RUN echo 'SPACESHIP_BATTERY_SHOW=true' >> ~/.zshrc
# RUN echo 'SPACESHIP_USER_SHOW=always' >> ~/.zshrc
# RUN echo 'SPACESHIP_HOST_SHOW=always' >> ~/.zshrc

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed --follow-symlinks -i -r -e "s/^(ZSH_THEME=).*/\1\"powerlevel10k\/powerlevel10k\"/" ~/.zshrc

RUN echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
RUN sed --follow-symlinks -i -e "s/\(source \$ZSH\/oh-my-zsh.sh\)/plugins\+\=\(git-flow docker zsh_reload zsh-autosuggestions docker-compose gitignore helm perl kubectl cpanm common-aliases nvm npm yarn node composer laravel5 redis-cli supervisor ubuntu sudo debian command-not-found\)\n\1/" ~/.zshrc
RUN echo 'export PATH="$PATH:$HOME/.yarn/bin"' >> ~/.zshrc

RUN echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
    echo "" >> ~/.zshrc

RUN echo "\n" >> ~/.zshrc && \
    echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> ~/.zshrc && \
    echo "\n" >> ~/.zshrc && \
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc

###########################################################################
# GIT config:
###########################################################################

USER dockeruser
ARG GIT_GLOBAL_USER_EMAIL="luiz@siffra.com.br"
ARG GIT_GLOBAL_USER_NAME="Luiz Benevenuto"
RUN git config --global user.email ${GIT_GLOBAL_USER_EMAIL}
RUN git config --global user.name ${GIT_GLOBAL_USER_NAME}

USER root
ENV PASSWORD=123
RUN usermod --shell /bin/zsh root && usermod --shell /bin/zsh --password $(openssl passwd -1 ${PASSWORD}) ${DOCKER_USER}
RUN echo "${DOCKER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${DOCKER_USER}

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

