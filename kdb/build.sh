#!/bin/bash

for i in "$@"
do
case $i in
    -t=*|--tag=*)
    IMAGE_TAG="${i#*=}"
    ;;
    -t=*|--tag=*)
    IMAGE_TAG="${i#*=}"
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
    [-t  | --tag=<Image Tag>   ]            The docker tag associated with the built image
    [--help]                                Displays this text
    [--debug]                               Runs the script in debug mode

EOF
}

fLog() {
   echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"
}

fPrintArgs() {
    IMAGE_TAG=${IMAGE_TAG:-$DEFAULT_KDB_TAG}

    echo
    fLog " Preparing Docker image with the following properties: "
    fLog "     ** Tag       = $IMAGE_TAG"
    echo
}

if [ "$HELP" == "YES" ]; then 
    fDisplayUsage
else
    
    fPrintArgs

    docker build --no-cache \
        -t $IMAGE_TAG \
        -f ./Dockerfile .

    fLog " Done!"
    echo
fi