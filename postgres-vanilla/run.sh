#!/bin/bash

for i in "$@"
do
case $i in
    -v=*|--version=*)
    POSTGRES_VERSION="${i#*=}"
    ;;
    -ep=*|--expose-port=*)
    POSTGRES_PORT="${i#*=}"
    ;;
    -dv=*|--data-volume=*)
    POSTGRES_DATA_VOLUME="${i#*=}"
    ;;
    -n=*|--name=*)
    POSTGRES_CONTAINER_NAME="${i#*=}"
    ;;
    -u=*|--user=*)
    POSTGRES_USER="${i#*=}"
    ;;
    -p=*|--password=*)
    POSTGRES_PASSWORD="${i#*=}"
    ;;
    --help)
    HELP=YES
    shift # past argument with no value 
    ;;
    --debug)
    DEBUG=YES
    shift # past argument with no value 
    ;;
    *)
        # unknown option
    ;;
esac
done

if [ "$DEBUG" == "YES" ]; then 
    set -x
fi

. ./defaults.properties

fDisplayUsage() {
    cat << EOF

 USAGE: ./run.sh 
    [-u  | --user=<Postgres User> ]          Postgres user, defaults to postgres
    [-v  | --version=<Postgres Version> ]    Postgres version, defaults to latest
    [-ep | --expose-port=<Postgres Port> ]   Server expose port, defaults to 5432
    [-dv | --data-volume=<Data Volume> ]     The mapped data volume. Autogenerated if not supplied
    [-n  | --name=<Container Name> ]         The name of the docker container. Optional
    [--help]                                 Displays this text
    [--debug]                                Runs the script in debug mode

EOF
}

fLog() {
   echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"
}

fPrintArgs() {
    POSTGRES_VERSION=${POSTGRES_VERSION:-$DEFAULT_POSTGRES_VERSION}
    POSTGRES_PORT=${POSTGRES_PORT:-$DEFAULT_POSTGRES_PORT}
    POSTGRES_USER=${POSTGRES_USER:-$DEFAULT_POSTGRES_USER}
    POSTGRES_DATA_VOLUME=${POSTGRES_DATA_VOLUME:-postgres_${POSTGRES_VERSION}_${POSTGRES_CONTAINER_NAME:-'default'}_data}

    echo
    fLog " Preparing Docker container with the following properties: "
    fLog "     ** Version   = $POSTGRES_VERSION"
    fLog "     ** Container = $POSTGRES_CONTAINER_NAME"
    fLog "     ** User      = $POSTGRES_USER"
    fLog "     ** Pass      = $POSTGRES_PASSWORD"
    fLog "     ** Port      = $POSTGRES_PORT"
    fLog "     ** Volume    = $POSTGRES_DATA_VOLUME"
    echo
}

fValidateArgs() {
    if [ -z "$POSTGRES_PASSWORD" ]; then
        echo " ERROR (-1): Password is not specified!"
        fDisplayUsage
        exit -1
    fi
}

fPullImageIfNeeded() {
    POSTGRES_IMAGE=postgres:$POSTGRES_VERSION
    if [[ "$(docker images -q $POSTGRES_IMAGE 2> /dev/null)" == "" ]]; then
        fLog " Pulling fresh image $POSTGRES_IMAGE ..."
        docker pull $POSTGRES_IMAGE
    else
        fLog " Image $POSTGRES_IMAGE is cached."
    fi
}

fCreateDataVolumeOrDie() {
    fLog " Creating volume $POSTGRES_DATA_VOLUME ..."
    docker volume inspect $POSTGRES_DATA_VOLUME 1> /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        echo " ERROR (-4): Data volume $POSTGRES_DATA_VOLUME already exists!"
        fDisplayUsage
        exit -4
    else
        docker volume create $POSTGRES_DATA_VOLUME 1> /dev/null
    fi
}

fRunNamedContainerOrDie() {
    fLog " Creating named container $POSTGRES_CONTAINER_NAME ..."
    docker container inspect $POSTGRES_CONTAINER_NAME 1> /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        echo " ERROR (-3): Container $POSTGRES_CONTAINER_NAME already exists!"
        fDisplayUsage
        exit -3
    fi
    docker run \
        --name $POSTGRES_CONTAINER_NAME \
        -p "$POSTGRES_PORT:$DEFAULT_POSTGRES_PORT" \
        -e "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
        -e "POSTGRES_USER=$POSTGRES_USER" \
        -v "$POSTGRES_DATA_VOLUME:/var/lib/postgresql/data" \
        -d "$POSTGRES_IMAGE"
}

fRunContainer() {
    fLog " Creating container ..."
    docker run \
        -p "$POSTGRES_PORT:$DEFAULT_POSTGRES_PORT" \
        -e "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
        -e "POSTGRES_USER=$POSTGRES_USER" \
        -v "$POSTGRES_DATA_VOLUME:/var/lib/postgresql/data" \
        -d "$POSTGRES_IMAGE"
}

if [ "$HELP" == "YES" ]; then 
    fDisplayUsage
else
    fPrintArgs
    fValidateArgs
    fPullImageIfNeeded
    fCreateDataVolumeOrDie

    if [ -z "POSTGRES_CONTAINER_NAME" ]; then
        fRunContainer
    else
        fRunNamedContainerOrDie
    fi

    fLog " Done!"
    echo
fi