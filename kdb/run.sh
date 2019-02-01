#!/bin/bash

for i in "$@"
do
case $i in
    -n=*|--name=*)
    CONTAINER_NAME="${i#*=}"
    ;;
    -t=*|--tag=*)
    IMAGE_TAG="${i#*=}"
    ;;
    -p=*|--port=*)
    PORT="${i#*=}"
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

 USAGE: ./build.sh 
    [-t  | --tag=<Image Tag>   ]            The kdb tag to be used. Defaults to $DEFAULT_KDB_TAG
    [-p  | --port=<Port>       ]            The kdb tag to be used. Defaults to $DEFAULT_KDB_PORT
    [--help]                                Displays this text
    [--debug]                               Runs the script in debug mode

EOF
}

fLog() {
   echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"
}

fPrintArgs() {
    IMAGE_TAG=${IMAGE_TAG:-$DEFAULT_KDB_TAG}
    PORT=${PORT:-$DEFAULT_KDB_PORT}

    echo
    fLog " Preparing Docker container with the following properties: "
    fLog "     ** Image     = $IMAGE_TAG"
    fLog "     ** Port      = $PORT"
    fLog "     ** Container = $CONTAINER_NAME"
    echo
}

fBuildImageIfNeeded() {
    if [[ "$(docker images -q $IMAGE_TAG 2> /dev/null)" == "" ]]; then
        fLog " Creating image $IMAGE_TAG ..."
        ./build.sh -t=$IMAGE_TAG
    else
        fLog " Image $IMAGE_TAG is cached."
    fi
}

if [ "$HELP" == "YES" ]; then 
    fDisplayUsage
else
    fPrintArgs
    fBuildImageIfNeeded

    if [ -z "$CONTAINER_NAME" ]; then
        fLog " Creating container ..."
        docker run \
            -p "$PORT:$DEFAULT_KDB_PORT" \
            -d "$IMAGE_TAG"
    else
        fLog " Creating named container $CONTAINER_NAME ..."
        docker run \
            --name $CONTAINER_NAME \
            -p "$PORT:$DEFAULT_KDB_PORT" \
            -d "$IMAGE_TAG"
    fi

    fLog " Done!"
    echo
fi