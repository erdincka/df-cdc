FROM maprtech/dev-sandbox-container:latest

LABEL com.hpe.version="0.0.1-beta"
LABEL vendor=HPE

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git python3-dev gcc tree locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8

# fix init-script
RUN sed -i '/after cldb /a     sleep 30; echo mapr | maprlogin password -user mapr' /usr/bin/init-script

EXPOSE 9443 8443 12443 2222 8047 9995

COPY entrypoint.sh /
COPY . /app/

ENV MAPR_HOME=/opt/mapr

# ARG MAPR_REPO=https://package.ezmeral.hpe.com/releases/
ARG MAPR_REPO=http://10.1.1.4/mapr

WORKDIR /app
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_9.3.0-1ubuntu22.04_all.deb
RUN dpkg -i ./mysql-connector-j_9.3.0-1ubuntu22.04_all.deb

# Install and configure NiFi with CDC support
# RUN sed -i 's|dfaf.mip.storage.hpecorp.net/artifactory/list/prestage/releases|10.1.1.4/mapr|g' /etc/apt/sources.list.d/mapr.list
# Remove dev repo
RUN sed -i '/dfaf.mip.storage.hpecorp.net/d' /etc/apt/sources.list.d/mapr.list
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-nifi_1.28.0.0.202504110639_all.deb
RUN dpkg -i ./mapr-nifi_1.28.0.0.202504110639_all.deb
RUN wget -P /opt/mapr/nifi/nifi-1.28.0/extensions https://repo1.maven.org/maven2/org/apache/nifi/nifi-cdc-mysql-nar/1.28.0/nifi-cdc-mysql-nar-1.28.0.nar
# Set NiFi credentials
RUN /opt/mapr/nifi/nifi-1.28.0/bin/nifi.sh set-single-user-credentials "admin" "Admin123.Admin123." 

# Install and configure Hive MS
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-hive_3.1.3.750.202504031243_all.deb
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-hivemetastore_3.1.3.750.202504031243_all.deb
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-hiveserver2_3.1.3.750.202504031243_all.deb
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-hivewebhcat_3.1.3.750.202504031243_all.deb
RUN dpkg -i ./mapr-hive_3.1.3.750.202504031243_all.deb ./mapr-hiveserver2_3.1.3.750.202504031243_all.deb ./mapr-hivemetastore_3.1.3.750.202504031243_all.deb ./mapr-hivewebhcat_3.1.3.750.202504031243_all.deb
COPY hive-site.xml /opt/mapr/hive/hive-3.1.3/conf/hive-site.xml

# Configure Hive for use with MYSQL
RUN ln -s /usr/share/java/mysql-connector-java-9.3.0.jar /opt/mapr/hive/hive-3.1.3/lib/mysql-connector-java.jar
RUN apt install -yq mysql-server
COPY mysqld.cnf /etc/mysql/conf.d/mysqld.cnf

### Configure zeppelin
RUN wget "$MAPR_REPO"/MEP/MEP-9.4.0/ubuntu/mapr-zeppelin_0.10.1.200.202504140840_all.deb
RUN dpkg -i ./mapr-zeppelin_0.10.1.200.202504140840_all.deb
COPY CDC_Dashboard.zpln /opt/mapr/zeppelin/zeppelin-0.10.1/notebook/

RUN rm *.deb

