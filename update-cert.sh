#!/usr/local/bin/bash

PHP=`which php`
if [ "$1" == "" ]; then
    echo "Usage $0 <domain>"
    exit
fi

echo "+ PHP Binary found: $PHP"
# Give the location of the certificate directory. In my case they are
# genererated by 'debehydrated' https://github.com/lukas2511/letsencrypt.sh.git
CERTDIRECTORY="/opt/dehydrated/certs"
echo "+ Certificate directory is $CERTDIRECTORY"
# Letencrypt certificate and chain filename (and path)
# 
# CHANGE THESE TO YOUR CERT/CHAIN PATH 
echo "+ Loading certficites from $CERTDIRECTORY/$1/"
CRT="$CERTDIRECTORY/$1/fullchain.pem"

echo "+ fullchain.pem: $CRT"
KEY="$CERTDIRECTORY/$1/privkey.pem"

echo "+ privkey.pem: $KEY"
# use php base64_encode function to convert certificate and chain
#

echo "+ Base64Enconding certificate files..."
ENCRT=`$PHP -r '$cert = file_get_contents( $argv[1] , true);  echo base64_encode("$cert");' $CRT`
ENKEY=`$PHP -r '$key = file_get_contents( $argv[1] , true);  echo base64_encode("$key");' $KEY`

# replace the placeholder string in the pattern template with certificate encoded information.
# redirect it out to the sub file so it can be scp to the pfsense server

echo "+ Creating pattern.sub file for replacement in config.xml"
cat "$PWD/pattern.template" | awk '$1=$1' FS="CRTPLACEHOLDER" OFS="$ENCRT"  | awk '$1=$1' FS="KEYPLACEHOLDER" OFS="$ENKEY" | awk '$1=$1' FS="DOMAINPLACEHOLDER" OFS="$1" > /tmp/pattern.sub

if grep "sslcertificate-$1" /conf/config.xml > /dev/null; then
    echo "+ Check: sslcertificate-$1 found in config.xml"
    DOMAININCONFIGXML=1
else
    echo "!!! Failure: sslcertificate-$1 NOT found in config.xml, is this correct????"
    DOMAININCONFIGXML=0
fi



if grep $ENCRT /conf/config.xml > /dev/null; then
	echo "+ Certficate already in config.xml"
else
        if [[ $DOMAININCONFIGXML == 1 ]]; then
		echo "+ Replacing pattern.sub in conig.xml and reloading webGUI"
		cp /conf/config.xml /tmp/config.xml && sed -f /tmp/pattern.sub < /tmp/config.xml > /conf/config.xml && rm /tmp/config.cache && /etc/rc.restart_webgui	
	else
		echo "!!! Not replacing domain, since it's not in your config.xml"
	fi
fi

echo "+ Done"
echo 
