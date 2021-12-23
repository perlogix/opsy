#!/bin/bash

for users in games gnats irc list news sync uucp; do
    userdel -r "$users" 2>/dev/null
done

command -v grpck && yes | grpck

find /boot/ -type f -name '*.cfg' -exec chmod -f 0400 {} \; 2>/dev/null

find / -nouser -exec chown -f root {} \; 2>/dev/null

find / -nogroup -exec chown -f :root {} \; 2>/dev/null

find / -xdev -perm +o=w ! \( -type d -perm +o=t \) ! -type l -ok chmod -v o-w {} \; 2>/dev/null

find /home -maxdepth 1 -mindepth 1 -type d -exec chmod -f 0700 {} \;

chmod -Rf g-wx,o-rwx /var/log/*
chmod -f 0640 /var/log/btmp

chmod -f 0750 /etc/sudoers.d
chmod -f 0440 /etc/sudoers.d/*

echo 'root' >/etc/cron.allow
echo 'root' >/etc/at.allow

chmod -f 0700 /etc/cron.{d,daily,hourly,monthly,weekly}
chmod -f 0700 /etc/cron.*/*
chmod -f 0755 /var/spool/cron/crontabs
chmod -f 0600 /var/spool/anacron/cron.*
chmod -f 0600 /var/spool/at/*
chmod -f 0600 /var/spool/cron/crontabs/*
chmod -f 0400 /etc/crontab
chmod -f 0400 /etc/cron.allow
chmod -f 0400 /etc/at.allow

chown -f root:root /etc/ssh/sshd_config
chmod -f og-rwx /etc/ssh/sshd_config

chmod -f 0640 /etc/login.defs

chown -f root:root /etc/passwd
chmod -f 0644 /etc/passwd

chown -f root:shadow /etc/shadow
chmod -f o-rwx,g-wx /etc/shadow

chown -f root:root /etc/group
chmod -f 0644 /etc/group

chown -f root:shadow /etc/gshadow
chmod -f o-rwx,g-rw /etc/gshadow

chown -f root:root /etc/passwd-
chmod -f 0600 /etc/passwd-

chown -f root:root /etc/shadow-
chmod -f 0600 /etc/shadow-

chown -f root:root /etc/group-
chmod -f 0600 /etc/group-

chown -f root:root /etc/gshadow-
chmod -f 0600 /etc/gshadow-

chown -Rf root:root /var/cache/private

chmod -f 700 /boot /etc/{iptables,arptables}

chown -f root:root /etc/modprobe.d/*.conf
chmod -f 0644 /etc/modprobe.d/*.conf

chown -f root:root /etc/grub.conf
chown -Rf root:root /etc/grub.d
chmod -f og-rwx /etc/grub.conf
chmod -Rf og-rwx /etc/grub.d

chmod -f 0640 /etc/cups/cupsd.conf

passwd -l root