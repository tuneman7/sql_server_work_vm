#!/bin/bash

apt update
apt install apt-utils -y
apt upgrade -y
apt install -y docker docker.io python3 python-is-python3 git jq nano curl zip python3-venv python3-pip postgresql-client-common postgresql-client gunicorn mysql-client lsof
groupadd docker
usermod -aG docker ubuntu
newgrp docker
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt install msodbcsql18 -y
ACCEPT_EULA=Y apt-get install mssql-tools18 unixodbc-dev -y
mkdir /data
chmod 777 -R /data
cd /data
git clone https://github.com/tuneman7/sql_server_work 
chmod 777 -R /data
cd /data/sql_server_work/
. up_all_svrs.sh >output.txt
