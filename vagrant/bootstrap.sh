#!/bin/sh

EXIT_CODE=0

CA_CERTIFICATES_PATH=/vagrant_data
CA_CERTIFICATES_SCRIPT_URI=https://raw.githubusercontent.com/scizeron/scripts/master/certificates/update-ca-certificates.sh

PROXY_USER="XXX"
PROXY_PASS="XXX"
PROXY_HOST="XXX"
PROXY_PORT="XXX"
PROXY_PROTO="http"

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
echo "- wget proxy configuration"
touch /home/vagrant/.wgetrc
echo "http_proxy = $PROXY_ENTRY" >  /home/vagrant/.wgetrc
echo "https_proxy = $PROXY_ENTRY" >>  /home/vagrant/.wgetrc
echo "use_proxy = on" >> /home/vagrant/.wgetrc
echo "wait = 15" >> /home/vagrant/.wgetrc
echo "- wget proxy configuration ok"

echo "-------------------------------------------------------------------"
echo "- curl proxy configuration"
touch /home/vagrant/.curlrc
echo "proxy=$PROXY_ENTRY" > /home/vagrant/.curlrc
echo "- curl proxy configuration ok"

echo ""
echo "-------------------------------------------------------------------"
echo "- env proxy configuration"
touch /home/vagrant/.bashrc
echo ""
echo "# added by bootstrap.sh" >> /home/vagrant/.bashrc
echo "export http_proxy=$PROXY_ENTRY" >> /home/vagrant/.bashrc
echo "export https_proxy=$PROXY_ENTRY" >> /home/vagrant/.bashrc
echo "export HTTP_PROXY=$PROXY_ENTRY" >> /home/vagrant/.bashrc
echo "export HTTPS_PROXY=$PROXY_ENTRY" >> /home/vagrant/.bashrc
echo "export NO_PROXY=192.*" >> /home/vagrant/.bashrc
echo "export no_proxy=192.*" >> /home/vagrant/.bashrc
echo "- env proxy configuration ok"

echo ""
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
echo " - download update-ca-certificates.sh from $CA_CERTIFICATES_SCRIPT_URI"
curl --proxy ${PROXY_ENTRY} --get --output update-ca-certificates.sh $CA_CERTIFICATES_SCRIPT_URI
chmod u+x update-ca-certificates.sh
echo " - update-ca-certificates.sh is downloaded"
echo " - install dos2unix"
apt-get -y install dos2unix
echo " - dos2unix update-ca-certificates.sh"
dos2unix update-ca-certificates.sh
echo " - add/update ca-certificates in $CA_CERTIFICATES_PATH"
./update-ca-certificates.sh $CA_CERTIFICATES_PATH
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
 echo "export http_proxy=\"${PROXY_ENTRY}\"" >> /etc/default/docker
 service docker restart
 EXIT_CODE=$?

 if [ $EXIT_CODE != 0 ]; then
  echo "ERROR : docker proxy configuration"
  exit $EXIT_CODE    
 fi;

 echo "- docker proxy configuration + restart ok"
fi

exit $EXIT_CODE
