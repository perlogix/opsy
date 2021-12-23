#!/bin/sh

# Install baseline
curl -LO https://raw.githubusercontent.com/perlogix/opsy/main/linux-ops/server-setup.sh
curl -LO https://raw.githubusercontent.com/perlogix/opsy/main/linux-ops/maintenance.sh
curl -LO https://raw.githubusercontent.com/perlogix/opsy/main/linux-ops/quick-secure.sh

chmod -f 0755 ./*.sh

./server-setup.sh
./maintenance.sh
./quick-secure.sh

# Setup Maintenance Service
cp -f ./maintenance.sh /opt/

cat <<'EOF' >/etc/systemd/system/maintenance.service
[Unit]
Description=Run Maintenance Update & Clean Up Script
After=network.target

[Service]
ExecStart=/opt/maintenance.sh
StandardOutput=file:/var/log/maintenance.log
StandardError=file:/var/log/maintenance.log

[Install]
WantedBy=default.target
EOF

cat <<'EOF' >/etc/systemd/system/maintenance.timer
[Unit]
Description=Maintenance Update & Clean Up Timer

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now maintenance.timer

# Install cmon
if [ "$(command -v rpm)" != "" ]; then
  curl -LO "$(curl -s https://api.github.com/repos/perlogix/cmon/releases/latest | grep browser_download_url | grep rpm | cut -d '"' -f 4)"
  rpm -i ./cmon*.rpm
  rm -f ./cmon*.rpm
fi

if [ "$(command -v dpkg)" != "" ]; then
  curl -LO "$(curl -s https://api.github.com/repos/perlogix/cmon/releases/latest | grep browser_download_url | grep deb | cut -d '"' -f 4)"
  dpkg -i ./cmon*.deb
  rm -f ./cmon*.deb
fi
