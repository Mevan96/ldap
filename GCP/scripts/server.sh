# !/bin/bash

# install ldap-server
sudo yum install -y openldap openldap-servers openldap-clients 
sudo systemctl start slapd
sudo systemctl enable slapd

# configure ldap-server
sudo firewall-cmd --add-service=ldap

PASSWORD=$(sudo slappasswd -s mevan)

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /resources/ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG

sudo systemctl restart slapd

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
# add my domain in LDAP DB
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /resources/ldapdomain.ldif 

# add domain
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /resources/baseldapdomain.ldif 

# add group and user
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /resources/ldapgroup.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /resources/ldapuser.ldif 



# install UI
sudo yum --enablerepo=epel -y install phpldapadmin
sudo sed -i '397s+^//++' /etc/phpldapadmin/config.php
sudo sed -i '398s+^+//+' /etc/phpldapadmin/config.php

#sudo cat > /etc/httpd/conf.d/phpldapadmin.conf << EOL "
#Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
#Alias /ldapadmin /usr/share/phpldapadmin/htdocs
#<Directory /usr/share/phpldapadmin/htdocs>
#  <IfModule mod_authz_core.c>
#    Require all granted
#    Require local
#    Require ip 10.0.0.0/24
#  </IfModule>
#  <IfModule !mod_authz_core.c>
#    Order Allow, Deny
#    Allow from all
#    Allow from 127.0.0.1
#    Allow from ::1
#  </IfModule>
#</Directory>"
#EOL

sudo systemctl restart httpd
