#!/bin/bash

# Sync time
if [ "$(systemctl status systemd-timesyncd.service | grep 'Active: active')" != "" ]; then
    systemctl restart systemd-timesyncd.service
fi

# Clean unused Docker resources
if [ "$(command -v docker)" ]; then
    # Update ecs-agent if present
    if [ "$(docker ps | grep amazon/amazon-ecs-agent)" != "" ]; then
        docker pull amazon/amazon-ecs-agent:latest
    fi
    docker system prune -a -f
fi

# Update flatpaks
command -v flatpak && flatpak update -y -v

# Update PI firmware
command -v rpi-eeprom-config && rpi-eeprom-config -a

# Update firmware
if [ "$(command -v fwupdmgr)" ]; then
    fwupdmgr refresh --force
    fwupdmgr update -y
fi

if [ "$(command -v swupd)" ]; then
    # Update Clear Linux
    swupd update -y
    # Repair Clear Linux
    swupd repair -y -x
    # Clean Clear Linux Updates
    swupd clean -y
fi

if [ "$(command -v dpkg)" ]; then
  # Fix or clean any lock files
  rm -f /var/lib/dpkg/updates/*
  # Remove all linux kernels except the current one
  dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt purge -y
  # Remove old Linux source
  dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt purge -y
fi

if [ "$(command -v apt)" ]; then
  # Fix or clean any lock files
  rm -f /var/lib/apt/lists/lock
  rm -f /var/cache/apt/archives/lock
  # Upgrade packages
  apt update -y
  ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt upgrade -y
  # Clean garbage
  apt autoremove -y --purge
  apt -y autoclean
  apt -y clean
fi

if [ "$(command -v yum)" ]; then
  yum update -y
  yum clean all
  rm -rf /var/cache/yum
fi

# Upgrade and remove old snaps
if [ "$(command -v snap)" ]; then
  snap set system refresh.retain=2
  snap refresh
  snap list --all | awk '/disabled/{print $1, $3}' | while read -r snapname revision; do snap remove "$snapname" --revision="$revision"; done
fi

# Clean journal
if [ "$(command -v journalctl)" ]; then
  journalctl --rotate
  journalctl --vacuum-files=2
  journalctl --vacuum-size=100M
fi

# BleachBit Cleaner
if [ "$(command -v bleachbit)" ]; then
  bleachbit --clean adobe_reader.cache \
    adobe_reader.mru \
    adobe_reader.tmp \
    apt.autoclean \
    apt.autoremove \
    apt.clean \
    apt.package_lists \
    deepscan.backup \
    deepscan.ds_store \
    deepscan.thumbs_db \
    deepscan.tmp \
    deepscan.vim_swap_root \
    deepscan.vim_swap_user \
    evolution.cache \
    firefox.crash_reports \
    flash.cache \
    flash.cookies \
    gedit.recent_documents \
    gimp.tmp \
    gnome.run \
    gnome.search_history \
    java.cache \
    journald.clean \
    libreoffice.cache \
    libreoffice.history \
    nautilus.history \
    openofficeorg.cache \
    openofficeorg.recent_documents \
    screenlets.logs \
    skype.chat_logs \
    skype.installers \
    slack.cache \
    sqlite3.history \
    system.cache \
    system.localizations \
    system.recent_documents \
    system.rotated_logs \
    system.tmp \
    system.trash \
    thumbnails.cache \
    x11.debug_logs \
    zoom.cache \
    zoom.logs
    
  # BleachBit for all users
  grep home /etc/passwd | grep -v 'nologin\|false' | awk -F':' '{ print $ 1 }' | while IFS= read -r user; do
    runuser -l "$user" -c "bleachbit --clean adobe_reader.cache \
  adobe_reader.mru \
  adobe_reader.tmp \
  apt.autoclean \
  apt.autoremove \
  apt.clean \
  apt.package_lists \
  deepscan.backup \
  deepscan.ds_store \
  deepscan.thumbs_db \
  deepscan.tmp \
  deepscan.vim_swap_root \
  deepscan.vim_swap_user \
  evolution.cache \
  firefox.crash_reports \
  flash.cache \
  flash.cookies \
  gedit.recent_documents \
  gimp.tmp \
  gnome.run \
  gnome.search_history \
  java.cache \
  journald.clean \
  libreoffice.cache \
  libreoffice.history \
  nautilus.history \
  openofficeorg.cache \
  openofficeorg.recent_documents \
  screenlets.logs \
  skype.chat_logs \
  skype.installers \
  slack.cache \
  sqlite3.history \
  system.cache \
  system.localizations \
  system.recent_documents \
  system.rotated_logs \
  system.tmp \
  system.trash \
  thumbnails.cache \
  x11.debug_logs \
  zoom.cache \
  zoom.logs"
  done
fi

# Clean hidden temp and cache files
for n in $(find / -type d \( -name ".tmp" -o -name ".temp" -o -name ".cache" \) 2>/dev/null); do find "$n" -type f -delete; done

# Clean old logs
find /var/log -name '*.log' -type f -mtime +30 -delete
find /var/log -name '*.gz' -type f -delete
find /var/log -name '*.log.[0-9$]' -type f -delete

# Clear contents of log files bigger than 100M
for log in $(find / -type f -size +100M 2>/dev/null | grep '\.log$\|\.log.old$\|\.log.bk$\|\.log.backup$'); do
  echo >"$log"
done

# Set 0600 to SSH files
for n in $(find / -type d -name ".ssh" 2>/dev/null); do find "$n" -type f -exec chmod -f 0600 {} +; done

# Set files and dirs without user to root
find / -nouser -exec chown -f root {} \; 2>/dev/null

# Set files and dirs without group to root
find / -nogroup -exec chown -f :root {} \; 2>/dev/null

# Remove other world writable permissions on all files
find / -xdev -perm +o=w ! \( -type d -perm +o=t \) ! -type l -ok chmod -v o-w {} \; 2>/dev/null

# Set home directories to 0750 permissions
find /home -maxdepth 1 -mindepth 1 -type d -exec chmod -f 0700 {} \;

# Remove group and other permissions on log files
chmod -Rf g-wx,o-rwx /var/log/*

# Trim SSD
command -v fstrim && fstrim -v /