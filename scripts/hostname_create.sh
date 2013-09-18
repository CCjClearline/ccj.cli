#!/bin/bash

SERVER=$(hostname)
IP=$(host $SERVER | awk '{ print $4 }' )

DOMAIN=$(echo "$1" | tr -d ' ')
echo -e "Proceed with setting up hostnames for $DOMAIN? [y/n]"

read proceed
if [ $proceed == "n" ]; then
	echo -e "Re-enter domain name"
	read domain
	DOMAIN=$(echo "$domain" | tr -d ' ')
fi

USERNAME=$(echo "$DOMAIN" | cut -c1-8)
# We should first strip off the TLD, since domains that are less than 8 charas don't get usersnames that include the TLD.


echo -e "Proceed with username $USERNAME? [y/n]"
read proceed
if [ $proceed == "n" ]; then
	echo -e "Re-enter username"
	read username
	USERNAME=$username
fi

ACCHOSTNAME=$USERNAME.ccjclearline.com

echo -e "Creating directory /usr/local/apache/conf/userdata/std/2/$USERNAME/$DOMAIN"
mkdir -p /usr/local/apache/conf/userdata/std/2/$USERNAME/$DOMAIN || { echo 'mkdir failed!' >&2; exit 1; }

echo -e "Creating file /usr/local/apache/conf/userdata/std/2/$USERNAME/$DOMAIN/$ACCHOSTNAME.conf:"
echo -e "ServerAlias $ACCHOSTNAME"
echo "ServerAlias $ACCHOSTNAME" >> /usr/local/apache/conf/userdata/std/2/$USERNAME/$DOMAIN/$ACCHOSTNAME.conf || { echo 'Conf file creation failed!' >&2; exit 1; }

echo -e "Rebuilding apache conf."
/usr/local/cpanel/bin/build_apache_conf || { echo 'apache build failed!' >&2; exit 1; }

echo -e "Checking apache conf."
grep $USERNAME /etc/httpd/conf/httpd.conf
ls /usr/local/apache/conf/userdata/std/2/$USERNAME/$DOMAIN/*.conf

echo -e "Restart apache? [y/n]"
read proceed
if [ $proceed == "y" ]; then
	httpd restart || { echo 'apache restart failed!' >&2; exit 1; }
fi

echo -e "Add the following A record to the ccjclearline.com zone:"
echo -e "$USERNAME IN A $IP"
echo ""
echo -e "Add the following to ns10:/etc/named.conf.local"
echo -e "zone "$DOMAIN" {type slave; file "cac/$DOMAIN"; masters{$IP;};};"