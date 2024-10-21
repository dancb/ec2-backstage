#!/bin/bash

# Archivo de log
LOG_FILE="/var/log/user-data.log"

# Redirigir toda la salida a este archivo de log
exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "El script de User Data inició en $(date)" | sudo tee -a $LOG_FILE

########## Esperando a que apt-get esté disponible ##########
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
   echo "Esperando a que apt-get esté disponible..." | sudo tee -a $LOG_FILE
   sleep 5
done

########## Actualizando los paquetes del sistema ##########
echo "########## Actualizando los paquetes del sistema..." | sudo tee -a $LOG_FILE
sudo apt-get update -y | sudo tee -a $LOG_FILE
sudo apt-get upgrade -y | sudo tee -a $LOG_FILE

########## Instalando NVM (Node Version Manager) ##########
echo "########## Instalando NVM (Node Version Manager)..." | sudo tee -a $LOG_FILE
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash | sudo tee -a $LOG_FILE

# Cargar NVM en el shell actual y en todos los futuros shells
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" | sudo tee -a $LOG_FILE
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" | sudo tee -a $LOG_FILE

# Asegurarse de que NVM se cargue en futuros shells
echo 'export NVM_DIR="$HOME/.nvm"' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/ubuntu/.bashrc

# Cargar NVM en el shell del script para garantizar que funcione
source "$NVM_DIR/nvm.sh"

########## Instalando Node.js versión 18.x usando NVM ##########
echo "########## Instalando Node.js versión 18.x usando NVM..." | sudo tee -a $LOG_FILE
nvm install 18 | sudo tee -a $LOG_FILE
nvm use 18 | sudo tee -a $LOG_FILE
nvm alias default 18 | sudo tee -a $LOG_FILE

# Verificar la instalación de Node.js
echo "########## Verificando la instalación de Node.js..." | sudo tee -a $LOG_FILE
node -v | sudo tee -a $LOG_FILE
npm -v | sudo tee -a $LOG_FILE

########## Configurando npm para instalaciones globales ##########
# Crear directorio para instalaciones globales de npm en el home del usuario
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

# Actualizar el PATH para que npm global use el nuevo directorio
export PATH="$HOME/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> /home/ubuntu/.bashrc

########## Instalando Yarn ##########
echo "########## Instalando Yarn..." | sudo tee -a $LOG_FILE
npm install --global yarn | sudo tee -a $LOG_FILE

# Recargar el PATH para el script
source /home/ubuntu/.bashrc

# Verificar la instalación de Yarn
echo "########## Verificando la instalación de Yarn..." | sudo tee -a $LOG_FILE
yarn --version | sudo tee -a $LOG_FILE

########## Instalando Git ##########
echo "########## Instalando Git..." | sudo tee -a $LOG_FILE
sudo apt-get install -y git | sudo tee -a $LOG_FILE

# Verificar la instalación de Git
echo "########## Verificando la instalación de Git..." | sudo tee -a $LOG_FILE
git --version | sudo tee -a $LOG_FILE

########## Clonando el repositorio de Backstage ##########
# echo "########## Clonando el repositorio de Backstage..." | sudo tee -a $LOG_FILE
# git clone https://github.com/backstage/backstage.git /home/ubuntu/backstage | sudo tee -a $LOG_FILE

echo "El script de User Data finalizó en $(date)" | sudo tee -a $LOG_FILE
