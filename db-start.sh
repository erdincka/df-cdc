#!/usr/bin/env bash

echo """
  [mysqld]
  server_id = 1
  log_bin = delta
  binlog_format=row
  binlog_do_db = demodb
""" > /etc/mysql/conf.d/mysqld.cnf

echo """
user=root
password=Admin123.
""" > /etc/mysql/conf.d/client.cnf

mysql -u root < /app/create-demodb.sql

