#! /usr/bin/env bash

set -euo pipefail

echo "[INFO] Installing Nginx"

sudo apt update
sudo apt install nginx -y