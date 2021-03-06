#!/bin/sh

if [ -z "$conf_NAME" ]; then
	echo "-e conf_NAME is missing. Exiting"
	exit 1
fi

if [ -z "$conf_CONTACT" ]; then
        echo "-e conf_CONTACT is missing. Exiting"
        exit 1
fi

sed -i '17s/.*/      "INSTANCE_NAME"   : '"'$conf_NAME'"',/' /opt/egem/egem-net-intelligence-api/app.json
sed -i '18s/.*/      "CONTACT_DETAILS" : '"'$conf_CONTACT'"',/' /opt/egem/egem-net-intelligence-api/app.json
sed "s/'/\"/g" /opt/egem/egem-net-intelligence-api/app.json

cd /opt/egem/egem-net-intelligence-api && pm2 start app.json

MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')

if [ $MEMORY -lt 2000000 ]; then
	echo "The host system has less than 2 Gb of RAM. Starting with --cache 256"
	CACHE='--cache 256'
else
	if [ $MEMORY -lt 4000000 ]; then
		echo "The host system has less than 4 Gb of RAM. Starting with --cache 512"
		CACHE='--cache 512'
	fi
fi

egem --datadir /opt/egem/live-net/ --maxpeers 100 --rpc $CACHE
