#!/usr/bin/env bash

sed -i '1,/This container IP/!d' /usr/bin/init-script # remove the while loop at the end
/usr/bin/init-script
echo "[ $(date) ] System initialized, preparing for demo..."


# Enable NiFi & CDC support
apt install -y mapr-nifi
wget -P /opt/mapr/nifi/nifi-1.28.0/extensions https://repo1.maven.org/maven2/org/apache/nifi/nifi-cdc-mysql-nar/1.28.0/nifi-cdc-mysql-nar-1.28.0.nar
# Reconfigure cluster for NiFi
/opt/mapr/server/configure.sh -R


# Create Hive table for users
hive --service beeline -u "jdbc:hive2://localhost:10000/default;ssl=true;auth=maprsasl" -f /app/create-table.hiveql


sleep infinity # just in case, keep container running
