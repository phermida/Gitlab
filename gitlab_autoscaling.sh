#Preparing the environment
#!/bin/bash

#1. Login to a new Linux-based machine that will serve as a bastion server and where Docker will spawn new machines from
apt-get update
#2. Install GitLab Runner following the GitLab Runner installation documentation
#2.1 Install Docker first:
curl -sSL https://get.docker.com/ | sh
#2.2 Docker as the method of spawning Runners:
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest -y
  
#Después de esto se ejecutará los siguientes comandos dentro del docker?  
docker exec -it gitlab-runner bash  

#3. Install Docker Machine following the Docker Machine installation documentation
apt-get update
#3.1 Download the Docker Machine binary and extract it to your PATH.
curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
chmod +x /tmp/docker-machine &&
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
#3.2 Checking docker-machine version
docker-machine version
#3.3 Confirm the version and save scripts:
cd ~/etc/bash_completion.d
scripts=( docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash ); for i in "${scripts[@]}"; do sudo wget https://raw.githubusercontent.com/docker/machine/v0.13.0/contrib/completion/bash/${i} -P /etc/bash_completion.d; done
#3.4 To enable the docker-machine shell prompt, add $(__docker_machine_ps1) to your PS1 setting in ~/.bashrc
cd
echo "PS1='[\u@\h \W$(__docker_machine_ps1)]\$ '" > ~/.bashrc

#4. Register the runner
docker exec -it gitlab-runner gitlab-runner register
#Complete with echoes

#5. OpenNebula plugin
#5.1.1 Install GO
apt-get update
#Golang-go1.6 on Ubuntu14.04
sudo apt-get update
sudo apt-get -y upgrade
sudo curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
sudo tar -xvf go1.6.linux-amd64.tar.gz
#/usr o /usr/local?
sudo mv go /usr/local
#Setting up GOPATH 
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile
sudo apt-get install bzr -y
#5.1.2 Set GOPATH:
#Dont know if its the right order of commands
echo "export GOPATH=$HOME/work" > ~/.bash_profile
source ~/.bash_profile
export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)
export GOBIN=$HOME/work/bin
#5.1.3 Install GODEP
go get github.com/tools/godep
#5.2 Building the plugin binary
apt-get install gcc -y
go get github.com/OpenNebula/docker-machine-opennebula
cd $GOPATH/src/github.com/OpenNebula/docker-machine-opennebula
apt-get install make -y
make build
make install
#5.3 Set up ONE_AUTH and ONE_XMLRPC to point to the OpenNebula cloud
echo -e "export ONE_LOCATION=\nexport ONE_AUTH=$HOME/work/one_auth\nexport ONE_XMLRPC=http://nebula.cesga.es:2633/RPC2\nexport PATH=$HOME/work/bin:$PATH" >> ~/.bash_profile
source ~/.bash_profile
