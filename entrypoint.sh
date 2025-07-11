#!/usr/bin/env bash

# Prepare DB for Hive
service mysql start
mysql -u root <<EOD
    CREATE DATABASE IF NOT EXISTS metastore;
    CREATE USER IF NOT EXISTS 'hive'@'%' IDENTIFIED BY 'Admin123.';
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';
    GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'%';
    FLUSH PRIVILEGES;
EOD
/opt/mapr/hive/hive-3.1.3/bin/schematool -dbType mysql -initSchema

# /opt/mapr/nifi/nifi-1.28.0/bin/nifi.sh restart

sed -i '1,/This container IP/!d' /usr/bin/init-script # remove the while loop at the end
/usr/bin/init-script
echo "[ $(date) ] System initialized, preparing for demo..."

# Create Hive table for users
hive --service beeline -u "jdbc:hive2://localhost:10000/default;ssl=true;auth=maprsasl" -f /app/create-table.hiveql

echo """
[client]
user=root
password=Admin123.
""" > /etc/mysql/conf.d/client.cnf
mysql -u root < /app/create-demodb-tables.sql
echo "Hive table for demo `users` created."

# Upload NiFi template via REST call

echo 
echo "Hive Credentials: hive/Admin123."
echo "NiFi Credentials: admin/Admin123.Admin123."
echo "Cluster Admin Credentials: mapr/mapr"
echo "MySQL DB Credentials: root/Admin123."
echo "Ready!"

sleep infinity # just in case, keep container running
