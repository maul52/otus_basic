#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	# user not root
	echo 'Please run script as root(use sudo)" 
	exit 1
fi

read -p "Use VPN? (y , n, x to exit) " yn
    case $yn in
        [Yy]* ) 
		echo 'Install Vpn"
		#vpn install
		yum install yum-plugin-copr
		yum copr enable dsommers/openvpn3
		yum install openvpn3-client
		#vpn config & start
		openvpn3 configs-list
		openvpn3 config-import --config srv.ovpn --persistent
		openvpn3 session-start --config srv.ovpn
		;;
        [Nn]* ) 			
		;;
		[Xx]* ) 
		exit 0	
		;;
    esac

yum -y install nano
#java-latest-openjdk-devel.x86_64

#cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
echo [elasticsearch-7.x] > /etc/yum.repos.d/elasticsearch.repo
echo name=Elasticsearch repository for 7.x packages >> /etc/yum.repos.d/elasticsearch.repo
echo baseurl=https://artifacts.elastic.co/packages/7.x/yum >> /etc/yum.repos.d/elasticsearch.repo
echo gpgcheck=1 >> /etc/yum.repos.d/elasticsearch.repo
echo gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch >> /etc/yum.repos.d/elasticsearch.repo
echo enabled=1 >> /etc/yum.repos.d/elasticsearch.repo
echo autorefresh=1 >> /etc/yum.repos.d/elasticsearch.repo
echo type=rpm-md >> /etc/yum.repos.d/elasticsearch.repo

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch


echo '1 - install filebeat'
echo '2 - install ELK'
read -p 'Select component to install? (1 or 2) ' num
    case $num in
        1 ) 
		echo 'Install filebit"
		yum -y install filebeat
		
		# Filebeat config
		cp ./filebeat.yml/etc/filebeat/filebeat.yml
		# Start
		systemctl enable filebeat
		systemctl restart filebeat
		systemctl restart nginx
		;;
        2 )
		#####################################
		echo 'install ELK'
		yum -y install java-latest-openjdk-devel.x86_64 java-openjdk 
		yum -y install elasticsearch kibana logstash heartbeat-elastic
		rpm -qi elasticsearch 

		# Устанавливаем лимиты памяти для виртуальной машины Java	
		echo '-Xms1g' > /etc/elasticsearch/jvm.options.d/jvm.options
		echo '-Xmx1g' >> /etc/elasticsearch/jvm.options.d/jvm.options
		
		systemctl enable --now elasticsearch.service
		systemctl enable --now logstash
		
		# Accept iptables
		iptables -A INPUT -p tcp --dport 9200 -j ACCEPT
		service iptables save
		curl -X PUT "http://127.0.0.1:9200/mytest_index"
		
		cp ./kibana.yml /etc/kibana/kibana.yml 
		sudo systemctl enable --now kibana

		iptables -A INPUT -p tcp --dport 5601 -j ACCEPT
		service iptables save
		
		cp ./logstash.yml /etc/logstash/logstash.yml
		
		cat > /etc/logstash/conf.d/logstash-nginx-es.conf

		echo 'input {' > /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '    beats {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '        port => 5400' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '    }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '}' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo 'filter {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' grok {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   match => [ "message" , "%{COMBINEDAPACHELOG}+%{GREEDYDATA:extra_fields}"]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   overwrite => [ "message" ]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' mutate {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   convert => ["response", "integer"]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   convert => ["bytes", "integer"]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   convert => ["responsetime", "float"]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' geoip {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   source => "clientip"' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   add_tag => [ "nginx-geoip" ]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' date {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   remove_field => [ "timestamp" ]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' useragent {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   source => "agent"' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '}' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo 'output {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' elasticsearch {' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   hosts => ["localhost:9200"]' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   index => "weblogs-%{+YYYY.MM.dd}"' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '   document_type => "nginx_logs"' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo ' stdout { codec => rubydebug }' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo '}' >> /etc/logstash/conf.d/logstash-nginx-es.conf
		echo >> /etc/logstash/conf.d/logstash-nginx-es.conf
		;;
    esac

echo 'Disconnect VPN'
ACTIVE_SESSIONS=$(openvpn3 sessions-list | grep -i 'path' | awk '{p=index($0, ":");print $2}')
echo $ACTIVE_SESSIONS
openvpn3 session-manage --disconnect --session-path $ACTIVE_SESSIONS
			
