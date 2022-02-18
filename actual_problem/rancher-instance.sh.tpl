#!/bin/bash

apt update -y
apt upgrade -y
curl -sfL https://get.k3s.io | sh -s - server --datastore-endpoint="mysql://${db_user}:${db_pass}@tcp(${db_hostname}:3306)/${db_database}"
cat <<EOF > /root/test.txt
${db_user}
${db_pass}
${db_hostname}
${db_database}
EOF
