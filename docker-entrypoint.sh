#!/bin/sh

if [ -z "$conf_NAME" ]; then
	echo "-e conf_NAME is missing. Exiting"
	exit 1
fi

if [ -z "$conf_CONTACT" ]; then
        echo "-e conf_CONTACT is missing. Exiting"
        exit 1
fi

sed -i '17s/.*/      "INSTANCE_NAME"   : '"'$conf_NAME'"',/' /opt/egem-net-intelligence-api/app.json
sed -i '18s/.*/      "CONTACT_DETAILS" : '"'$conf_CONTACT'"',/' /opt/egem-net-intelligence-api/app.json
sed "s/'/\"/g" /opt/egem-net-intelligence-api/app.json

cd /opt/egem-net-intelligence-api && pm2 start app.json

egem --datadir /opt/live-net/ --maxpeers 100 --rpc
