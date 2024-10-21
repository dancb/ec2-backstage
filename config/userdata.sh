#!/bin/bash

# Archivo de log
LOG_FILE="/var/log/user-data.log"

# Redirigir toda la salida a este archivo de log
exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "El script de User Data inició en $(date)" | sudo tee -a $LOG_FILE

########## Actualizando los paquetes del sistema ##########
echo "########## Actualizando los paquetes del sistema..." | sudo tee -a $LOG_FILE
sudo apt-get update -y | sudo tee -a $LOG_FILE
sudo apt-get upgrade -y | sudo tee -a $LOG_FILE

########## Instalando NVM (Node Version Manager) ##########
echo "########## Instalando NVM (Node Version Manager)..." | sudo tee -a $LOG_FILE
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash | sudo tee -a $LOG_FILE
export NVM_DIR="$HOME/.nvm" | sudo tee -a $LOG_FILE
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" | sudo tee -a $LOG_FILE

########## Instalando Node.js versión 18.x usando NVM ##########
echo "########## Instalando Node.js versión 18.x usando NVM..." | sudo tee -a $LOG_FILE
nvm install 18 | sudo tee -a $LOG_FILE
nvm use 18 | sudo tee -a $LOG_FILE
nvm alias default 18 | sudo tee -a $LOG_FILE

# Verificar la instalación de Node.js
echo "########## Verificando la instalación de Node.js..." | sudo tee -a $LOG_FILE
node -v | sudo tee -a $LOG_FILE

########## Instalando Git ##########
echo "########## Instalando Git..." | sudo tee -a $LOG_FILE
sudo apt-get install -y git | sudo tee -a $LOG_FILE

# Verificar la instalación de Git
echo "########## Verificando la instalación de Git..." | sudo tee -a $LOG_FILE
git --version | sudo tee -a $LOG_FILE

########## Instalando Yarn ##########
echo "########## Instalando Yarn..." | sudo tee -a $LOG_FILE
sudo npm install --global yarn | sudo tee -a $LOG_FILE

# Verificar la instalación de Yarn
echo "########## Verificando la instalación de Yarn..." | sudo tee -a $LOG_FILE
yarn --version | sudo tee -a $LOG_FILE

########## Clonando el repositorio de Backstage ##########
echo "########## Clonando el repositorio de Backstage..." | sudo tee -a $LOG_FILE
sudo git clone https://github.com/backstage/backstage.git /home/ubuntu/backstage | sudo tee -a $LOG_FILE

########## Instalando dependencias de Backstage ##########
# echo "########## Instalando dependencias de Backstage..." | sudo tee -a $LOG_FILE
# cd /home/ubuntu/backstage && sudo yarn install | sudo tee -a $LOG_FILE

# Opción para iniciar Backstage (comentada)
# echo "########## Iniciando Backstage..." | sudo tee -a $LOG_FILE
# sudo yarn dev &

echo "El script de User Data finalizó en $(date)" | sudo tee -a $LOG_FILE
