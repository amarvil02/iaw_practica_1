#!/bin/bash

# Muestra todos los comandos que se van ejecutando
set -x

#Se importan las variables de configuración
source .env

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes
#apt upgrade -y

# Configuramos las respuestas de instalación de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

# Instalamos phpmyadmin
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# Creamos un usuario que tenga acceso a todas las bases de datos
mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%'";

# Instalamos Adminer
# Creamos el directorio para adminer
mkdir -p /var/www/html/adminer

# Descargamos el archivo de Adminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer

# Renombramos el nombre del archivo en Adminer
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php

# Modificamos el propietario y el grupo del directorio /var/www/html
chown -R www-data:www-data /var/www/html