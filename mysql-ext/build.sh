#!/bin/bash

for i in "$@"
do
case $i in
    -t=*|--tag=*)
    IMAGE_TAG="${i#*=}"
    ;;
    -v=*|--version=*)
    MYSQL_VERSION="${i#*=}"
    ;;
    -s=*|--source=*)
    SOURCE="${i#*=}"
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
    [-v  | --version=<MySQL Version>   ]    MySQL version, defaults to 8.0
    [-s  | --source=<Scripts Dir>  ]        Location of the bootstrap SQL scripts, defaults to
                                                ./docker-entrypoint-initdb.d/
    [--help]                                Displays this text
    [--debug]                               Runs the script in debug mode

EOF
}

fLog() {
   echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"
}

fPrintArgs() {
    MYSQL_VERSION=${MYSQL_VERSION:-$DEFAULT_MYSQL_VERSION}
    IMAGE_TAG=${IMAGE_TAG:-"$DEFAULT_IMAGE_TAG:$MYSQL_VERSION"}
    SOURCE=${SOURCE:-"$DEFAULT_SQL_INIT_DIR"}

    echo
    fLog " Preparing Docker image with the following properties: "
    fLog "     ** Version   = $MYSQL_VERSION"
    fLog "     ** Tag       = $IMAGE_TAG"
    fLog "     ** Source    = $SOURCE"
    echo
}

if [ "$HELP" == "YES" ]; then 
    fDisplayUsage
else
    
    fPrintArgs

    docker build --no-cache \
        --build-arg source=${SOURCE} \
        --build-arg version=${MYSQL_VERSION} \
        -t $IMAGE_TAG \
        -f ./Dockerfile .

    fLog " Done!"
    echo
fi