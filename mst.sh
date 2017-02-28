#!/usr/bin/env bash

#
# My shell toolkit
# Author: agile6v
#

VERSION="0.0.1"
PLATFORM=`uname -s 2>/dev/null`
SCRIPT_NAME=`basename $0`

# print usage information
usage() {
    version;
    echo
    echo "Usage: $SCRIPT_NAME [command|option]"
    echo
    echo "Options:"
    echo "    -V, --version    Print program version"
    echo "    -h, --help       Print help"
    echo
    echo "Commands:"
    echo "    replace       Replace content in the files"
    echo "    json          Json pretty print (The input should be inside the single quotes)"
    echo
    echo "Use "$SCRIPT_NAME [command] --help" for more information about a command."
    echo
}

version() {
    echo "$SCRIPT_NAME v$VERSION"
}

json() {
    check_cmd python;

    if [ $# -eq 0 ];then
        json_usage; exit
    fi

    while getopts :hf: opt; do
        case $opt in
            f) python -m json.tool $OPTARG; exit ;;
            h) json_usage; exit ;;
        esac
    done

    echo "$1" | python -m json.tool;
}

json_usage() {
    echo "Usage: $SCRIPT_NAME json [option|json string]"
    echo
    echo "Options:"
    echo "    -f    Specify a json file"
    echo
    echo "i.e."
    echo "    $SCRIPT_NAME json '{\"name\":\"agile6v\",\"gender\":\"male\"}'"
    echo "    $SCRIPT_NAME json -f /path/to/file.json"
    echo
}

replace() {

    echo "replace running";
    #grep -irl "hello" . | xargs sed -i ".bak" 's/hello/hi/g'
}

check_cmd() {
    FOUND=`command -v $1`
    if [ -z $FOUND ]; then
        echo "Please install $1 first!"; exit;
    fi
}

######################### main #############################

# parse arguments
arg=$1; shift
if [ -n "$arg"  ]; then
    case $arg in
        -h|--help) usage; exit ;;
        -V|--version) version; exit ;;
        replace) replace; exit ;;
        json) json $@; exit ;;
        *) usage; exit ;;
    esac
else
    usage;
fi


