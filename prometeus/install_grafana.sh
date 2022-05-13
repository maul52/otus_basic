#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	# user not root
	echo "Please run script as root(use sudo)" 
	exit 1
fi

# Установка Grafana
#cat > /etc/yum.repos.d/grafana.repo
# Добавляем репозиторий
echo "#################################" > /etc/yum.repos.d/grafana.repo
echo [grafana] >> /etc/yum.repos.d/grafana.repo
echo name=grafana >> /etc/yum.repos.d/grafana.repo
echo baseurl=https://packages.grafana.com/oss/rpm >> /etc/yum.repos.d/grafana.repo
echo repo_gpgcheck=1 >> /etc/yum.repos.d/grafana.repo
echo enabled=1 >> /etc/yum.repos.d/grafana.repo
echo gpgcheck=1 >> /etc/yum.repos.d/grafana.repo
echo gpgkey=https://packages.grafana.com/gpg.key >> /etc/yum.repos.d/grafana.repo
echo sslverify=1 >> /etc/yum.repos.d/grafana.repo
echo sslcacert=/etc/pki/tls/certs/ca-bundle.crt >> /etc/yum.repos.d/grafana.repo
echo "#################################" >> /etc/yum.repos.d/grafana.repo

yum install -y grafana

# Accept iptables
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
service iptables save

mkdir /var/lib/grafana/plugins/

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
systemctl status grafana-server

read -p "Install complite, REBOOT NOW? (y or n) " yn
    case $yn in
        [Yy]* ) echo "!!! Reboot !!!"; reboot;;
        [Nn]* ) exit;;
    esac
