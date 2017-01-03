#!/bin/bash


## SET VARIABLES

USER=www-data ## user

GROUP=www-data ##group

mysql_root_password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1` ## set mysql root password

database_name=test ## set database name

database_user=test ## set database user

database_password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1` ## database password

root_directory=/var/www/hotelcommerce-1.0/ ##root directory

path_to_root_directory_folder=/var/www/ ## path to download zip package of qloapps

##install apache2

apt-get update
apt-get -y install apache2

##install mysql-server

export DEBIAN_FRONTEND="noninteractive"
echo "mysql-server-5.6 mysql-server/root_password password $mysql_root_password" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $mysql_root_password" | debconf-set-selections
apt-get install -y mysql-server-5.6

#install php and its extensions

apt-get install -y php5 php5-curl php5-gd php5-mcrypt php5-mysql

php5enmod mcrypt

##set php settings

sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 768M/" /etc/php5/apache2/php.ini

echo "date.timezone = Asia/Kolkata" >> /etc/php5/apache2/php.ini

echo "date.timezone = Asia/Kolkata" >> /etc/php5/cli/php.ini


##install necessory packages

apt-get install -y unzip

apt-get install -y wget

##download qloapps from github.com

cd $path_to_root_directory_folder &&  wget https://github.com/webkul/hotelcommerce/archive/v1.0.zip

cd $path_to_root_directory_folder && unzip v1.0.zip

chown -R $USER:$GROUP $root_directory

find $root_directory -type f -exec chmod 644 {} \;

find $root_directory -type d -exec chmod 755 {} \;

##apache2 settings

a2enmod rewrite

a2enmod headers

echo " " > /etc/apache2/sites-enabled/000-default.conf

cat <<EOT >> /etc/apache2/sites-enabled/000-default.conf

<VirtualHost *:80> 
DocumentRoot $root_directory 
<Directory  $root_directory> 
Options FollowSymLinks 
Require all granted  
AllowOverride all 
</Directory> 
ErrorLog /var/log/apache2/error.log 
CustomLog /var/log/apache2/access.log combined 
</VirtualHost> 

EOT

/etc/init.d/apache2 restart

##set database name, user and password

mysql -u root -p$mysql_root_password -e "create database $database_name;" 
mysql -u root -p$mysql_root_password -e "grant all on $database_name.* to '$database_user'@'%' identified by '$database_password';"
mysql -u root -p$mysql_root_password -e "exit"

/etc/init.d/mysql restart

## create a log file

touch /var/log/check.log
chown syslog:adm /var/log/check.log
chmod 640 /var/log/check.log

##  check for mysql and database password in log file

echo "####################################" >> /var/log/check.log
echo "mysql root password is: $mysql_root_password " >> /var/log/check.log
echo "database password is: $database_password " >> /var/log/check.log
echo "####################################" >> /var/log/check.log



echo "########################################################"
echo "########################################################"
echo "##################### IMPORTANT ########################"
echo "REMOVE "/var/log/check.log" file after checking password"
echo "########################################################"
echo "########################################################"
