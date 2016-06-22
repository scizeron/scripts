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

for CA_FILE in ${SRC_CA_FOLDER}/
do
 case "$CA_FILE" in
  *.cer)
    OUT_FILE=${DEST_DIR}/${CA_FILE}${EXPECTED_EXTENSION}
    openssl x509 -in $CA_FILE -inform der -outform pem -out ${OUT_FILE}
    echo "${CA_FILE} has been transformed and copied"
    ;;
  *.pem)
    cp ${CA_FILE} ${DEST_DIR}/${CA_FILE}
    echo "${CA_FILE} has been copied"
    ;;
 esac
done

update-ca-certificates

exit $?
