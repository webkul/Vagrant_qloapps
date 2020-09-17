#!/bin/bash
# VAGRANT PROVISIONING SCRIPT FOR QLOAPPS
# AUTHOR: Alankrit Srivastava
# Webkul Software Pvt. Limited.
# Operating System: Ubuntu 14.04

##########################################################################################################
# This block contains variables to be defined by user. Before running this script, you must ensure that: #
#> You have vagrant installed on your server and this script is included in shell provisioning block in  #
#  Vagrantfile.                                                                                          #
#> If you want to setup database on remote host then remote host must be acccessible.                    #
#> Your domain name must be present. If not, create a DNS host entry in your firewall.                   #
# This script is strictly for one user per instance. Re-running scripts for another user will            #  
# throw errors and destroy configuration for first user.                                                 #
##########################################################################################################

domain_name = ""                                                                          ## mention the domain name

database_host = ""                                                                         ## mention database host.

database_name = ""                                                                        ## mention database name

mysql_root_password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`  ## randomly generated database 



database_Connectivity() {
echo "CHECKING DATABASE HOST CONNECTIVITY"
database_connectivity_check=`mysqlshow --user=root --password=$mysql_root_password --host=$database_host | grep -o mysql`
if [ "$database_connectivity_check" != "mysql" ]; then
echo "$DATABASE CONNECTIVITY FAILED !"
exit 1
else
echo "DATABASE CONNECTIVITY ESTABLISHED"
fi
}

database_Availability() {
echo "CHECKING DATABASE AVAILABILITY"
database_availability_check=`mysqlshow  --user=root --password=$mysql_root_password --host=$database_host | grep -o $database_name`
if [ "$database_availability_check" == "$database_name" ]; then
echo "DATBASE $database_name ALREADY EXISTS. USE ANOTHER DATABASE NAME !"
exit 1
else
echo "DATABASE $database_name IS FREE TO BE USED"
fi
}


lamp_Installation() {
##update server
apt-get update \
    && apt-get -y install apache2 \
    && a2enmod rewrite \
    && a2enmod headers \
    && export LANG=en_US.UTF-8 \
    && apt-get update \
    && apt-get install -y software-properties-common \
    && apt-get install -y language-pack-en-base \
    && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install php7.2 php7.2-curl php7.2-intl php7.2-gd php7.2-dom php7.2-iconv php7.2-xsl php7.2-mbstring php7.2-ctype php7.2-zip php7.2-pdo php7.2-xml php7.2-bz2 php7.2-calendar php7.2-exif php7.2-fileinfo php7.2-json php7.2-mysqli php7.2-mysql php7.2-posix php7.2-tokenizer php7.2-xmlwriter php7.2-xmlreader php7.2-phar php7.2-soap php7.2-mysql php7.2-fpm php7.2-bcmath libapache2-mod-php7.2 \
    && sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 512M/" /etc/php/7.2/apache2/php.ini \
    && echo "date.timezone = Asia/Kolkata" >> /etc/php/7.2/apache2/php.ini \
    && sed -i -e"s/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 16M/" /etc/php/7.2/apache2/php.ini \
    && sed -i -e"s/^max_execution_time\s*=\s*30/max_execution_time = 500/" /etc/php/7.2/apache2/php.ini

##install mysql-server=5.7
export DEBIAN_FRONTEND="noninteractive"
echo "mysql-server-5.7 mysql-server/root_password password $mysql_root_password" | debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $mysql_root_password" | debconf-set-selections
apt-get -y install mysql-server-5.7
sleep 4
database_Connectivity
sleep 2
database_Availability

##create database
mysql -h $database_host -u root -p$mysql_root_password -e "create database $database_name;" 
mysql -h $database_host -u root -p$mysql_root_password -e "grant all on $database_name.* to 'root'@'%' identified by '$mysql_root_password';"


##apache2 configuration
a2enmod rewrite
a2enmod headers

touch /etc/apache2/sites-enabled/qloapps.conf
cat <<EOF >> /etc/apache2/sites-enabled/qloapps.conf
<VirtualHost *:80> 
ServerName $domain_name
DocumentRoot /var/www/html/hotelcommerce
<Directory  /var/www/html/hotelcommerce> 
Options FollowSymLinks 
Require all granted  
AllowOverride all 
</Directory> 

ErrorLog /var/log/apache2/error.log 
CustomLog /var/log/apache2/access.log combined 

</VirtualHost> 
EOF
}

qloapps_Download() {
apt-get install -y git
cd /var/www/html/ && git clone https://github.com/webkul/hotelcommerce.git

##ownership and permissions
find /var/www/html/ -type f -exec chmod 644 {} \;
find /var/www/html/ -type d -exec chmod 755 {} \;
chown -R www-data:www-data /var/www/html/

##restart servers
/etc/init.d/apache2 restart
}


logging_Credentials() {

##Logging randomly generated Mysql password in a file

echo "
_______________________________________________________________________\\

DOMAIN NAME: $domain_name
DATABASE HOST: $database_host
DATABASE USER: root
DATABASE ROOT USER'S PASSWORD: $mysql_root_password
DATABASE NAME: $database_name
________________________________________________________________________\\

Admin URL will be generated after qloapps installation. Please check admin frontname in server root directory.
REMOVE "/var/log/check.log" file after checking password.
Script Execution has been completed. If you encounter any errors, destroy this Vagrant server and re-build the Vagrant server." \
 > /var/log/check.log
echo "
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         										              
 Vagrant Shell Provisoning is completed. Hit your domain name to start Qloapps Installation Process.    
 Also, please check /var/log/check.log file to retrieve your database credentials.                  
												      
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
"
}

main() {
lamp_Installation
qloapps_Download
logging_Credentials
}

main
