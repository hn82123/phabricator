#!/bin/bash

/test_dbms_started.sh

cd /var/phabricator/phabricator/
bin/config set "diffusion.ssh-user" 	"git"
bin/config set "phd.user"           	"phd"
bin/config set "mysql.host"     	"$MYSQL_PORT_3306_TCP_ADDR"
bin/config set "mysql.pass"     	"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
bin/config set "mysql.user"     	"root"
bin/config set "phabricator.base-uri"   "http://phd.emsym.com/"
bin/config set "storage.local-disk.path" "/var/phabricator_files/"

bin/storage upgrade --force 
bin/phd start

/usr/sbin/sshd -f /etc/ssh/sshd_config.phabricator
/usr/sbin/php5-fpm

exec "$@"
