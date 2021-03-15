FROM postgres:13

LABEL maintainer="Luiz Benevenuto <luiz@siffra.com.br>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -fy tzdata postgresql-plperl-$PG_MAJOR postgresql-pltcl-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
ENV LANGUAGE=pt_BR.UTF-8
ENV LC_ALL=pt_BR.UTF-8
ENV LC_CTYPE=pt_BR.UTF-8
ENV LANG=pt_BR.UTF-8

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PGTZ=America/Sao_Paulo

ENV POSTGRES_INITDB_ARGS --encoding=UTF-8 --lc-collate=pt_BR.UTF-8 --lc-ctype=pt_BR.UTF-8 --locale=pt_BR.UTF-8

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog
