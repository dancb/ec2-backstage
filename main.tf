provider "aws" {
  region = "us-east-1"
}

# Crear el par de claves y guardar la clave privada en el directorio 'config'
resource "tls_private_key" "backstage_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "backstage_key_pair" {
  key_name   = "backstage-key"
  public_key = tls_private_key.backstage_key.public_key_openssh
}

resource "local_file" "backstage_private_key" {
  filename = "${path.module}/config/backstage-key.pem"
  content  = tls_private_key.backstage_key.private_key_pem
  file_permission = "0400"
}

# Crear una VPC
resource "aws_vpc" "backstage_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "backstage-vpc"
  }
}

# Crear subnets públicas
resource "aws_subnet" "backstage_public_subnet" {
  vpc_id                  = aws_vpc.backstage_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "backstage-public-subnet"
  }
}

# Crear una Internet Gateway
resource "aws_internet_gateway" "backstage_igw" {
  vpc_id = aws_vpc.backstage_vpc.id
  tags = {
    Name = "backstage-igw"
  }
}

# Crear una tabla de enrutamiento para las subnets públicas
resource "aws_route_table" "backstage_route_table" {
  vpc_id = aws_vpc.backstage_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.backstage_igw.id
  }

  tags = {
    Name = "backstage-route-table"
  }
}

# Asociar la tabla de enrutamiento a la subnet pública
resource "aws_route_table_association" "backstage_route_assoc" {
  subnet_id      = aws_subnet.backstage_public_subnet.id
  route_table_id = aws_route_table.backstage_route_table.id
}

# Crear un grupo de seguridad que permita HTTP, HTTPS y SSH
resource "aws_security_group" "backstage_sg" {
  vpc_id = aws_vpc.backstage_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backstage-sg"
  }
}

# Crear una instancia EC2 para Backstage
resource "aws_instance" "backstage_instance" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 para us-east-1
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.backstage_public_subnet.id
  security_groups = [aws_security_group.backstage_sg.id]
  key_name      = aws_key_pair.backstage_key_pair.key_name

  # Instalar Backstage en la instancia
  user_data = <<-EOF
                #!/bin/bash

                # Archivo de log
                LOG_FILE="/var/log/user-data.log"

                # Redirigir toda la salida a este archivo de log
                exec > >(sudo tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

                echo "User Data script started at $(date)" | sudo tee -a $LOG_FILE

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
              EOF

  tags = {
    Name = "backstage-ec2-instance"
  }
}

# Salida de la IP pública de la instancia EC2
output "backstage_instance_public_ip" {
  value = aws_instance.backstage_instance.public_ip
  description = "La dirección IP pública de la instancia Backstage"
}
