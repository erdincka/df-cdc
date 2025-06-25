# NiFi for CDC


Blog: https://community.cloudera.com/t5/Community-Articles/Change-Data-Capture-CDC-with-Apache-NiFi-Part-1-of-3/ta-p/246623

## Setup DB (MySQL/MariaDB)

Install mysql server.

`apt install mysql`

Modify to enable binlog (/etc/mysql/conf.d/mysqld.cnf):

```ini
[mysqld]
server_id = 1
log_bin = delta
binlog_format=row
binlog_do_db = demodb
```

Create database and user:

`mysql -u root -p` and provide root password.

Optionally, create a user.

```sql
CREATE DATABASE demodb;

USE demodb;

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` text,
  `first` text,
  `last` text,
  `street` text,
  `city` text,
  `state` text,
  `postcode` text,
  `country` text,
  `gender` text,
  `email` text,
  `uuid` text,
  `username` text,
  `password` text,
  `phone` text,
  `cell` text,
  `dob` datetime NULL DEFAULT NULL,
  `registered` datetime NULL DEFAULT NULL,
  `large` text,
  `medium` text,
  `thumbnail` text,
  `nat` text,
  PRIMARY KEY (`id`),
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

```

### Insert data into MySQL

API call to get a new list of users: https://randomuser.me/api/?results=10&format=csv

or use `python3 users.py --count <number_of_users>`


## Setup Data Fabric

<!-- ### Setup Streams

`maprcli stream create -path /apps/mystream -ttl 86400 -compression lz4 -produceperm p -consumeperm p -topicperm p` -->


<!-- ### Setup HiveMetastore for Iceberg Tables using S3 for storage
 -->


## Setup NiFi

Download and import template: `wget https://community.cloudera.com/legacyfs/online/attachments/20483-cdc-mysql-replication.xml`

<!-- * Modified the template to write data into Kafka topic (replacing last processor). -->
* Modified the template to write inserts into Hive table and other operations (delete/update...) to S3 bucket (demobk).


### Install/Enable MySQL CDC Extension for NiFi

Place connector into: /opt/mapr/nifi/nifi-1.28.0/extensions
`wget -P /opt/mapr/nifi/nifi-1.28.0/extensions https://repo1.maven.org/maven2/org/apache/nifi/nifi-cdc-mysql-nar/1.28.0/nifi-cdc-mysql-nar-1.28.0.nar`


### Install MySQL JDBC client

from: https://dev.mysql.com/downloads/connector/j/

`wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-9.3.0-1.el8.noarch.rpm`

or

`wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_9.3.0-1ubuntu22.04_all.deb`

and it should be available in `/usr/share/java/mysql-connector-j-9.3.0.jar`, this location will be updated in the processor configuration in NiFi.



### Create Hive Table (if using Hive)

CREATE TABLE web_log(viewTime INT, userid BIGINT, url STRING, referrer STRING, ip STRING) 
PARTITIONED BY (vendor_id bigint) STORED BY ICEBERG;

```hive
CREATE TABLE users (
  id INT,
  title STRING,
  first STRING,
  last STRING,
  street STRING,
  city STRING,
  state STRING,
  postcode STRING,
  country STRING,
  gender STRING,
  email STRING,
  uuid STRING,
  username STRING,
  password STRING,
  phone STRING,
  cell STRING,
  dob DATE,
  registered DATE,
  large STRING,
  medium STRING,
  thumbnail STRING,
  nat STRING
);

```


### Run NiFi flow - forward inserts/updates to Kafka topic

Only inserts are replicated in this version.

Other SQL statements are forward to another route, where they will be converted to parquet and put into S3 bucket.


### Setup Dashboard (Superset)

No proper hive connector available, looking for alternatives with prestodb. It can connect to Hive and provide endpoint to Superset. Though couldn't get presto hive connector working with DF Hive Server2 too.


### Spark Streaming consumption from Kafka topic?

Using notebook or Airflow?
