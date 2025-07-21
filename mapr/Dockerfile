FROM maprtech/dev-sandbox-container:7.10.0_9.4.0_ubuntu20

LABEL com.hpe.version="0.0.5"
LABEL vendor=HPE

ARG MAPR_REPO=https://package.ezmeral.hpe.com/releases/
ARG UBUNTU_VERSION=22.04
ARG NIFI_VERSION=1.28.0
ARG MYSQL_CONNECTOR_VERSION=9.3.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y git python3-dev gcc tree locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV MAPR_HOME=/opt/mapr

WORKDIR /app
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_$MYSQL_CONNECTOR_VERSION-1ubuntu"${UBUNTU_VERSION}"_all.deb
RUN dpkg -i ./mysql-connector-j_$MYSQL_CONNECTOR_VERSION-1ubuntu"${UBUNTU_VERSION}"_all.deb

# Replace dev repo
RUN sed -i "s|http://dfaf.mip.storage.hpecorp.net/artifactory/list/prestage/releases|${MAPR_REPO}|g" /etc/apt/sources.list.d/mapr.list
RUN apt update && apt upgrade -y && apt install -y \
    mapr-nifi \
    mapr-drill \
    mysql-server
    # mapr-spark \
    # mapr-spark-thriftserver \
    # mapr-grafana \
    
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

EXPOSE 8443 2222 3000 12443 8047

# fix init-script
RUN sed -i '/after cldb /a     sleep 30; echo mapr | maprlogin password -user mapr' /usr/bin/init-script

# Add CDC support to NiFi
RUN wget -P /opt/mapr/nifi/nifi-"${NIFI_VERSION}"/extensions https://repo1.maven.org/maven2/org/apache/nifi/nifi-cdc-mysql-nar/"${NIFI_VERSION}"/nifi-cdc-mysql-nar-"${NIFI_VERSION}".nar
# Enable MySQL CDC recording
COPY mysqld.cnf /etc/mysql/conf.d/mysqld.cnf

# Create DB tables for demo
COPY create-demodb-tables.sql /app/

COPY entrypoint.sh /

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
COPY pyproject.toml uv.lock .python-version /app/
COPY users.py /app/
COPY ingest_to_iceberg.py /app/
COPY invoke-pyspark.sh /app/
COPY create_iceberg_table.py /app/
RUN /root/.local/bin/uv sync
# RUN /root/.local/bin/uv lock

RUN wget -P /opt/mapr/spark/spark-3.5.5/jars https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.9.2/iceberg-spark-runtime-3.5_2.12-1.9.2.jar

# Cleanup
RUN rm ./mysql-connector-j_"${MYSQL_CONNECTOR_VERSION}"-1ubuntu"${UBUNTU_VERSION}"_all.deb
