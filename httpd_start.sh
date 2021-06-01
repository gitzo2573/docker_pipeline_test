#!/bin/bash

sudo su -

# Virtual Machine Apache HTTPD start and enable

# Apache start service
echo "26185_httpd_start.sh: start httpd"
systemctl enable httpd
systemctl start httpd

# Firewall
echo "26185_httpd_start.sh: enable, start, port 80 firewalld"
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload

# Apache status 
echo "26185_httpd_start.sh: status httpd"
apachectl configtest 2>&1 | grep -v "skipping"
apachectl status

# Apache status and Firewalld status
echo "26185_httpd_start.sh: status firewalld"
systemctl status firewalld

npm start