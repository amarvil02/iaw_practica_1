#!bin/bash

# Muestra todos los comandos que se van ejecutando
set -x

# Actualizamos los repositorios
#apt update

# Actualizamos los paquetes
#apt upgrade -y

# Instalamos el servidor web Apache
apt install apache2 -y

# Instalamos el sistema gestor de base de datos MySQL
apt install mysql-server -y