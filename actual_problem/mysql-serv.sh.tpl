#!/bin/bash

apt update -y
apt upgrade -y
apt install -y mysql-server
mysql -u root -e "CREATE USER '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${db_user}'@'%';"
mysql -u root -e "CREATE DATABASE ${db_database};"
grep 'mysqlx-bind-address' -P -R -I -l  /etc/mysql/mysql.conf.d/mysqld.cnf | xargs sed -i 's/mysqlx-bind-address/#mysqlx-bind-address/g'
grep 'bind-address' -P -R -I -l  /etc/mysql/mysql.conf.d/mysqld.cnf | xargs sed -i 's/bind-address/#bind-address/g'
service mysql restart
curl -sfL https://get.k3s.io | sh -s - server --datastore-endpoint="mysql://${db_user}:${db_pass}@tcp(localhost:3306)/${db_database}"
k3s kubectl get node
