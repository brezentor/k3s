#!/bin/bash
sleep 3m
scp -o "StrictHostKeyChecking no" -i /home/ubuntu/my-first-instance.pem ubuntu@$1:/var/lib/rancher/k3s/server/node-token /home/ubuntu/node-token
token=`cat /home/ubuntu/node-token`
k3s agent --server https://$1:6443 --token $token
cat <<EOF > /home/ubuntu/test.txt
$1
$token
EOF
