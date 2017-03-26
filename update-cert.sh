#!/usr/local/bin/bash

PHP=`which php`
if [ "$1" == "" ]; then
    echo "Usage $0 <domain>"
    exit
fi

# Give the location of the certificate directory. In my case they are
# genererated by 'debehydrated' https://github.com/lukas2511/letsencrypt.sh.git
CERTDIRECTORY="/opt/dehydrated/certs"

# Letencrypt certificate and chain filename (and path)
# 
# CHANGE THESE TO YOUR CERT/CHAIN PATH 

CRT="$CERTDIRECTORY/$1/fullchain.pem"
KEY="$CERTDIRECTORY/$1/privkey.pem"

# use php base64_encode function to convert certificate and chain
#
ENCRT=`$PHP -r '$cert = file_get_contents( $argv[1] , true);  echo base64_encode("$cert");' $CRT`
ENKEY=`$PHP -r '$key = file_get_contents( $argv[1] , true);  echo base64_encode("$key");' $KEY`

# replace the placeholder string in the pattern template with certificate encoded information.
# redirect it out to the sub file so it can be scp to the pfsense server


cat "$PWD/pattern.template" | awk '$1=$1' FS="CRTPLACEHOLDER" OFS="$ENCRT"  | awk '$1=$1' FS="KEYPLACEHOLDER" OFS="$ENKEY" | awk '$1=$1' FS="DOMAINPLACEHOLDER" OFS="$1" > /tmp/pattern.sub

cp /conf/config.xml /tmp/config.xml && sed -f /tmp/pattern.sub < /tmp/config.xml > /conf/config.xml && rm /tmp/config.cache && /etc/rc.restart_webgui

