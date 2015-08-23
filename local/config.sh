#!/bin/sh
#install necessary packages
#yum update -y
yum -y install sudo
yum -y install java-1.6.0-openjdk-devel
yum -y install wget
yum -y install unzip
yum -y install which

#configure the non-root user named "dev"
useradd -ms /bin/bash dev
echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Edit sudoers file # To avoid error: sudo: sorry, you must have a tty to run sudo RUN
sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

#unpack and install jboss-6.4
unzip /tmp/jboss-eap-6.4.0.zip -d /usr/share
rm /tmp/jboss-eap-6.4.0.zip
chown -fR dev.dev /usr/share/jboss-eap-6.4/

#prepare for dev scripts to be executed
chmod a+x /tmp/dev_commands.sh

#==============
#user commands for dev
su dev
echo "export JBOSS_HOME='/usr/share/jboss-eap-6.4/'" >> /home/dev/.bashrc
echo "alias run-jboss='/usr/share/jboss-eap-6.4/bin/standalone.sh'" >> /home/dev/.bashrc
echo "export JAVA_OPTS='-Xmx512m -Xms256m -XX:MaxPermSize=350m -XX:PermSize=64m -Djava.net.preferIPv4Stack=true -Djboss.as.management.blocking.timeout=600'" >> /home/dev/.bashrc

#configure jboss
/usr/share/jboss-eap-6.4/bin/add-user.sh admin password-1
cp /tmp/order.war-1.17.17.war /usr/share/jboss-eap-6.4/standalone/deployments/order.war

echo "#local settings added by ian.wu" >> /usr/share/jboss-eap-6.4/bin/standalone.conf
echo "JAVA_OPTS=\"\$JAVA_OPTS -Dsdp.configuration.home=/usr/share/jboss-eap-6.4/standalone/configuration\"" >> /usr/share/jboss-eap-6.4/bin/standalone.conf
cp -f /tmp/standalone.xml /usr/share/jboss-eap-6.4/standalone/configuration/
cp -f /tmp/module.xml /usr/share/jboss-eap-6.4/modules/system/layers/base/sun/jdk/main/module.xml
cp -f /tmp/environment.properties /usr/share/jboss-eap-6.4/standalone/configuration/
cp -f /tmp/MA000XSPKI03.pem /usr/share/jboss-eap-6.4/bin/
cp -f /tmp/MacysRootCA.pem /usr/share/jboss-eap-6.4/bin/
cp -f /tmp/messserv.p12 /usr/share/jboss-eap-6.4/bin/

#change the jboss port-binding. specicially, we need to 
#bind the ports to 0.0.0.0:xxxx , so that docker's port 
#binding could expose the container's port to external host
sed -i -e "s/<inet-address.*\/>/<any-address\/>/g" /usr/share/jboss-eap-6.4/standalone/configuration/standalone.xml 

#enable the following  later
#ADD keystore /opt/jboss/wildfly/standalone/configuration/
