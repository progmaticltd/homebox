#!/bin/bash

sedcmd=${SEDCMD:-sed}
defaultprivoxydir="/etc/privoxy"
defaulturls=$(grep -v '#' /etc/privoxy/adblock-lists.conf | tr '\n' ' ')

#===    FUNCTION    ============================================================
#            NAME:    cleanup
#     DESCRIPTION:    cleans up after script termination
#      PARAMETERS:    none
#         RETURNS:    none
#===============================================================================
function cleanup() {
    trap - INT TERM EXIT
    [[ -f "${pidfile}" ]] && rm "$pidfile"
    exit
}

#===    FUNCTION    ============================================================
#            NAME:    isrunning
#     DESCRIPTION:    is any previous instance of this script already running
#      PARAMETERS:    pid file path
#         RETURNS:    boolean
#===============================================================================
function isrunning() {
    pidfile="${1}"
    [[ ! -f "${pidfile}" ]] && return 1    #pid file is nonexistent
    procpid=$(<"${pidfile}")
    [[ -z "${procpid}" ]] && return 1    #pid file contains no pid
    # check process list for pid existence and is an instance of this script
    [[ ! $(ps -p ${procpid} | grep $(basename ${0})) == "" ]] && value=0 || value=1
    return ${value}
}

#===    FUNCTION    ============================================================
#            NAME:    createpidfile
#     DESCRIPTION:    atomic creation of pid file with no race condition
#      PARAMETERS:    the pid to put in the file, the filename to use as a lock
#         RETURNS:    none
#===============================================================================
function createpidfile() {
    mypid=${1}
    pidfile=${2}
    #Close stderr, don't overwrite existing file, shove my pid in the lock file.
    $(exec 2>&-; set -o noclobber; echo "$mypid" > "$pidfile")
    [[ ! -f "${pidfile}" ]] && exit #Lock file creation failed
    procpid=$(<"${pidfile}")
    [[ ${mypid} -ne ${procpid} ]] && {
        #I'm not the pid in the lock file
        # Is the process pid in the lockfile still running?
        isrunning "${pidfile}" || {
            # No.    Kill the pidfile and relaunch
            rm "${pidfile}"
            $0 "$@"
        }
        exit
    }
}

#===    FUNCTION    ============================================================
#            NAME:    pidfilename
#     DESCRIPTION:    create a predictable pid file name, put it in the right inode
#      PARAMETERS:    none
#         RETURNS:    path and filename
#===============================================================================
function pidfilename() {
    myfile=$(basename "$0" .sh)
    whoiam=$(whoami)
    mypidfile="/tmp/${myfile}.pid"
    [[ "$whoiam" == 'root' ]] && mypidfile="/var/run/$myfile.pid"
    echo "$mypidfile"
}

