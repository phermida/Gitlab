#!/bin/bash

sudo su
apt-get update -y
apt-get install docker.io -y
apt-get install docker-compose -y
initDir='/srv/gitlab'
mv -r initconfig $initDir;
sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config
echo "XXX.XXX.XXX.XXX:/gitlab /srv/gitlab nfs4" >> /etc/fstab

