#Dockerfile with the full deployment of gitlab-runner+docker-machine+opennebula-plugin
FROM gitlab/gitlab-runner:v10.1.0

RUN apt-get update && \
curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
chmod +x /tmp/docker-machine && \
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

ENV PS1 '[\u@\h \W$(__docker_machine_ps1)]\$ '

RUN apt-get update && \
apt-get -y upgrade && \
apt-get install -y gcc make bzr && \
curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz && \
tar -xvf go1.6.linux-amd64.tar.gz && \
rm go1.6.linux-amd64.tar.gz && \
mv go /usr/local

ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH $HOME/work

#export GOBIN=$HOME/work/bin && \

RUN export PATH=$PATH:$(go env GOPATH)/bin && \
export GOPATH=$(go env GOPATH) && \
go get github.com/tools/godep && \
go get github.com/OpenNebula/docker-machine-opennebula && \
sed -i 's/err = vm.TerminateHard()/err = vm.Action("delete")/g' $GOPATH/src/github.com/OpenNebula/docker-machine-opennebula/opennebula.go && \
cd $GOPATH/src/github.com/OpenNebula/docker-machine-opennebula && \
make build && \
make install && \
#OpenNebula User+Password
echo "user:pass" > /work/one_auth

ENV ONE_AUTH $HOME/work/one_auth
ENV ONE_XMLRPC http://nebula.cesga.es:2633/RPC2
ENV PATH $HOME/work/bin:$PATH

EXPOSE 2633


CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]

#Al terminar, registrar el runner y añadir el driver a config.toml
#  [runners.machine]
#    IdleCount = 0
#    MachineDriver = "opennebula"
#    MachineName = "job-runner-%s"
#    MachineOptions = [
#      "opennebula-template-id=565"
#    ]
