From centos:6
MAINTAINER ian.wu@macys.com

#install necessary packages
RUN yum update -y
RUN yum -y install sudo
RUN yum -y install java-1.6.0-openjdk-devel
RUN yum -y install wget
RUN yum -y install unzip
RUN yum -y install which

#configure the non-root user named "dev"
RUN useradd -ms /bin/bash dev
RUN echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Edit sudoers file # To avoid error: sudo: sorry, you must have a tty to run sudo RUN
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

#unpack and install jboss-6.4
ADD local/* /tmp/
RUN unzip /tmp/jboss-eap-6.4.0.zip -d /usr/share
RUN rm /tmp/jboss-eap-6.4.0.zip
RUN chown -fR dev.dev /usr/share/jboss-eap-6.4/

#configure the dev user
USER dev
RUN echo "export JBOSS_HOME='/usr/share/jboss-eap-6.4/'" >> ~/.bashrc
RUN echo "alias run-jboss='/usr/share/jboss-eap-6.4/bin/standalone.sh'" >> ~/.bashrc

#configure jboss
RUN /usr/share/jboss-eap-6.4/bin/add-user.sh admin password-1
RUN cp /tmp/order.war-1.17.17.war /usr/share/jboss-eap-6.4/standalone/deployments/order.war
RUN cp /tmp/environment.properties /usr/share/jboss-eap-6.4/standalone/configuration/
RUN cp /tmp/standalone.conf /usr/share/jboss-eap-6.4/bin/standalone.conf
RUN cp /tmp/module.xml /usr/share/jboss-eap-6.4/modules/system/layers/base/sun/jdk/main/module.xml
#ADD keystore /opt/jboss/wildfly/standalone/configuration/

#change the jboss port-binding. specicially, we need to 
#bind the ports to 0.0.0.0:xxxx , so that docker's port 
#binding could expose the container's port to external host
RUN sed -i -e "s/<inet-address.*\/>/<any-address\/>/g" /usr/share/jboss-eap-6.4/standalone/configuration/standalone.xml 



