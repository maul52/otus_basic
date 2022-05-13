#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	# user not root
	echo "Please run script as root(use sudo)" 
	exit 1
fi

yum install -y {jnet,h,io,if,a}top iptraf nmon
#скачиваем
#wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
#wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
#wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.14.0/mysqld_exporter-0.14.0.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
#распаковываем
tar xzvf node_exporter-1.3.1.linux-amd64.tar.gz
#tar xzvf prometheus-2.35.0.linux-amd64.tar.gz
#add user
#useradd --no-create-home --shell /usr/sbin/nologin prometheus
useradd --no-create-home --shell /bin/false node_exporter
#copy and change permission
cp ./node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter: /usr/local/bin/node_exporter

# Создаём службу node exporter

#cat > /etc/systemd/system/node_exporter.service

echo '##############################' > /etc/systemd/system/node_exporter.service
echo [Unit] >> /etc/systemd/system/node_exporter.service
echo Description=Node Exporter >> /etc/systemd/system/node_exporter.service
echo Wants=network-online.target >> /etc/systemd/system/node_exporter.service
echo After=network-online.target >> /etc/systemd/system/node_exporter.service
echo  >> /etc/systemd/system/node_exporter.service
echo [Service] >> /etc/systemd/system/node_exporter.service
echo User=node_exporter >> /etc/systemd/system/node_exporter.service
echo Group=node_exporter >> /etc/systemd/system/node_exporter.service
echo Type=simple >> /etc/systemd/system/node_exporter.service
echo ExecStart=/usr/local/bin/node_exporter >> /etc/systemd/system/node_exporter.service
echo >> /etc/systemd/system/node_exporter.service
echo [Install] >> /etc/systemd/system/node_exporter.service
echo WantedBy=multi-user.target >> /etc/systemd/system/node_exporter.service
echo '###############################' >> /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl start node_exporter
systemctl status node_exporter
systemctl enable node_exporter

iptables -A INPUT -p tcp --dport 9100 -j ACCEPT
service iptables save

curl localhost:9100
curl localhost:9100/metrics
