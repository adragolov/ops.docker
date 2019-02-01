FROM ubuntu:trusty

ENV KDB_ARCHIVE_FILE ./kdb-v3.6-x86.tar.gz
ENV KDB_VERSION 3.6
ENV KDB_VARIANT x86
ENV KDB_PORT 5551
ENV QUSER_NAME quser
ENV QUSER_HOME /users/$QUSER_NAME
ENV QHOME $QUSER_HOME/q

SHELL ["/bin/bash", "-c"]

ADD $KDB_ARCHIVE_FILE $QUSER_HOME

RUN useradd -m $QUSER_NAME && \
    apt-get update && \
    apt-get install -y libc6-i386 && \
    chmod -R 755 $QUSER_HOME/q && \
    chmod +x $QUSER_HOME/q/l32/q && \
    chown -R $QUSER_NAME $QUSER_HOME/q && \
    echo "export QHOME=$QUSER_HOME" > /etc/environment

USER $QUSER_NAME

WORKDIR $QUSER_HOME/q/l32/

EXPOSE $KDB_PORT

ENTRYPOINT ./q -p ${KDB_PORT}