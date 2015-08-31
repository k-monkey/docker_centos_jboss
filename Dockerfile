From centos:6
MAINTAINER ian.wu@macys.com

#copy all helper files to image
ADD local/* /tmp/
RUN /tmp/config.sh

WORKDIR /usr/share/jboss-eap-6.4/
