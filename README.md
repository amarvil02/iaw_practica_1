# IAW_Practica1
Instalación de la pila LAMP

## Creacion del script install_lamp.sh
Para empezar, tendremos nuestro directorio creado para la práctica, en mi caso iaw_practica_1, y dentro de este directorio tendremos otro directorio llamado scripts, que será donde instalaremos la pila LAMP y otras herramientas.

En el script install_lamp tendremos el siguiente contenido:

Empezaremos el script con **#!/bin/bash**, que es un indicador que le dice al sistema operativo que el script debe ser ejecutado utilizando el intérprete de Bash.

Tras esto, escribiremos también **set -x** que mostrará todos los comandos que se vayan ejecutando.

## Actualizaciónes
Antes de continuar, recuerdo que estamos trabajando con Ubuntu y que los comandos utilizados no servirán para todos los demás sistemas operativos.

Lo siguiente que haremos será introducir el comando **apt update**, el cuál actualizará los repositorios. También, tendremos el comando **apt upgrade -y** que actualizará los paquetes que hemos instalado en el anterior comando a sus últimas versiones.

## Instalaciones de servicios
A continuación, vamos a instalar el servidor web Apache, con el comando **apt install apache2 -y**. Aunque no esté reflejado en el script, necesitamos unos comandos para iniciar Apache. Con el comando **sudo systemctl start apache2** y con el comando **sudo systemctl enable apache2** dejará activado el servidor y no se apagará cada vez que apaguemos la máquina.

Seguimos con el script aunque todavía no hemos terminado con Apache. El siguiente paso en el script será instalar el sistema gestor de base de datos de MySQL con el comando **apt install mysql-server -y**, al igual que con el servidor Apache tendremos que iniciar el servidor con el comando **sudo systemctl start mysql** y lo dejamos habilitado con **sudo systemctl enable mysql**. Con MySQL instalado podremos acceder a los archivos de configuración en **/etc/mysql/mysql.cnf**, a los archivos de log en **/var/log/mysql/error.log** y podremos acceder a MySQL con **sudo mysql**.

Lo siguiente que instalaremos será PHP con sus módulos con el comando **sudo apt install php libapache2-mod-php php-mysql -y**. Una vez instalado PHP, tendremos que crear un directorio php (crearlo fuera de scripts) y creamos un archivo *index.php* en el cuál tendremos una estructura php con el contenido **phpinfo();** que nos permitirá comprobar que la instalación de PHP se ha completado con éxito, si accedes a tu dirección IP/info.php verás la página con PHP.

## Configuraciones de los servidores
Empezaremos con Apache, crearemos fuera del directorio scripts un directorio llamado conf, y dentro un archivo *000-default.conf* que será un archivo de configuración de Apache, configuraremos la DirectoryIndex que se utiliza para configurar el orden prioridad de los archivos que se van a mostrar cuando se acceda a un directorio. En este caso damos prioridad a index.php. Entonces una vez creado esto, para ejecutarlo en el script y que funcione la configuración que hemos realizado, lo copiamos con el comando **cp ../conf/000-default.conf /etc/apache2/sites-available** y tras esto ejecutamos **systemctl restart apache2** para reiniciar el servicio de Apache.

También, copiaremos el archivo de prueba de PHP que ya he comentado a través del comando **cp ../php/index.php /var/www/html**. Por último, modificamos el propietario y el grupo del directorio /var/www/html con **chown -R www-data:www-data /var/www/html**.



