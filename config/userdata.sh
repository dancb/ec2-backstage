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

########## Instalando PostgreSQL ##########
echo "Instalando PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Iniciar el servicio de PostgreSQL y habilitarlo para que se inicie en el arranque
sudo systemctl start postgresql
sudo systemctl enable postgresql


########## Creación de usuario y base de datos de ejemplo (opcional) ##########
# Cambia el directorio antes de ejecutar comandos como el usuario postgres
cd /tmp

# Crear un nuevo usuario y base de datos de ejemplo (opcional)
# Nota: Puedes modificar estos valores según sea necesario.
sudo -u postgres psql -c "CREATE USER daniel WITH PASSWORD 'daniel';"
sudo -u postgres psql -c "CREATE DATABASE mydb OWNER daniel;"

########## Imprimiendo las versiones instaladas ##########
echo "Verificando versiones instaladas..."
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "Yarn version: $(yarn --version)"
echo "Git version: $(git --version)"
echo "Docker version: $(docker --version)"
echo "PostgreSQL version: $(psql --version)"

echo "El script de instalación finalizó en $(date)"
