#Script de instalación de Gitlab en Docker-compose
#Ya modificado el cambio de puerto y comentada la url externa
#Falta de errores aún por confirmar!!!

#!/bin/sh
apt-get update  # To get the latest package lists
sudo apt-get remove docker docker-engine docker.io -y
sudo apt-get install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual -y
sudo apt-get update -y
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y
sudo apt-get update -y
sudo apt-get install docker-ce -y
sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl https://raw.githubusercontent.com/Mniac/Gitlab/master/docker-compose.yml > docker-compose.yml
docker-compose up -d

