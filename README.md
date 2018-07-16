## WHAT IS QLOAPPS

Qlo is an open source, free and customizable online reservation system. You can launch a userfriendly site and can manage online as well as offline bookings. Using this you can easily launch your hotel booking website and even manage your offline booking too. This package is developed on top of Prestashop 1.6.


## SHELL PROVISIONING IN VAGRANT

Vagrant is used to create and configure lightweight, reproducible, and portable development environments. It allows set-up, configuration and working in a simple way. Vagrant allows provisioning tools such as shell scripts, Chef, or Puppet, that can be used to automatically install and configure software on the machine.

Provisioners in Vagrant allow you to automatically install software packages, change configurations, running command line instructions etc. It automates the workflow. Vagrant gives you multiple options for provisioning the machine, from simple shell scripts to more complex ones. You can run provisining by running "*vagrant up --provision*".

We are here using shell provisioner. The Vagrant Shell provisioner allows you to execute a script within the guest instance. Here we will create a shell script installing the LAMP set-up (including other necessory packages) and Qloapps, an open source Hotel Commerce Solution. Qlo booking system allow hotel owners to manage their online & ondesk bookings by launching an Hotel Booking Website.


## PREREQUISITES

> Latest available version of Virtualbox and Vagrant server should be installed on the server. Run "*vagrant -v*" to check vagrant version.

> Dowload a Vagrant box for Ubuntu 14.04 and add its path in the Vagrantfile. A Vagrantfile sample is added in this project. Mention path to the Vagrant box in "*config.vm.box*". 

> Mention Vagrant username, password and IP address in their respective fields.


## VAGRANT SHELL PROVISIONING FOR QLOAPPS

Enable shell provisioning by defining function in Vagrantfile. A qloapps.sh bash script is placed parallel to the Vagrantfile. Configure your Vagrantfile by mentioning box name, IP address, vagrant user and password, etc and place 
*config.vm.provision "shell", path: "qloapps.sh"* as shown in Vagrantfile.

Now open qloapps.sh file, set the domain name, database host and database name in their respective variables. Take a note that mysql root password will be randomly generated here which you can check in a log file located at /var/log/check.log. *Don't forget to remove /var/log/check.log file after noting down mysql root password to ensure no security vulnerability.*

In our architecture, we are using:

> Ubuntu 14.04

> Apache2

> PHP-5.6

> Mysql-5.6

> Database user: root

> Qloapps installation path: /var/www/html/hotelcommerce


After finishing the script, 

> Close the file and make it executable by running command: *chmod a+x qloapps.sh*

> Now, you can load you vagrant instance by running command: *vagrant up*

> To deploy shell provisioning, run command: *vagrant provision*

> To run provisioning along with vagrant startup, run command: *vagrant up --provision*

> To enter the vagrant environment after startup, run command: "vagrant ssh"

> To stop the instance, run *exit* command in vagrant enviornment and then run command: *vagrant halt*

> To destroy your vagrant environment, run command: *vagrant destroy* 

After successfull installation, hit the url http://your-server-name and begin with the installation.
