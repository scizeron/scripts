#!/bin/sh

# ----------------------------------------------------------------------------
# usage
# ----------------------------------------------------------------------------
usage() {
 echo "Usage:  $0 dir"
 echo " dir containing the certificates to update"
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

if [ $# -eq 0 ]; then
 usage
 exit 1
fi

SRC_CA_FOLDER=$1
SRC_CERT_EXTENSION=*.cer
EXPECTED_EXTENSION=.crt
DEST_DIR=/usr/local/share/ca-certificates

cp $SRC_CA_FOLDER/${SRC_CERT_EXTENSION} $DEST_DIR/

for CA_FILE in $DEST_DIR/${SRC_CERT_EXTENSION}
do
 openssl x509 -in $CA_FILE -inform der -outform pem -out ${CA_FILE}${EXPECTED_EXTENSION}
 rm $CA_FILE
 echo "${CA_FILE}${EXPECTED_EXTENSION} is created"
done

update-ca-certificates

exit $?
