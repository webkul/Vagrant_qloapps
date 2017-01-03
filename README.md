## SHELL PROVISIONING IN VAGRANT

Vagrant is used to create and configure lightweight, reproducible, and portable development environments. It allows set-up, configuration and working in a simple way. Vagrant allows provisioning tools such as shell scripts, Chef, or Puppet, that can be used to automatically install and configure software on the machine.

Provisioners in Vagrant allow you to automatically install software packages, change configurations, running command line instructions etc. It automates the workflow. Vagrant gives you multiple options for provisioning the machine, from simple shell scripts to more complex ones. You can run provisining by running "vagrant up --provision".

We are here using shell provisioner. The Vagrant Shell provisioner allows you to execute a script within the guest instance. Here we will create a shell script installing the LAMP set-up (including other necessory packages) and Qloapps, an open source Hotel Commerce Solution. Qlo booking system allow hotel owners to manage their online & ondesk bookings by launching an Hotel Booking Website.


## SHELL PROVISIONING FOR QLOAPPS

First we will enable shell provisioning by defining function in Vagrantfile. A qloapps.sh bash script is placed outside the Vagrantfile. Configure your Vagrantfile by mentioning box name, IP address, vagrant user and password, etc and place 
*config.vm.provision "shell", path: "qloapps.sh"* as shown in Vagrantfile.

Now open qloapps.sh file, mention the steps for installation of LAMP set-up and other requirements needed for installation of qloapps. Take a note that mysql root password and database password has been randomly generated here which you can check in a log file located at /var/log/check.log. *Don't forget to remove /var/log/check.log file after noting down mysql root password and database password to ensure no security vulnerability.*

In our architecture, we are using:

> Apache-2.4.7

> PHP-5.5

> Mysql-5.6

After finishing the script, 

> Close the file and make it executable by running command: *chmod a+x qloapps.sh*

> Now, you can load you vagrant instance by running command: *vagrant up*

> To run provisioning along with vagrant startup, run command: *vagrant up --provision*

> To enter the vagrant environment after startup, run command: "vagrant ssh"

> To stop the instance, run *exit* command in vagrant enviornment and then run command: *vagrant halt*

After successfull installation, hit the url http://your-server-name and begin with the installation.

![Alt text](https://github.com/alankrit29/Shell-Provisining-in-Vagrant-for-Qloapps/blob/master/Screenshot%20from%202017-01-03%2011:47:53.png?raw=true)
