#!/bin/bash

# Archivo de log
LOG_FILE="/var/log/user-data.log"

# Redirigir toda la salida a este archivo de log
exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "User Data script started at $(date)" | sudo tee -a $LOG_FILE

# Esperar a que yum no esté bloqueado
while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do
    echo "Yum is being used by another process, waiting..." | sudo tee -a $LOG_FILE
    sleep 5
done

# Actualizar el sistema
echo "Updating system packages..." | sudo tee -a $LOG_FILE
sudo yum update -y | sudo tee -a $LOG_FILE

# Instalar Node.js y Git
echo "Installing Node.js and Git..." | sudo tee -a $LOG_FILE
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash - | sudo tee -a $LOG_FILE
sudo yum install -y nodejs git | sudo tee -a $LOG_FILE

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
sudo git clone https://github.com/backstage/backstage.git /home/ec2-user/backstage | sudo tee -a $LOG_FILE

# Instalar dependencias de Backstage
echo "Installing Backstage dependencies..." | sudo tee -a $LOG_FILE
cd /home/ec2-user/backstage && sudo yarn install | sudo tee -a $LOG_FILE

# Iniciar Backstage en segundo plano
echo "Starting Backstage..." | sudo tee -a $LOG_FILE
sudo yarn dev &

echo "User Data script finished at $(date)" | sudo tee -a $LOG_FILE