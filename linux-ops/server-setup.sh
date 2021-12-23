#!/bin/bash

# Disable Services
systemctl disable bluetooth
systemctl disable openvpn
systemctl disable NetworkManager-wait-online
systemctl disable motd-news.timere
systemctl --user mask tracker-extract
systemctl --user mask tracker-miner-fs
systemctl --user mask tracker-store

# APT Based System Setup
if [ "$(command -v apt-get)" != "" ]; then
  sed -i 's|Prompt=.*|Prompt=never|g' /etc/update-manager/release-upgrades
  sed -i 's/APT::Periodic::Unattended-Upgrade.*/APT::Periodic::Unattended-Upgrade "0";/' /etc/apt/apt.conf.d/20auto-upgrades
  echo 'APT::Acquire::Queue-Mode "access";' >/etc/apt/apt.conf.d/99parallel
  echo 'APT::Acquire::Retries 3;' >>/etc/apt/apt.conf.d/99parallel
  echo 'Acquire::Languages "none";' >>/etc/apt/apt.conf.d/00aptitude

  apt-get update -y
  apt-get remove -y whoopsie apport apport-gtk ubuntu-report unattended-upgrades kerneloops plymouth thunderbird transmission-common cheese aisleriot gnome-mahjongg gnome-mines gnome-sudoku remmina mlocate
  ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt upgrade -y
  apt-get autoremove -y
  ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt install -y tuned curl jq vim net-tools
fi

# Snap Based System Setup
if [ "$(command -v snap)" != "" ]; then
  snap set system refresh.retain=2
  snap refresh
fi

# YUM Based System Setup
if [ "$(command -v yum)" != "" ]; then
  yum remove -y mlocate
  yum update -y
  yum install -y tuned curl vim jq net-tools
  yum clean all
fi

# Clear Linux System Setup
if [ "$(command -v swupd)" != "" ]; then
  clr_power --server
  swupd update -y
  swupd repair -y -x
  clr-boot-manager update
  swupd bundle-add -y net-tools cloud-control vim jq curl firmware-update sysadmin-basic
  swupd clean -y
fi

# Raspberry Pi Setup
if [ -f "/boot/firmware/config.txt" ]; then
  echo 'arm_freq=1900' >>/boot/firmware/config.txt
  echo 'over_voltage=4' >>/boot/firmware/config.txt
fi

# System Log Setup
sed -i 's/rotate [0-9]/rotate 1/g' /etc/logrotate.d/*
sed -i 's/weekly\|monthly/daily/g' /etc/logrotate.d/*
sed -i 's/rotate [0-9]/rotate 1/g' /etc/logrotate.conf
sed -i 's/weekly\|monthly/daily/g' /etc/logrotate.conf
sed -i 's/#SystemMaxFiles=100/SystemMaxFiles=7/g' /etc/systemd/journald.conf
sed -i 's/^#DumpCore=.*/DumpCore=no/' /etc/systemd/system.conf
sed -i 's/^#CrashShell=.*/CrashShell=no/' /etc/systemd/system.conf
journalctl --vacuum-time=1d
journalctl --vacuum-files=2
journalctl --vacuum-size=100M

# Rewrite fstab Defaults
sed -i 's/defaults.*/defaults,noatime,nodiratime  1  1/g' /etc/fstab

# Setup RC Local
cat <<'EOF' >/etc/systemd/system/rc-local.service
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
EOF

cat <<'EOF' >/etc/rc.local
#!/bin/sh
for d in /sys/block/[m,s,n,x]*; do
  printf 1024 > "$d"/queue/nr_requests
  printf 1024 > "$d"/queue/read_ahead_kb
  printf 1 > "$d"/queue/add_random
  printf 2 > "$d"/queue/rq_affinity
  printf 1 > "$d"/queue/iosched/low_latency
done
exit 0
EOF

chmod -f 0755 /etc/rc.local

systemctl daemon-reload
systemctl enable rc-local

# Enable TCP BBR
modprobe tcp_bbr

# Setup Sysctl Parameters
cat <<'EOF' >/etc/sysctl.d/99-sysctl.conf
fs.aio-max-nr=1048576
fs.epoll.max_user_watches=12616437
fs.file-max=9223372036854775807
fs.file-nr=736 0 9223372036854775807
fs.inotify.max_queued_events=524288
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=524288
fs.nr_open=1073741816
fs.suid_dumpable=0
kernel.core_pattern=/bin/false
kernel.dmesg_restrict=1
kernel.panic=5
kernel.pid_max=65536
kernel.printk=3 3 3 3
net.core.default_qdisc=fq
net.core.netdev_max_backlog=4096
net.core.rmem_max=16777216
net.core.somaxconn=65535
net.core.wmem_max=16777216
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_early_retrans=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_max_syn_backlog=8096
net.ipv4.tcp_max_tw_buckets=1440000
net.ipv4.tcp_moderate_rcvbuf=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 12582912 16777216
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_wmem=4096 12582912 16777216
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
vm.dirty_background_ratio=5
vm.dirty_expire_centisecs=12000
vm.dirty_ratio=50
vm.dirty_writeback_centisecs=1500
vm.extfrag_threshold=100
vm.max_map_count=262144
vm.min_free_kbytes=80000
vm.mmap_min_addr=65536
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

sysctl -p /etc/sysctl.d/99-sysctl.conf

# Increase File Limits
cat <<'EOF' >/etc/security/limits.d/99-limits.conf
* soft nofile 999999
* hard nofile 999999
root soft nofile 999999
root hard nofile 999999

* soft stack unlimited
* hard stack unlimited
root soft stack unlimited
root hard stack unlimited
EOF

# Enable Tuned
if [ "$(command -v tuned-adm)" != "" ]; then
  systemctl enable tuned
  tuned-adm profile "$(tuned-adm recommend 2>/dev/null)"
fi
