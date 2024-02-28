#!/bin/bash

if [ $# -ne 1 ];
then
	echo "Usage $0 <config_dir>"
	exit 1
fi

if [ ! -d $1 ];
then
	echo "Need config as directory"
	exit 1
fi

mkdir -p ./data/websites
mkdir -p ./data/mariadb

port=9000
echo "#!/bin/bash" > ./srcs/requirements/mariadb/tools/create_db.sh
echo "mariadbd --user=mysql &"  >> ./srcs/requirements/mariadb/tools/create_db.sh
echo "sleep 4"     >> ./srcs/requirements/mariadb/tools/create_db.sh >> ./srcs/requirements/mariadb/tools/create_db.sh
for element in $1/*;
do
	if [ -d $element ];
	then
		website=$(basename $element)
		db_name=$(grep SQL_DATABASE "$element/env" | cut -d '=' -f 2)
		db_user=$(grep SQL_USER "$element/env" | cut -d '=' -f 2)
		db_pass=$(grep SQL_PASS "$element/env" | cut -d '=' -f 2)
		echo "Creating website $website"
		echo "db_name: $db_name"
		echo "db_user: $db_user"
		echo "db_pass: $db_pass"
		echo "php_port: $port"
		# Creation du virtualhost pour apache2
		cat << EOF > ./srcs/requirements/apache2/conf/confs/$website.conf
<VirtualHost *:80>
    ServerName $website
    ServerAlias www.$website
    DocumentRoot /var/www/websites/$website
    ErrorLog /var/log/apache2/$website.error.log
    CustomLog /var/log/apache2/$website.access.log combined

    <Directory /var/www/websites/$website>
        Options Indexes FollowSymLinks
        AllowOverride none
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:fcgi://php:$port"
    </FilesMatch>

    RewriteEngine on
    RewriteCond %{SERVER_NAME} =$website [OR]
    RewriteCond %{SERVER_NAME} =www.$website
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF
		cat << EOF > ./srcs/requirements/apache2/conf/confs/$website-ssl.conf
<VirtualHost *:443>
    ServerName $website
    ServerAlias www.$website
    DocumentRoot /var/www/websites/$website
    ErrorLog /var/log/apache2/$website.error.log
    CustomLog /var/log/apache2/$website.access.log combined

    <Directory /var/www/websites/$website>
        Options Indexes FollowSymLinks
        AllowOverride none
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:fcgi://php:$port"
    </FilesMatch>

    SSLEngine on
    SSLCertificateFile /etc/apache2/certificate/$website.crt
    SSLCertificateKeyFile /etc/apache2/certificate/$website.key
</VirtualHost>
EOF
		# Creation du certificat ssl
		openssl req \
			-x509 \
			-nodes \
			-days 365 \
			-newkey rsa:2048 \
			-keyout ./srcs/requirements/apache2/conf/certs/$website.key \
			-out ./srcs/requirements/apache2/conf/certs/$website.crt

		# Creation de la db pour mariadb
		cat << EOF > ./srcs/requirements/mariadb/tools/$website.sql
CREATE DATABASE IF NOT EXISTS $db_name;
CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pass';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';
FLUSH PRIVILEGES;
EOF
		echo "mariadb < $website.sql" >> ./srcs/requirements/mariadb/tools/create_db.sh
		# Creation de la config pour php-fpm
		cat << EOF > ./srcs/requirements/php/conf/confs/$website.conf
[$website]
user = nobody
listen = $port
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /var/www/websites/$website
EOF
		# Creation du dossier du site
		mkdir -p ./data/websites/$website
		cp $element/data/* ./data/websites/$website

		echo ""
		echo ""

		((port++))
		if (( port > 9020 ));
		then
			echo "Cant build next, need to add more EXPOSE in php Dockerfile !!!"
			break
		fi
	else
		echo "$element not a folder, passing !!!"
	fi
done
echo "kill %1" >> ./srcs/requirements/mariadb/tools/create_db.sh >> ./srcs/requirements/mariadb/tools/create_db.sh

sleep 1

docker compose -f ./srcs/docker-compose.yml build

rm -rf ./srcs/requirements/apache2/conf/confs/*
rm -rf ./srcs/requirements/apache2/conf/certs/*
rm -rf ./srcs/requirements/php/conf/confs/*
rm -rf ./srcs/requirements/php/tools/*
rm -rf ./srcs/requirements/mariadb/tools/*
