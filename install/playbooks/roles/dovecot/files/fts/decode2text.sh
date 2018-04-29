#!/bin/dash

# Example attachment decoder script. The attachment comes from stdin, and
# the script is expected to output UTF-8 data to stdout. (If the output isn't
# UTF-8, everything except valid UTF-8 sequences are dropped from it.)

# Where to save logs
logfile=/tmp/decode2txt.log

# Add some logs
date=$(date -Iseconds)
echo "${date}: $1" >>$logfile

libexec_dir=$(dirname $0)
content_type=$1

# The second parameter is the format's filename extension, which is used when
# found from a filename of application/octet-stream. You can also add more
# extensions by giving more parameters.
formats='application/pdf pdf
application/x-pdf pdf
application/msword doc
application/mspowerpoint ppt
application/vnd.ms-powerpoint ppt
application/ms-excel xls
application/x-msexcel xls
application/vnd.ms-excel xls
application/vnd.openxmlformats-officedocument.wordprocessingml.document docx
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet xlsx
application/vnd.openxmlformats-officedocument.presentationml.presentation pptx
application/vnd.oasis.opendocument.text odt
application/vnd.sun.xml.writer sxw
application/vnd.oasis.opendocument.spreadsheet ods
application/vnd.oasis.opendocument.presentation odp
'

# The mime type should be specified
if [ "$content_type" = "" ]; then
    echo "Script called without mime type" >>$logfile
    exit 0
fi

fmt=$(echo ${formats} | grep -w "^${content_type}" | cut -d ' ' -f 2)
if [ "$fmt" = "" ]; then
    echo "Content-Type: ${content_type} not supported" >>${logfile}
    exit 1
fi

# most decoders can't handle stdin directly, so write the attachment to a temp file
path=$(mktemp)
trap "rm -f $path" 0 1 2 3 14 15
cat > $path

wait_timeout() {
    childpid=$!
    trap "kill -9 $childpid; rm -f $path" 1 2 3 14 15
    wait $childpid
}

# TODO: Check if this can be get from the system
LANG=en_US.UTF-8
export LANG

if [ $fmt = "pdf" ]; then

    # Extract text from PDF file
    /usr/bin/pdftotext $path - 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "doc" ]; then

    # Extract text from doc file
    (/usr/bin/catdoc $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "ppt" ]; then

    # Extract text from PPT file
    (/usr/bin/catppt $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "xls" ]; then

    # Extract text from XLS file
    (/usr/bin/xls2csv $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "odt" ]; then

    # Extract text from ODT file
    (/usr/bin/odt2txt $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "sxw" ]; then

    # Extract text from SXW file
    (/usr/bin/sxw2txt $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "ods" ]; then

    # Extract text from ODS files
    (/usr/bin/ods2txt $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "docx" ]; then

    # Extract text from DOCX file
    (/usr/bin/docx2txt $path -; true) 2>/dev/null &
    wait_timeout 2>/dev/null

elif [ $fmt = "xlsx" ]; then

    # Extract text from XLSX file
    (/usr/bin/xlsx2csv $path; true) 2>/dev/null &
    wait_timeout 2>/dev/null

else
    echo "Buggy decoder script: $fmt not handled" >&2
    exit 1
fi

exit 0
