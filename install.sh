#!/bin/sh

#1 : organization url
#2 : pat token
#3 : agent name
#4 : project name
#5 : user name

cd /home/$5
mkdir agent
cd agent

#Install agent
AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
wget -O agent.tar.gz ${AGENTURL} 
tar zxvf agent.tar.gz
chmod -R 777 .
./bin/installdependencies.sh
sudo -u $5 ./config.sh --unattended --url $1 --auth pat --token $2 --agent $3 --acceptTeeEula --work ./_work --projectname $4
./svc.sh install
./svc.sh start

#Install terraform
apt -y install software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt -y update 
apt -y install terraform

#Install azure-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#Install maven + unzip
apt -y install unzip maven

#Install sonarqube
cd /home/$5
mkdir /opt/sonarqube
chown $5 /opt/sonarqube
chgrp $5 /opt/sonarqube
wget -O sonarqube.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.0.45539.zip
sudo -u $5 unzip sonarqube.zip -d /opt/sonarqube
rm sonarqube.zip
cd /opt/sonarqube/sonarqube-9.0.0.45539/bin/linux-x86-64
sudo -u $5 ./sonar.sh console
return 0
