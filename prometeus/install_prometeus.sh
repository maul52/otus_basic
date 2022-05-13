download
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
# unpack
tar xzvf prometheus-2.35.0.linux-amd64.tar.gz
#add user
useradd --no-create-home --shell /usr/sbin/nologin prometheus
# Создаём папки и копируем файлы
mkdir {/etc/,/var/lib/}prometheus
cp -vi prometheus-2.35.0.linux-amd64/prom{etheus,tool} /usr/local/bin
cp -rvi prometheus-2.35.0.linux-amd64/{console{_libraries,s},prometheus.yml} /etc/prometheus/
chown -Rv prometheus: /usr/local/bin/prom{etheus,tool} /etc/prometheus/ /var/lib/prometheus/
# Accept iptables
iptables -A INPUT -p tcp --dport 9090 -j ACCEPT
service iptables save

# Проверка запуска вручную
#sudo -u prometheus /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

# Настраиваем сервис
#cat > /etc/systemd/system/prometheus.service

echo '################################' > /etc/systemd/system/prometheus.service
echo [Unit] >> /etc/systemd/system/prometheus.service
echo Description=Prometheus Monitoring >> /etc/systemd/system/prometheus.service
echo Wants=network-online.target >> /etc/systemd/system/prometheus.service
echo After=network-online.target >> /etc/systemd/system/prometheus.service
echo '' >> /etc/systemd/system/prometheus.service
echo [Service] >> /etc/systemd/system/prometheus.service
echo User=prometheus >> /etc/systemd/system/prometheus.service
echo Group=prometheus >> /etc/systemd/system/prometheus.service
echo Type=simple >> /etc/systemd/system/prometheus.service
echo 'ExecStart=/usr/local/bin/prometheus \' >> /etc/systemd/system/prometheus.service
echo '--config.file /etc/prometheus/prometheus.yml \' >> /etc/systemd/system/prometheus.service
echo '--storage.tsdb.path /var/lib/prometheus/ \' >> /etc/systemd/system/prometheus.service
echo '--web.console.templates=/etc/prometheus/consoles \' >> /etc/systemd/system/prometheus.service
echo '--web.console.libraries=/etc/prometheus/console_libraries' >> /etc/systemd/system/prometheus.service
echo 'ExecReload=/bin/kill -HUP $MAINPID' >> /etc/systemd/system/prometheus.service
echo '' >> /etc/systemd/system/prometheus.service
echo [Install] >> /etc/systemd/system/prometheus.service
echo WantedBy=multi-user.target >> /etc/systemd/system/prometheus.service
echo '#################################' >> /etc/systemd/system/prometheus.service

# Конфиг prometheus
#cat > /etc/prometheus/prometheus.yml
echo "#####################################" > /etc/prometheus/prometheus.yml
echo "# my global config" >> /etc/prometheus/prometheus.yml
echo global: >> /etc/prometheus/prometheus.yml
echo "  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute." >> /etc/prometheus/prometheus.yml
echo "  evaluation_interval: 15s "# Evaluate rules every 15 seconds. The default is every 1 minute." >> /etc/prometheus/prometheus.yml
echo "  # scrape_timeout is set to the global default (10s)." >> /etc/prometheus/prometheus.yml
echo "" >> /etc/prometheus/prometheus.yml
echo "# Alertmanager configuration" >> /etc/prometheus/prometheus.yml
echo alerting: >> /etc/prometheus/prometheus.yml
echo "  alertmanagers:" >> /etc/prometheus/prometheus.yml
echo "  - static_configs:" >> /etc/prometheus/prometheus.yml
echo "    - targets:" >> /etc/prometheus/prometheus.yml
echo "      # - alertmanager:9093" >> /etc/prometheus/prometheus.yml
echo  >> /etc/prometheus/prometheus.yml
echo "# Load rules once and periodically evaluate them according to the global 'evaluation_interval'." >> /etc/prometheus/prometheus.yml
echo rule_files: >> /etc/prometheus/prometheus.yml
echo "  # - "first_rules.yml"" >> /etc/prometheus/prometheus.yml
echo "  # - "second_rules.yml"" >> /etc/prometheus/prometheus.yml
echo  >> /etc/prometheus/prometheus.yml
echo "# A scrape configuration containing exactly one endpoint to scrape:" >> /etc/prometheus/prometheus.yml
echo "# Here it's Prometheus itself." >> /etc/prometheus/prometheus.yml
echo scrape_configs: >> /etc/prometheus/prometheus.yml
echo "  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config." >> /etc/prometheus/prometheus.yml
echo "  - job_name: 'prometheus'" >> /etc/prometheus/prometheus.yml
echo  >> /etc/prometheus/prometheus.yml
echo "    # metrics_path defaults to '/metrics'" >> /etc/prometheus/prometheus.yml
echo "    # scheme defaults to 'http'." >> /etc/prometheus/prometheus.yml
echo  >> /etc/prometheus/prometheus.yml
echo "    static_configs:" >> /etc/prometheus/prometheus.yml
echo "    - targets: ['localhost:9090']" >> /etc/prometheus/prometheus.yml
echo >> /etc/prometheus/prometheus.yml  
echo "  - job_name: 'node_exporter'" >> /etc/prometheus/prometheus.yml
echo "    scrape_interval: 5s" >> /etc/prometheus/prometheus.yml
echo "    static_configs:" >> /etc/prometheus/prometheus.yml
echo "      - targets: ['localhost:9100']" >> /etc/prometheus/prometheus.yml
echo "###############################################################" >> /etc/prometheus/prometheus.yml

# Запускаем сервис Prometheus
systemctl daemon-reload
systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus

