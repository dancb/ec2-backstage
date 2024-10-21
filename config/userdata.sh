#!/bin/bash

# Archivo de log
LOG_FILE="/var/log/user-data.log"

# Redirigir toda la salida a este archivo de log
exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "User Data script started at $(date)" | sudo tee -a $LOG_FILE

# Actualizar el sistema
echo "Updating system packages..." | sudo tee -a $LOG_FILE
sudo apt-get update -y | sudo tee -a $LOG_FILE
sudo apt-get upgrade -y | sudo tee -a $LOG_FILE

# Instalar Node.js 18.x y Git
echo "Installing Node.js 18.x and Git..." | sudo tee -a $LOG_FILE
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - | sudo tee -a $LOG_FILE
sudo apt-get install -y nodejs git | sudo tee -a $LOG_FILE

# Verificar la instalación de Node.js
echo "Node.js version:" | sudo tee -a $LOG_FILE
node -v | sudo tee -a $LOG_FILE

# Verificar la instalación de Git
echo "Git version:" | sudo tee -a $LOG_FILE
git --version | sudo tee -a $LOG_FILE

# Instalar Yarn
echo "Installing Yarn..." | sudo tee -a $LOG_FILE
sudo npm install --global yarn | sudo tee -a $LOG_FILE

# Verificar la instalación de Yarn
echo "Yarn version:" | sudo tee -a $LOG_FILE
yarn --version | sudo tee -a $LOG_FILE

# Clonar el repositorio Backstage
echo "Cloning the Backstage repository..." | sudo tee -a $LOG_FILE
sudo git clone https://github.com/backstage/backstage.git /home/ubuntu/backstage | sudo tee -a $LOG_FILE

# Instalar dependencias de Backstage
echo "Installing Backstage dependencies..." | sudo tee -a $LOG_FILE
cd /home/ubuntu/backstage && sudo yarn install | sudo tee -a $LOG_FILE

# Iniciar Backstage en segundo plano
# echo "Starting Backstage..." | sudo tee -a $LOG_FILE
# sudo yarn dev &

echo "User Data script finished at $(date)" | sudo tee -a $LOG_FILE