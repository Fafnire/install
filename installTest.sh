#!/bin/sh

#1 : organization url
#2 : pat token
#3 : agent name
#4 : environment name
#5 : project name
#6 : user name

cd /home/$6
mkdir agent
cd agent

#Install agent
AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
wget -O agent.tar.gz ${AGENTURL} 
tar zxvf agent.tar.gz
chmod -R 777 .
./bin/installdependencies.sh
sudo -u $6 ./config.sh --unattended --url $1 --auth pat --token $2 --agent $3 --acceptTeeEula --work ./_work --environment --environmentname $4 --projectname $5 --runasservice
./svc.sh install
./svc.sh start

#Install docker
apt -y update
apt -y install apt-transport-https ca-certificates curl gnupg lsb-release gnupg2 pass
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt -y update
apt -y install docker-ce docker-ce-cli containerd.io docker-compose

#Install azure-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
exit 0
