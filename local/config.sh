#!/bin/sh
#install necessary packages
#yum update -y #disabled, too many downloads
yum -y install sudo
yum -y install wget
yum -y install unzip
yum -y install which
yum -y install java-1.6.0-openjdk-devel

#configure the non-root user named "dev"
useradd -ms /bin/bash dev
echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Edit sudoers file # To avoid error: sudo: sorry, you must have a tty to run sudo RUN
sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

#unpack and install jboss-6.4
unzip /tmp/jboss-eap-6.4.0.zip -d /usr/share
rm /tmp/jboss-eap-6.4.0.zip
chown -fR dev.dev /usr/share/jboss-eap-6.4/

#==============
#user commands for dev
su dev
echo "export JBOSS_HOME='/usr/share/jboss-eap-6.4/'" >> /home/dev/.bashrc
echo "alias run-jboss='/usr/share/jboss-eap-6.4/bin/standalone.sh'" >> /home/dev/.bashrc
echo "export JAVA_OPTS='-Xmx512m -Xms256m -XX:MaxPermSize=350m -XX:PermSize=64m -Djava.net.preferIPv4Stack=true -Djboss.as.management.blocking.timeout=600'" >> /home/dev/.bashrc

#configure jboss
/usr/share/jboss-eap-6.4/bin/add-user.sh admin password-1

#change the jboss port-binding. specicially, we need to 
#bind the ports to 0.0.0.0:xxxx , so that docker's port 
#binding could expose the container's port to external host
#NOTE: this is not used, because we hard-coded this change in
#a local file which will override standalone.xml later.
#sed -i -e "s/<inet-address.*\/>/<any-address\/>/g" /usr/share/jboss-eap-6.4/standalone/configuration/standalone.xml 

#enable the following  later
#ADD keystore /opt/jboss/wildfly/standalone/configuration/
