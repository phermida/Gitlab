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
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - -y
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y
sudo apt-get update -y
sudo apt-get install docker-ce -y
sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose -y
sudo chmod +x /usr/local/bin/docker-compose -y
echo "web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  # environment:
    # GITLAB_OMNIBUS_CONFIG: |
      # external_url 'https://gitlab.example.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '80:80'
    - '443:443'
    - '26:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'" > docker-compose.yml -y
docker-compose up -d -y

