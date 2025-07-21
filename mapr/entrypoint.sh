#!/usr/bin/env bash

echo "[ $(date) ] Starting container configuration, watch logs and be patient, this will take a while!"

# Start MySQL
usermod -d /var/lib/mysql/ mysql
service mysql start
# Prepare DB for Hive
mysql -u root <<EOD
    CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'Admin123.';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1';
    FLUSH PRIVILEGES;
EOD

# Remove the while loop at the end so we can continue with the rest of the default init-script
sed -i '1,/This container IP/!d' /usr/bin/init-script
echo "[ $(date) ] Data Fabric configuring, this will take some time..."
/usr/bin/init-script 2>&1 > /root/configure-$(date +%Y%m%d_%H%M%S).log
echo "[ $(date) ] Data Fabric configuration is complete, preparing for demo..."

# Obtain ticket for mapr user
echo mapr | sudo -u mapr maprlogin password

# Set NiFi credentials
/opt/mapr/nifi/nifi-"${NIFI_VERSION}"/bin/nifi.sh set-single-user-credentials "${NIFI_USER}" "${NIFI_PASSWORD}"

if [ -n "${NIFI_WEB_PROXY_HOST}" ]; then
    sed -i "s|nifi.web.proxy.host=.*$|nifi.web.proxy.host=${NIFI_WEB_PROXY_HOST}|" /opt/mapr/nifi/nifi-${NIFI_VERSION}/conf/nifi.properties
    /opt/mapr/nifi/nifi-1.28.0/bin/nifi.sh restart 2>&1 >> /root/nifi-restart.log
    echo "[ $(date) ] NiFi set up to use proxy $NIFI_WEB_PROXY_HOST"
fi

# Create demo table in MySQL
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
access_key=$(echo "$AWS_CREDS" | grep -v aws_access_key_id | awk '{ print $1 }')
secret_key=$(echo "$AWS_CREDS" | grep -v aws_secret_access_key | awk '{ print $2 }')
mkdir -p /home/mapr/.aws
echo """
[default]
aws_access_key_id = ${access_key}
aws_secret_access_key = ${secret_key}
""" > /home/mapr/.aws/credentials
chown -R mapr:mapr /home/mapr/.aws/

# Create bucket
/opt/mapr/bin/mc alias set df https://mapr.demo:9000 $access_key $secret_key
/opt/mapr/bin/mc mb df/demobk
/opt/mapr/bin/mc mb df/demobk/staging

# Create Iceberg table on S3 bucket
/opt/mapr/spark/spark-3.5.5/bin/pyspark \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.9.2 < ./create_iceberg_table.py > /dev/null

# Mount locally
mount -t nfs -o nolock mapr:/mapr /mapr

echo "[ $(date) ] CREDENTIALS:"
# echo "Hive Credentials: hive/Admin123."
echo "NiFi: ${NIFI_USER}/${NIFI_PASSWORD}"
echo "Cluster Admin: mapr/mapr"
echo "MySQL: root/Admin123."
echo "S3 Access Key: ${access_key}"
echo "S3 Secret Key: ${secret_key}"

# TODO: Upload NiFi template via REST call

echo "[ $(date) ] Ready!"
sleep infinity # just in case, keep container running
