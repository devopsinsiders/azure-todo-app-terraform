#! /usr/bin/env bash

set -euo pipefail

echo "[INFO] Installing Python"

sudo apt update
sudo apt install python3 -y

echo "[INFO] Installing UnixODBC"

sudo apt-get update && sudo apt-get install -y unixodbc unixodbc-dev
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17

