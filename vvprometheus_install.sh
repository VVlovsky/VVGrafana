#!/bin/sh

sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

sudo apt-get update && apt-get upgrade
wget https://github.com/prometheus/prometheus/releases/download/v2.29.1/prometheus-2.29.1.linux-amd64.tar.gz
tar xfz prometheus-*.tar.gz
cd prometheus-2.29.1.linux-amd64

sudo cp ./prometheus /usr/local/bin/
sudo cp ./promtool /usr/local/bin/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo cp -r ./consoles /etc/prometheus
sudo cp -r ./console_libraries /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

cd .. && rm -rf prometheus*

sudo tee <<EOF > /dev/null /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first.rules"
  # - "second.rules"

scrape_configs:
  - job_name: "prometheus"
    scrape_interval: 5s
    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "substrate_node"
    scrape_interval: 5s
    static_configs:
      - targets: ["localhost:9615"]
  - job_name: node
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

sudo tee <<EOF > /dev/null /etc/systemd/system/prometheus.service
[Unit]
  Description=Prometheus Monitoring
  Wants=network-online.target
  After=network-online.target

[Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries
  ExecReload=/bin/kill -HUP $MAINPID

[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable prometheus && systemctl start prometheus
