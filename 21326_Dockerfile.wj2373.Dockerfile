### This sample Dockerfile shows how to build a Wildfly image for use on Azure
### App Service. The base image uses the Azul JRE, which receives free support
### when used on Azure. For more information about Azul on Azure:
### https://docs.microsoft.com/en-us/java/azure/jdk/

FROM mcr.microsoft.com/java/jre-headless:8u212-zulu-alpine-with-tools

LABEL maintainer="Moehring, Aaron (am542f)"

ENV JBOSS_HOME /opt/jboss/wildfly

ENV PORT 80
ENV SSH_PORT 2222

# Copy configuration files and JSP parking page
COPY docker_resources/standalone-full.xml    /docker_resources/wildfly/standalone-full.xml
COPY docker_resources/init_container.sh      /bin/init_container.sh
COPY docker_resources/sshd_config            /etc/ssh/
COPY lasrrtuweb/target/lasrrtuweb-0.0.1-SNAPSHOT.war /docker_resources/wildfly/webapps/lasrrtuweb-0.0.1-SNAPSHOT.war

RUN apk add --update openssh-server bash openrc \
        && rm -rf /var/cache/apk/* \
        # Remove unnecessary services
        && rm -f /etc/init.d/hwdrivers \
                 /etc/init.d/hwclock \
                 /etc/init.d/mtab \
                 /etc/init.d/bootmisc \
                 /etc/init.d/modules \
                 /etc/init.d/modules-load \
                 /etc/init.d/modloop \
        # Can't do cgroups
        && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
        # Add Postgres certificate
        && mkdir /root/.postgresql \
        && wget -O /root/.postgresql/root.crt https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt \
        # Set username and password for SSH
        && echo "root:Docker!" | chpasswd \
        # Allow access to the container entrypoint
        && chmod 755 /bin/init_container.sh \
        # Download and unpack Wildfly 14
        && wget -O /docker_resources/wildfly-14.0.1.Final.tar.gz https://download.jboss.org/wildfly/14.0.1.Final/wildfly-14.0.1.Final.tar.gz \
        && tar xvzf /docker_resources/wildfly-14.0.1.Final.tar.gz -C /docker_resources \
        && mkdir -p `dirname $JBOSS_HOME` \
        # Copy core Wildfly and the standalone configuration
        && mv /docker_resources/wildfly-14.0.1.Final $JBOSS_HOME \
        && mv /docker_resources/wildfly/standalone-full.xml $JBOSS_HOME/standalone/configuration/standalone-full.xml

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

EXPOSE 80 2222

ENTRYPOINT ["/bin/init_container.sh"]
