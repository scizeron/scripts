#!/bin/sh

# ----------------------------------------------------------------------------
# usage
# ----------------------------------------------------------------------------
usage() {
 echo "Usage:  $0 dir"
 echo " dir containing the certificates to add/update"
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

if [ $# -eq 0 ]; then
 usage
 exit 1
fi

SRC_CA_FOLDER=$1
EXPECTED_EXTENSION=.crt
DEST_DIR=/usr/local/share/ca-certificates

echo "-----------------------------------------------------------------------------"
echo " - Files in ${SRC_CA_FOLDER}"
echo "-----------------------------------------------------------------------------"

for CA_FILE in ${SRC_CA_FOLDER}/*.*
do
 FILENAME=`basename $CA_FILE` 
 FILE_NO_EXT=`echo $FILENAME | awk -F "." '{print $(NF-1)}'`
 EXT=`echo $FILENAME | awk -F "." '{print $NF}'`
 echo " - ${FILENAME}" 
 case "$FILENAME" in
  *.cer)
    OUT_FILE=${DEST_DIR}/${FILE_NO_EXT}${EXPECTED_EXTENSION}
    openssl x509 -in $CA_FILE -inform der -outform pem -out ${OUT_FILE}
    echo " - Transformed in pem format (${EXPECTED_EXTENSION}) and copied in ${DEST_DIR}"
    ;;
  *.crt)
    cp ${CA_FILE} ${DEST_DIR}/${FILENAME}
    echo " - Copied in ${DEST_DIR}"
    ;;
 esac
done

update-ca-certificates

exit $?
