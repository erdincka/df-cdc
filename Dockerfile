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

COPY mapr-start.sh /
COPY . /app/

ENV MAPR_HOME=/opt/mapr

WORKDIR /app

RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_9.3.0-1ubuntu22.04_all.deb
RUN dpkg -i ./mysql-connector-j_9.3.0-1ubuntu22.04_all.deb

