#!/bin/bash

# Archivo de log opcional
LOG_FILE="/var/log/user-data.log"
exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "El script de instalación comenzó en $(date)"

########## Esperando a que apt-get esté disponible ##########
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
   echo "Esperando a que apt-get esté disponible..." | sudo tee -a $LOG_FILE
   sleep 5
done

########## Actualizando los paquetes del sistema ##########
echo "Actualizando los paquetes del sistema..."
sudo apt-get update -y
sudo apt-get upgrade -y

########## Instalando Node.js 18.x y npm ##########
echo "Instalando Node.js 18.x y npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

########## Instalando Yarn ##########
echo "Instalando Yarn..."
sudo npm install --global yarn

########## Instalando Git ##########
echo "Instalando Git..."
sudo apt-get install -y git

########## Instalando Docker ##########
echo "Instalando Docker..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Agregar usuario actual al grupo Docker para usar Docker sin sudo
sudo usermod -aG docker ${USER}

########## Imprimiendo las versiones instaladas ##########
echo "Verificando versiones instaladas..."
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "Yarn version: $(yarn --version)"
echo "Git version: $(git --version)"
echo "Docker version: $(docker --version)"

echo "El script de instalación finalizó en $(date)"
