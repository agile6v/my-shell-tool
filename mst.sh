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
    echo "Usage: $SCRIPT_NAME <command|option>"
    echo
    echo "Options:"
    echo "    -V, --version    Print program version"
    echo "    -h, --help       Print help"
    echo
    echo "Commands:"
    echo "    replace       Replace the contents in the files"
    echo "    json          Json pretty print (The json string should be inside the single quotes)"
    echo "    count         Count the lines of code in a file or directory"
    echo "    ip            Translate IP address from dotted-decimal address to decimal format and vice versa,"
    echo "                  also support to calculate from CIDR ip address to network & broadcast address"
    echo
    echo "Use "$SCRIPT_NAME [command] --help" for more information about a command."
    echo
}

version() {
    echo "$SCRIPT_NAME v$VERSION"
}

### json pretty print
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

### replace the content in the files
replace() {
    if [ $# -eq 0 ];then
        replace_usage; exit
    fi

    local DIR="."
    local FROM=""
    local TO=""

    while getopts :hd:f:t: opt; do
        case $opt in
            d) DIR=$OPTARG; ;;
            f) FROM=$OPTARG; ;;
            t) TO=$OPTARG; ;;
            h) replace_usage; exit ;;
        esac
    done

    if [ "$FROM" = "" -o "$TO" = "" ]; then
        replace_usage; exit;
    fi

    local SCRIPT="grep -irl $FROM $DIR"
    local FILES=`eval $SCRIPT`
    local PATTERN="s/$FROM/$TO/g"
    if [ "${FILES}" = "" ]; then
        echo "No occurrences of \"$FROM\" found in the $DIR directory."; exit;
    fi
    echo "\nThe following files contain the string \"$FROM\":\n$FILES"
    echo $FILES | xargs sed -i ".bak" $PATTERN
    echo
    echo ">>> Replacement done."
    echo
    echo "Notice: The modified file is backed up in the file ending with suffix .bak!"
}

replace_usage() {
    echo "Usage: $SCRIPT_NAME replace <option>"
    echo
    echo "Options:"
    echo "    -d    Specify a directory"
    echo "    -f    A string to serach"
    echo "    -t    A string to replace"
    echo
    echo "i.e."
    echo "    $SCRIPT_NAME replace -d /tmp/ -f \"from\" -t \"to\""
    echo
}

# count the number of lines in a file or directory.
count() {
    if [ $# -eq 0 ];then
        count_usage; exit
    fi

    while getopts :h opt; do
        case $opt in
            h) count_usage; exit ;;
        esac
    done

    FILE=$1
    EXTENSION=${2:-"c|h|cc"}
    EXTENSION=${EXTENSION//|/ }
    OPTION=""
    for e in $EXTENSION; do
        if [ -z "$OPTION" ]; then
            OPTION=" -name \"*.$e\"";
        else
            OPTION="$OPTION -o -name \"*.$e\"";
        fi
    done

    if [ -d $FILE ]; then
        CMD="find $FILE$OPTION";
        NUM=`eval $CMD | xargs sed -e "/^[ \t ]*\/\//d" -e "s/\/\/[^\"]*//" -e "s/\/\*.*\*\///" -e "/^[ \t  ]*\/\*/,/.*\*\//d" | grep -v '^[[:space:]]*$' | wc -l`;
        echo "Total: $NUM lines";
    elif [ -f $FILE ]; then
        NUM=`sed -e "/^[ \t]*\/\//d" -e "s/\/\/[^\"]*//" -e "s/\/\*.*\*\///" -e "/^[ \t ]*\/\*/,/.*\*\//d" ${FILE}| grep -v '^[[:space:]]*$' | wc -l`;
        echo "$FILE: $NUM lines";
    else
        echo "$FILE is neither file nor directory!"; exit;
    fi
}

count_usage() {
    echo "Usage: $SCRIPT_NAME count <dir|file> [suffix]"
    echo
    echo "i.e."
    echo "    $SCRIPT_NAME count /path/to/count/"
    echo "    $SCRIPT_NAME count /path/to/count.php"
    echo "    $SCRIPT_NAME count /path/to/count/ c|cc|php|java"
    echo
}

ip_conversion() {
    if [ $# -eq 0 ];then
        ip_conversion_usage; exit
    fi

    if [ $1 -ge 0 ] 2>/dev/null; then
        A=$((($1 & 0xff000000 ) >>24))
        B=$((($1 & 0x00ff0000)>>16))
        C=$((($1 & 0x0000ff00)>>8))
        D=$(($1 & 0x000000ff))
        echo $A.$B.$C.$D
    elif [[  $1 == *"/"*  ]]; then
        STR=${1//\// }
        read IP MASK <<< $(echo ${STR})
        echo "Ip:      $IP"
        MASK=`cidr2mask $MASK`;
        echo "Netmask: $MASK";
        OIFS=$IFS;
        IFS='.';i=($IP);m=($MASK);
        NET_ADDR="$((${i[0]} & ${m[0]})).$((${i[1]} & ${m[1]})).$((${i[2]} & ${m[2]})).$((${i[3]} & ${m[3]}))"
        echo "Network: $NET_ADDR"
        BROADCAST_ADDR="$((255-${m[0]}+(${i[0]}&${m[0]}))).$((255-${m[1]}+(${i[1]}&${m[1]}))).$((255-${m[2]}+(${i[2]}&${m[2]}))).$((255-${m[3]}+(${i[3]}&${m[3]})))"
        IFS=$OIFS
        echo "Broadcast: $BROADCAST_ADDR";
    else
        A=$(echo $1 | cut -d '.' -f1)
        B=$(echo $1 | cut -d '.' -f2)
        C=$(echo $1 | cut -d '.' -f3)
        D=$(echo $1 | cut -d '.' -f4)
        echo $(($A<<24|$B<<16|$C<<8|$D))
    fi
}

cidr2mask() {
    set -- $(( 5 - ($1 / 8)  )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255  )) 0 0 0
    [ $1 -gt 1  ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

ip_conversion_usage() {
    echo "Usage: $SCRIPT_NAME ip <dotted-decimal address| decimal format>"
    echo
    echo "i.e."
    echo "    $SCRIPT_NAME ip 111.193.53.38"
    echo "    $SCRIPT_NAME ip 111.193.53.38/24"
    echo "    $SCRIPT_NAME ip 1874933030"
    echo
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
        replace) replace $@; exit ;;
        json) json $@; exit ;;
        count) count $@; exit ;;
        ip) ip_conversion $@; exit ;;
        *) usage; exit ;;
    esac
else
    usage;
fi

