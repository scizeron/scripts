#!/bin/sh

EXIT_CODE=0

# ----------------------------------------------------------------------------
# usage
# ----------------------------------------------------------------------------
usage() {
 echo "Usage:  $0 --proxyHost <PROXY_HOST> --proxyUser <PROXY_USER> --proxyPass <PROXY_PASS> --proxyPort <PROXY_PORT> --proxyProto <PROXY_PROTO>"
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

if [ $# -eq 0 ]; then
 usage
 exit 1
fi

while [ $# -gt 0 ]
do
 key="$1"
 case $key in
  --proxyUser)
   PROXY_USER=$2
   shift
   ;;
  --proxyPass)
   PROXY_PASS=$2
   shift
   ;;
  --proxyHost)
   PROXY_HOST=$2
   shift
   ;;
  --proxyPort)
   PROXY_PORT=$2
   shift
   ;;
  --proxyProto)
   PROXY_PROTO=$2
   shift
   ;;
  -h|--help)
   usage
   exit 0
   ;;
  *)
   usage
   exit 1
   ;;
 esac
 shift
done

if [ $PROXY_HOST = "XXX" ]; then
 echo "The '--proxyHost' value is mandatory."
 usage
 exit 1
fi

PROXY_ENTRY="${PROXY_PROTO}://"

if [ $PROXY_USER != "XXX" ] && [ $PROXY_PASS  != "XXX" ]; then
 PROXY_ENTRY="${PROXY_ENTRY}${PROXY_USER}:${PROXY_PASS}@"
fi

PROXY_ENTRY="${PROXY_ENTRY}${PROXY_HOST}"

if [ $PROXY_PORT != "XXX" ]; then
 PROXY_ENTRY="${PROXY_ENTRY}:${PROXY_PORT}"
fi

echo "-------------------------------------------------------------------"
echo "- apt-get proxy configuration"
APT_PROXY_FILE="/etc/apt/apt.conf.d/01proxy"
touch $APT_PROXY_FILE

echo "Acquire::http::Proxy \"${PROXY_ENTRY}\";" > $APT_PROXY_FILE
echo "Acquire::https::Proxy \"${PROXY_ENTRY}\";" >> $APT_PROXY_FILE
echo "- apt-get proxy configuration ok"

echo ""
echo "-------------------------------------------------------------------"
echo "- certificates"
curl --proxy ${PROXY_ENTRY} --get --output update-ca-certificates.sh https://raw.githubusercontent.com/scizeron/scripts/master/certificates/update-ca-certificates.sh
chmod u+x update-ca-certificates.sh
apt-get -y install dos2unix
dos2unix update-ca-certificates.sh
./update-ca-certificates.sh /vagrant_data
EXIT_CODE=$?

if [ $EXIT_CODE != 0 ]; then
 echo "ERROR : certificates configuration"
 exit $EXIT_CODE    
fi;

echo "- certificates ok"

if [ -f /etc/default/docker ]; then
 echo ""
 echo "-------------------------------------------------------------------"
 echo "- docker proxy configuration"
 echo "export http_proxy=\"http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}\"" >> /etc/default/docker
 service docker restart
 EXIT_CODE=$?

 if [ $EXIT_CODE != 0 ]; then
  echo "ERROR : docker proxy configuration"
  exit $EXIT_CODE    
 fi;

 echo "- docker proxy configuration + restart ok"
fi

exit $EXIT_CODE