#===    FUNCTION    ============================================================
#            NAME:    doconvert
#     DESCRIPTION:    download requested scripts and perform the conversion
#      PARAMETERS:    privoxy conf dir, list of urls
#         RETURNS:    none
#===============================================================================
function doconvert() {
    privoxydir=$1
    urls=$2
    for url in ${urls[@]}
    do
        file=${tempdir}/$(basename ${url})
        actionfile=${file%\.*}.script.action
        filterfile=${file%\.*}.script.filter
        list=$(basename ${file%\.*})

        # clean up files
        [[ -f "${file}" ]] && rm "${file}"
        [[ -f "${actionfile}" ]] && rm "${actionfile}"
        [[ -f "${filterfile}" ]] && rm "${filterfile}"

        echo "downloading ${url} ..."
        wget -t 3 -O ${file} "${url}" >${tempdir}/wget-${url//\//#}.log 2>&1

        [ "$(grep -E '^.*\[Adblock.*\].*$' ${file})" == "" ] && echo "The list recieved from ${url} isn't an AdblockPlus list. Skipped" && continue

        echo "Creating actionfile for ${list} ..."
        echo -e "{ +block{${list}} }" > ${actionfile}
        $sedcmd '/^!.*/d;1,1 d;/^@@.*/d;/\$.*/d;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}

        echo "... creating filterfile for ${list} ..."
        echo "FILTER: ${list} Tag filter of ${list}" > ${filterfile}
        $sedcmd '/^#/!d;s/^##//g;s/^#\(.*\)\[.*\]\[.*\]*/s@<([a-zA-Z0-9]+)\\s+.*id=.?\1.*>.*<\/\\1>@@g/g;s/^#\(.*\)/s@<([a-zA-Z0-9]+)\\s+.*id=.?\1.*>.*<\/\\1>@@g/g;s/^\.\(.*\)/s@<([a-zA-Z0-9]+)\\s+.*class=.?\1.*>.*<\/\\1>@@g/g;s/^a\[\(.*\)\]/s@<a.*\1.*>.*<\/a>@@g/g;s/^\([a-zA-Z0-9]*\)\.\(.*\)\[.*\]\[.*\]*/s@<\1.*class=.?\2.*>.*<\/\1>@@g/g;s/^\([a-zA-Z0-9]*\)#\(.*\):.*[:[^:]]*[^:]*/s@<\1.*id=.?\2.*>.*<\/\1>@@g/g;s/^\([a-zA-Z0-9]*\)#\(.*\)/s@<\1.*id=.?\2.*>.*<\/\1>@@g/g;s/^\[\([a-zA-Z]*\).=\(.*\)\]/s@\1^=\2>@@g/g;s/\^/[\/\&:\?=_]/g;s/\.\([a-zA-Z0-9]\)/\\.\1/g' ${file} >> ${filterfile}
        echo "... filterfile created - adding filterfile to actionfile ..."
        echo "{ +filter{${list}} }" >> ${actionfile}
        echo "*" >> ${actionfile}
        echo "... filterfile added ..."

        echo "... creating and adding whitlist for urls ..."
        echo "{ -block }" >> ${actionfile}
        $sedcmd '/^@@.*/!d;s/^@@//g;/\$.*/d;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}
        echo "... created and added whitelist - creating and adding image handler ..."

        echo "{ -block +handle-as-image }" >> ${actionfile}
        $sedcmd '/^@@.*/!d;s/^@@//g;/\$.*image.*/!d;s/\$.*image.*//g;/#/d;s/\./\\./g;s/\?/\\?/g;s/\*/.*/g;s/(/\\(/g;s/)/\\)/g;s/\[/\\[/g;s/\]/\\]/g;s/\^/[\/\&:\?=_]/g;s/^||/\./g;s/^|/^/g;s/|$/\$/g;/|/d' ${file} >> ${actionfile}
        echo "... created and added image handler ..."
        echo "... created actionfile for ${list}."

        actionfiledest="${privoxydir}/$(basename ${actionfile})"
        echo "... copying ${actionfile} to ${actionfiledest}"
        cp "${actionfile}" "${actionfiledest}"
        filterfiledest="${privoxydir}/$(basename ${filterfile})"
        echo "... copying ${filterfile} to ${filterfiledest}"
        cp "${filterfile}" "${filterfiledest}"
    done
}

#===    FUNCTION    ============================================================
#            NAME:    usage
#     DESCRIPTION:    prints command usage
#      PARAMETERS:    none
#         RETURNS:    none
#===============================================================================
function usage() {
    echo "Usage: ${0} [-d] [-p <privoxy config dir>] [-u <url1>] [-u <url2>]..."
    exit 1
}

#===    FUNCTION    ============================================================
#            NAME:    main
#     DESCRIPTION:    main script entry point
#      PARAMETERS:    none
#         RETURNS:    none
#===============================================================================
function main() {
    pidfile="$(pidfilename)"

    tempfile="$(mktemp -t j.XXX)"
    tempdir="$(dirname $tempfile)"
    rm ${tempfile}

    isrunning "${pidfile}" && {
        echo "$(basename ${0}) is already running"
        exit 1
    }

    createpidfile $$ "${pidfile}"
    trap 'cleanup' INT TERM EXIT
    debug="false"
    trap 'logger -t $0 -i -- $USER : $BASH_COMMAND' ERR    #log errors regardless

    privoxydir=$defaultprivoxydir
    urls=( "${defaulturls[@]}" )
    while getopts "dp:u:" opt; do
        case "${opt}" in
            p)
                privoxydir=${OPTARG}
                ;;
            u)
                urls+=("${OPTARG}")
                ;;
            d)
                debug="true"
                ;;
            *)
                usage
                ;;
            :)
                echo "Option -'$OPTARG' requires an arguemnt." >&2
                usage
                ;;
        esac
    done

    [[ "$debug" == "true" ]] && trap 'logger -t $0 -i -- $USER : $BASH_COMMAND' DEBUG #syslog everything if we're debugging
    [[ ! -d "$privoxydir" ]] && usage
    [[ "${#urls[@]}" -eq "0" ]] && usage

    # perform the operation
    doconvert "$privoxydir" "$urls"
}

main "$@"

exit 0
