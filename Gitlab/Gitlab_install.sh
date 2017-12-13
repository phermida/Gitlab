#!/bin/sh
EXTERNAL_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

apt-get update -y
apt-get install docker.io -y
apt-get install docker-compose -y
cp -r initconfig /srv/gitlab/
if [ ! -f "/srv/gitlab/data/.ssh/authorized_keys" ]; then mkdir -p /srv/gitlab/data/.ssh; touch /srv/gitlab/data/.ssh/authorized_keys; chown 998:998 /srv/gitlab/data/.ssh/authorized_keys; fi
sed -i $'s/Port 22$/Port 2222$/g' /etc/ssh/sshd_config
service ssh restart
#echo "XXX.XXX.XXX.XXX:/gitlab /srv/gitlab nfs4" >> /etc/fstab
docker-compose up -d
while [[ ! $(curl -sL -w "%{http_code}\\n" "http://$EXTERNAL_IP" -o /dev/null --connect-timeout 3 --max-time 5) == "200" ]];  do echo -e ".\c"; sleep 1; done
echo -e " Done!\c"
echo ""
docker exec -ti gitlab_web_1 service ssh restart
