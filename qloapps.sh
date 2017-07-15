#!/bin/bash

########################################################
# VAGRANT PROVISIONING SCRIPT FOR QLOAPPS-v-1.1.0      #
# AUTHOR: Alankrit Srivastava                          #
# Webkul Software Pvt. Limited.                        #
########################################################

# BLOCK 1 #
##########################################################################################################
# This block contains variables to be defined by user. Before running this script, you must ensure that: #
#> You have vagrant installed on your server.                                                            #
#> If you want to setup database on remote host then remote host must be acccessible.                    #
#> Your domain name must be present. If not, create a DNS host entry in your firewall.                   #
# This script is strictly for one user per instance. Re-running scripts for another user will            #  
# throw errors and destroy configuration for first user.                                                 #
##########################################################################################################

##set variables

user=                                 ## mention name of the user. This will be your apache2 user. Also will be your ssh and sftp user.

user_password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`   ## randomly generated user's password

path_to_root_directory_folder=        ## mention path of magento installation directory. Avoid using /var/www . (ex: /home/test)

######################################################################################################################
# For database on remote host, mention the its endpoint or IP address in the "database_host" variable.               #
# If you wish to keep database on local environment, mention "localhost" or "127.0.0.1" in "database_host" variable  #
######################################################################################################################

database_root_user=                   ## mention database root user

database_root_password=               ## mention database root user's password

database_user=                        ## mention database user

database_name=                        ## mention database name

database_user_password=               ## mention database user's password

database_host=                        ## mention database remote host.

domain_name=                          ## mention the domain name

# BLOCK 2 #
#################################################################################
# This block define variables for coloured output and perform several functions:#
# > ubuntu version check                                                        #
# > review user's inputs                                                        #
# > install mysql-client (and mysql-server for local database setup)            #
# > database host connectivity check                                            #
# > database name availability check                                            #
#################################################################################

##predefined variables

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
trap '{ echo "${red} PROCESS INTERRUPTED. EXITING !!! ${reset}." ; exit 1; }' INT
ubuntu_version=`cat /etc/lsb-release | awk 'NR==2' | grep -Eo '[0-9\.]*'`

##RE-CHECKING ALL THE USER'S INPUTS##

echo " ${yellow}**CHECK YOUR INPUTS BEFORE PROCEEDING**
_______________________________________________________________________\\
DOMAIN NAME: $domain_name                                                          
USER'S NAME: $user
USER'S PASSWORD: $user_password
SERVER DIRECTORY PATH: $path_to_root_directory_folder
DATABASE HOST: $database_host
DATABASE ROOT USER: $database_root_user
DATABASE ROOT USER'S PASSWORD: $database_root_password
DATABASE NAME: $database_name
DATABASE USER: $database_user
DATABASE USER'S PASSWORD: $database_user_password
_______________________________________________________________________\\"
sleep 2

##update server

apt-get update

##install mysql-client for remote database

apt-get -y install mysql-client-5.6

##install mysql-server when database host is localhost

if [ "$database_host" == "localhost" ] || [ "$database_host" == "127.0.0.1" ]; then
export DEBIAN_FRONTEND="noninteractive"
echo "mysql-server-5.6 mysql-server/root_password password $database_root_password" | debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $database_root_password" | debconf-set-selections
apt-get -y install mysql-server-5.6
fi

##database host connectivity check

echo "${yellow}CHECKING DATABASE HOST CONNECTIVITY${reset}"
datbase_connectivity_check=`mysqlshow --user=$database_root_user --password=$database_root_password --host=$database_host | grep -o mysql`
if [ "$datbase_connectivity_check" != "mysql" ]; then
echo "${red}DATBASE CONNECTIVITY FAILED !${reset}"
exit
else
echo "${green}DATABASE CONNECTIVITY ESTABLISHED${reset}"
fi

##database availability check

############################################################################################################################################
# In this script, your database will be created with a name being assigned to "$database_name" variable. And "database avaiability check"  #
# checks if a database with same database name is present or not. For database already present, it terminates the script and asks you to   #
# another database name. If you have already created an empty database, with its proper permissions to an user, before running this script #
# then comment out "database availability check" block.                                                                                    #
############################################################################################################################################

echo "${yellow}CHECKING DATABASE AVAILABILITY${reset}"
database_availability_check=`mysqlshow --user=$database_root_user --password=$database_root_password --host=$database_host | grep -o $database_name`
if [ "$database_availability_check" == "$database_name" ]; then
echo "${red}DATBASE $database_name ALREADY EXISTS. USE ANOTHER DATABASE NAME !${reset}"
exit
else
echo "${green}DATABASE $database_name IS FREE TO BE USED${reset}"
fi
# BLOCK 4 #
############################################################
# This block deals with:                                   #
# > apache user creation (also ssh and sftp user)          #
# > apache2 installation and configuration                 #
# > php 5 installation with dependencies                   #
# > database creation                                      #
# > magento installation and configuration                 #
# > phpmyadmin installation and configuration              #
# > openssh-server installation                            #
############################################################

##install necessory packages

apt-get install -y unzip
apt-get install -y wget

##apache2 user creation

useradd -m -s /bin/bash $user
echo -e "$user_password\n$user_password\n" | passwd $user

##install apache2

apt-get -y install apache2

#install php and its extensions

apt-get install -y php5 php5-curl php5-gd php5-mcrypt php5-mysql libapache2-mod-php5
php5enmod mcrypt
sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 512M/" /etc/php5/apache2/php.ini

##create database and its user

mysql -h $database_host -u $database_root_user -p$database_root_password -e "create database $database_name;" 
mysql -h $database_host -u $database_root_user -p$database_root_password -e "grant all on $database_name.* to '$database_user'@'%' identified by '$database_user_password';"

##download Qloapps

cd /var/www/ && wget https://github.com/webkul/hotelcommerce/archive/v1.1.0.zip

## make a folder and unzip magento files

mkdir -p $path_to_root_directory_folder
cd $path_to_root_directory_folder/ && unzip /var/www/v1.1.0.zip

##ownership and permissions

find $path_to_root_directory_folder -type f -exec chmod 644 {} \;
find $path_to_root_directory_folder -type d -exec chmod 755 {} \;
chown -R $user: $path_to_root_directory_folder


##apache2 settings

a2enmod rewrite
a2enmod headers

sed -i "s/www-data/$user/g" /etc/apache2/envvars
echo " " > /etc/apache2/sites-enabled/000-default.conf

cat <<EOF >> /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80> 
ServerName $domain_name
DocumentRoot $path_to_root_directory_folder/hotelcommerce-1.1.0
<Directory  $path_to_root_directory_folder/hotelcommerce-1.1.0> 
Options FollowSymLinks 
Require all granted  
AllowOverride all 
</Directory> 

Include /etc/phpmyadmin/apache.conf
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory "/usr/share/phpmyadmin/">
Order allow,deny
Allow from all
Require all granted
</Directory>

ErrorLog /var/log/apache2/error.log 
CustomLog /var/log/apache2/access.log combined 

</VirtualHost> 
EOF

##phpmyadmin

add-apt-repository -y ppa:vincent-c/ppa
apt-get -y update
echo "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
apt-get -y install phpmyadmin
sed -i "/$database_host/d" /etc/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['host'] = '$database_host';" >> /etc/phpmyadmin/config.inc.php


##install ssh server

apt-get -y install openssh-server
sed -i -e"s/^PasswordAuthentication\s*.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config


##restart servers

/etc/init.d/apache2 restart

##ceate a log file

touch /var/log/check.log
chown syslog:adm /var/log/check.log
chmod 640 /var/log/check.log

## check password ##

echo "user password is: $user_password " > /var/log/check.log
echo "Database user $database_user password is: $database_user_password " >>  /var/log/check.log
echo "Database root user password is: $database_root_password" >> /var/log/check.log
echo "${red}################################ IMPORTANT !!! ##############################${reset}"
echo "${yellow}#      REMOVE "/var/log/check.log" file after checking password          #${reset}"
echo "${red}#############################################################################${reset}"

##############################################################################################################################################################################################
