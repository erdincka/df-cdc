Docker pull :
docker pull sparkflows/fire:3.2.1_3.2.16

Docker run :

docker run -p 8080:8080 -p 9443:9443 -e FIRE_VERSION=3.1.0 -e KEYSTORE_PASSWORD=12345678 -e FIRE_HTTP_PORT=8080 -e FIRE_HTTPS_PORT=9443 sparkflows/fire:py_3.5.2_3.3.1


More details can be found here :

https://docs.sparkflows.io/en/latest/installation/installation/index.html

Other helpful docker commands :
docker start container id  (to restart a container)
docker attach container id (to attach to a running container)


To login into Sparkflows application :
Open your web browser and navigate to URL :

http://<machine_ip>:8080

Login with :

admin/admin OR test/test


## Enable Configurations

- AWS: S3

- Module: JDBC Browser, Data Quality, Data Catalog, CDC

- Connection: Livy


### Hive connection:

Administration - Connections - Add connection

jdbc:hive2://vm-10-1-1-20.kayalab.uk:10000/default;ssl=true;auth=maprsasl;sslTrustStore=/root/ssl_truststore;trustStorePassword=7y_8ZMelgqSqxug8goAFJovlS1_v7_ee;user=mapr;password=mapr

### Mysql connection:


cp /usr/share/java/mysql-connector-java-9.3.0.jar /usr/local/fire-3.3.1_spark_3.5.2/fire-server-lib/

Administration - Connections - Add connection

jdbc:mysql://db.kayalab.uk:3306/
