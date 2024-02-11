#! /usr/bin/env bash

set -euo pipefail

echo "[INFO] Installing Python"

sudo apt update
sudo apt install python3-pip -y

echo "[INFO] Installing UnixODBC"

sudo apt-get update && sudo apt-get install -y unixodbc unixodbc-dev
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17

echo "[INFO] Installing pm2"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install pm2 -g

echo "[INFO] Setting up Backend Application for First Time"

sudo -u devopsadmin bash -c '
cd /home/devopsadmin/
git clone https://github.com/devopsinsiders/todoapp-backend-py.git
cd /home/devopsadmin/todoapp-backend-py
echo CONNECTION_STRING="Driver={ODBC Driver 17 for SQL Server};Server=tcp:devopsinssrv1.database.windows.net,1433;Database=todoappdb;Uid=devopsadmin;Pwd=P@ssw01rd@123;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;" > .env
pip install -r requirements.txt
pm2 start app.py
'
