#!/bin/sh

#NODE EXPORTER

wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar xvf node_exporter-1.1.2.linux-amd64.tar.gz

# copy binary
cp node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin

# set ownership
# sudo chown prometheus:prometheus /usr/local/bin/node_exporter

rm -rf node_exporter*

sudo tee <<EOF > /dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable node_exporter && systemctl start node_exporter
