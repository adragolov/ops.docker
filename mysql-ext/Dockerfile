ARG version=8.0
ARG source="./docker-entrypoint-initdb.d/"

FROM mysql:$version

ARG source
ARG version

ENV BOOTSTRAP_VERSION $version
ENV BOOTSTRAP_DIRECTORY $source

ADD $BOOTSTRAP_DIRECTORY /docker-entrypoint-initdb.d/