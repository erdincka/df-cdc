#!/usr/bin/env bash

echo "[ $(date) ] Starting container configuration, watch logs and be patient, this will take a while!"

# Prepare DB for Hive
usermod -d /var/lib/mysql/ mysql
service mysql start 2>&1 > /dev/null
mysql -u root <<EOD
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'Admin123.';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
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

# Remove the while loop at the end so we can continue with the rest of the default init-script
sed -i '1,/This container IP/!d' /usr/bin/init-script
echo "[ $(date) ] Data Fabric configuring, this will take some time..."
/usr/bin/init-script 2>&1 > /root/configure-$(date +%Y%m%d_%H%M%S).log
echo "[ $(date) ] Data Fabric configuration is complete, preparing for demo..."

/opt/mapr/hive/hive-3.1.3/bin/schematool -dbType mysql -initSchema
# /opt/mapr/hive/hive-3.1.3/bin/hive.sh restart
echo "[ $(date) ] Hive configured to use MySQL DB, waiting for startup...."

# Obtain ticket for mapr user
echo mapr | sudo -u mapr maprlogin password

# Set NiFi credentials
/opt/mapr/nifi/nifi-"${NIFI_VERSION}"/bin/nifi.sh set-single-user-credentials "${NIFI_USER}" "${NIFI_PASSWORD}"

if [ -n "${NIFI_WEB_PROXY_HOST}" ]; then
    sed -i "s|nifi.web.proxy.host=.*$|nifi.web.proxy.host=${NIFI_WEB_PROXY_HOST}|" /opt/mapr/nifi/nifi-${NIFI_VERSION}/conf/nifi.properties
    /opt/mapr/nifi/nifi-1.28.0/bin/nifi.sh restart 2>&1 >> /root/nifi-restart.log
    echo "[ $(date) ] NiFi set up to use proxy $NIFI_WEB_PROXY_HOST"
fi

echo """
[client]
user=root
password=Admin123.
""" > /etc/mysql/conf.d/client.cnf
mysql -u root < /app/create-demodb-tables.sql
echo "[ $(date) ] MySQL demo table 'users' created."

# Setup S3
mkdir -p /root/.mc/certs/CAs/; cp /opt/mapr/conf/ca/chain-ca.pem /root/.mc/certs/CAs/
AWS_CREDS=$(maprcli s3keys generate -domainname primary -accountname default -username mapr)
access_key=$(echo "$AWS_CREDS" | grep -v accesskey | awk '{ print $1 }')
secret_key=$(echo "$AWS_CREDS" | grep -v accesskey | awk '{ print $2 }')
mkdir -p /home/mapr/.aws
echo """
[default]
    accessKey=${access_key}
    secretKey=${secret_key}
""" > /home/mapr/.aws/credentials
chown -R mapr:mapr /home/mapr/.aws/

# Create bucket
/opt/mapr/bin/mc alias set df https://mapr.demo.local:9000 $access_key $secret_key
/opt/mapr/bin/mc mb df/demobk

# Create Hive table for users
sleep 60; hive --service beeline -u "jdbc:hive2://`hostname -f`:10000/default;ssl=true;auth=maprsasl" -f /app/create-table.hiveql 2>&1 >> /root/hive-tablecreate.log

# Mount locally
mount -t nfs -o nolock mapr:/mapr /mapr

echo "[ $(date) ] CREDENTIALS:"
echo "Hive Credentials: hive/Admin123."
echo "NiFi Credentials: ${NIFI_USER}/${NIFI_PASSWORD}"
echo "Cluster Admin Credentials: mapr/mapr"
echo "MySQL DB Credentials: root/Admin123."
echo "S3 Credentials"
echo "S3 Access Key: ${access_key}"
echo "S3 Secret Key: ${secret_key}"

# TODO: Upload NiFi template via REST call

echo "[ $(date) ] Ready!"
sleep infinity # just in case, keep container running
