#!/usr/bin/env bash

echo "[ $(date) ] Starting container configuration, watch logs and be patient, this will take a while!"

# Prepare DB for Hive
usermod -d /var/lib/mysql/ mysql
service mysql start
mysql -u root <<EOD
    CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'Admin123.';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1';
    DROP DATABASE IF EXISTS metastore;
    CREATE DATABASE metastore;
    DROP USER IF EXISTS hive@'%';
    DROP USER IF EXISTS hive@'localhost';
    CREATE USER 'hive'@'%' IDENTIFIED BY 'Admin123.';
    CREATE USER 'hive'@'localhost' IDENTIFIED BY 'Admin123.';
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'localhost';
    GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'%';
    GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'localhost';
    FLUSH PRIVILEGES;
EOD

sed -i "s|nifi.web.proxy.host=.*$|nifi.web.proxy.host=${NIFI_WEB_PROXY_HOST}|" /opt/mapr/nifi/nifi-${NIFI_VERSION}/conf/nifi.properties

# Remove the while loop at the end so we can continue with the rest of the default init-script
sed -i '1,/This container IP/!d' /usr/bin/init-script
/usr/bin/init-script
echo "[ $(date) ] Data Fabric configured, preparing for demo..."

/opt/mapr/hive/hive-3.1.3/bin/schematool -dbType mysql -initSchema
# /opt/mapr/hive/hive-3.1.3/bin/hive.sh restart
echo "[ $(date) ] Hive configured to use MySQL DB"

# Create Hive table for users
sleep 120
hive --service beeline -u "jdbc:hive2://`hostname -f`:10000/default;ssl=true;auth=maprsasl" -f /app/create-table.hiveql

# /opt/mapr/nifi/nifi-1.28.0/bin/nifi.sh restart

echo """
[client]
user=root
password=Admin123.
""" > /etc/mysql/conf.d/client.cnf
mysql -u root < /app/create-demodb-tables.sql
echo "[ $(date) ] Hive table for demo `users` created."

# Upload NiFi template via REST call

echo "[ $(date) ] CREDENTIALS:"
echo "Hive Credentials: hive/Admin123."
echo "NiFi Credentials: admin/Admin123.Admin123."
echo "Cluster Admin Credentials: mapr/mapr"
echo "MySQL DB Credentials: root/Admin123."

# Setup S3
cp /opt/mapr/conf/ca/chain-ca.pem /root/.mc/certs/CAs/
echo "S3 Credentials:"
maprcli s3keys generate -domainname primary -accountname default -username mapr

echo "[ $(date) ] Ready!"
sleep infinity # just in case, keep container running
