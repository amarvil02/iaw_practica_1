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
Empezaremos con Apache, crearemos fuera del directorio scripts un directorio llamado conf, y dentro un archivo *000-default.conf* que será un archivo de configuración de Apache, configuraremos la DirectoryIndex que se utiliza para configurar el orden prioridad de los archivos que se van a mostrar cuando se acceda a un directorio. En este caso damos prioridad a index.php. El contenido será:

ServerSignature Off
ServerTokens Prod

<VirtualHost *:80>
    #ServerName www.example.com
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html

     <Directory "/var/www/html/stats">
          AuthType Basic
          AuthName "Acceso restringido"
          AuthBasicProvider file
          AuthUserFile "/etc/apache2/.htpasswd"
          Require valid-user
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

Entonces una vez creado esto, para ejecutarlo en el script y que funcione la configuración que hemos realizado, lo copiamos con el comando **cp ../conf/000-default.conf /etc/apache2/sites-available** y tras esto ejecutamos **systemctl restart apache2** para reiniciar el servicio de Apache.

También, copiaremos el archivo de prueba de PHP que ya he comentado a través del comando **cp ../php/index.php /var/www/html**. Por último, modificamos el propietario y el grupo del directorio /var/www/html con **chown -R www-data:www-data /var/www/html**.

Para ejecutar el script utilizaremos en el terminal sudo ./install_lamp.sh, con chmod +x cambiaremos los permisos del archivo.

## Instalación de otras herramientas relacionadas con la pila LAMP
En el directorio scripts, crearemos un archivo llamado *install_tools.php* en este copiaremos las 7 primeras líneas del anterior script. 

Antes de nada vamos a crear en scripts un archivo llamado *.env* con el siguiente contenido:

PHPMYADMIN_APP_PASSWORD=123456
APP_USER=usuario
APP_PASSWORD=password
STATS_USERNAME=usuario
STATS_PASSWORD=password

Esto servirá para tener la variables de configuración que usaremos más adelante en el script, para importar estas variables utilizaremos **source .env**. 

En el siguiente paso configuraremos las respuestas de instalación de phpMyAdmin con el siguiente contenido:

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

Y una vez hecho esto, instalamos phpmyadmin, a través del comando **sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y** y también, creamos un usuario que tenga acceso a todas las bases de datos con:

mysql -u root <<< "DROP USER IF EXISTS '$APP_USER'@'%'"
mysql -u root <<< "CREATE USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PASSWORD';"
mysql -u root <<< "GRANT ALL PRIVILEGES ON *.* TO '$APP_USER'@'%'";

Las variables que hemos configurado antes serán utilizadas en estos pasos.

### Instalación de Adminer
En este paso instalaremos Adminer, que es una alternaniva de phpmyadmin, antes de instalarlo crearemos el directorio para Adminer con el comando **mkdir -p /var/www/html/adminer**, y a continuación descargamos el archivo de Adminer y lo guardamos en el directorio */var/www/html/adminer con el comando **wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer**.

Ahora, vamos a renombrar el nombre del archivo en Adminer con **mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php** y por último, modificamos el propietario y el grupo del directorio /var/www/html -> **chown -R www-data:www-data /var/www/html**.

### Instalación de GoAccess
Lo instalaremos con el comando **apt install goaccess -y**, el siguiente paso será crear un directorio para los informes html de GoAccess con **mkdir -p /var/www/html/stats**. Por último, ejecutamos GoAccess en segundo plano **goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize**.

## Configuramos la autenticacion basica de un directorio
Lo primero, será crear el archivo .htpasswd -> **htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD**. Ahora en nuestro directorio *conf* que hemos creado antes para configurar Apache crearemos un archivo llamado *000-default-stats.conf* que tendrá la configuración del acceso al directorio, el contenido será el siguiente:

ServerSignature Off
ServerTokens Prod

<VirtualHost *:80>
    #ServerName www.example.com
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html

     <Directory "/var/www/html/stats">
          AuthType Basic
          AuthName "Acceso restringido"
          AuthBasicProvider file
          AuthUserFile "/etc/apache2/.htpasswd"
          Require valid-user
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

Ahora en nuestro script install_tools.sh lo copiaremos con **cp ../conf/000-default-stats.conf /etc/apache2/sites-available/000-default.conf**. Por último, reiniciamos el servicio de Apache con el comando **systemctl restart apache2**.






