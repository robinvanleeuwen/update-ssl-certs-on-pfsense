#!/usr/local/bin/bash

OPENSSL=`which openssl`

source /usr/local/etc/dehydrated/config

for i in `cat $DOMAINS_TXT`;do 

   /opt/update-ssl-certs-on-pfsense/update-cert.sh $i
	
done

