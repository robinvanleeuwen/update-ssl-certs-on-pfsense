#!/usr/local/bin/bash

# For all domains in /opt/dehydrated/domains.txt update the
# certificate if neccesary and reload HA Proxy


source /usr/local/etc/dehydrated/config

for i in `cat $DOMAINS_TXT`;do 

   /opt/update-ssl-certs-on-pfsense/update-cert.sh $i
	
done

echo "Restarting HA-Proxy"
/usr/local/etc/rc.d/haproxy.sh restart
