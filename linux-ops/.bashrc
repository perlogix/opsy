function batppf() {
  bat -ppf "$1"
}

function audit() {
  echo -e "\033[1mSystemD:  \033[0m $(sudo systemctl --failed --no-pager | grep -v UNIT)"
  echo -e "\033[1mDmesg:    \033[0m \n$(sudo dmesg -tP --level=err,emerg,crit,alert | sed 's/^/           /')"
  echo -e "\033[1mJournal:    \033[0m \n$(sudo journalctl -p "emerg".."err" --no-pager -b | grep -v 'kernel\|Logs\|ssh'| sed 's/^/           /')"
  echo -e "\033[1mSecureBoot:  \033[0m \n$(mokutil --sb-state 2>/dev/null | sed 's/^/           /')"
  echo -e "\033[1mVulnerabilities:  \033[0m \n$(grep -r . /sys/devices/system/cpu/vulnerabilities/ 2>/dev/null | sed 's/^/           /')"
}

function extract () {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
    echo "'$1' is not a valid file"
  fi
}

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias audit=audit
alias bat=batppf
alias c='clear'
alias cpr='rsync -ah --info=progress2'
alias crons='sudo find /var/spool/cron /etc/crontab /etc/anacrontab -type f -exec cat {} \; 2>/dev/null | grep -v "^#\|^[A-Z]"| sed -e "s/[[:space:]]\+/ /g" | awk NF'
alias df="df -hT"
alias diff="delta -s"
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'
alias dpkg='sudo dpkg'
alias du='du -h'
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode}'
alias extract=extract
alias ff='find . -name'
alias fgrep='fgrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode}'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode}'
alias halt='sudo /sbin/halt'
alias h='history'
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias ll='lsd -lh'
alias lsa='lsd -lah'
alias mkdir='mkdir -p'
alias netfiles='sudo lsof -i 4 2>/dev/null'
alias netstat='sudo netstat -tulanp'
alias netreset='sudo systemd-resolve --flush-caches && sudo nmcli networking off && sudo nmcli networking on'
alias old='lsd -lt  | tail -n 10'
alias journalctl='sudo journalctl'
alias json='python3 -m json.tool'
alias more='less'
alias new='lsd -ltr  | tail -n 10'
alias path='echo $PATH | tr -s ":" "\n"'
alias poweroff='sudo sync && systemctl poweroff'
alias pkill='sudo pkill -9 -f'
alias pubip='dig @1.1.1.1 ch txt whoami.cloudflare +short | cut -d\" -f 2'
alias reboot='sudo sync && sudo systemctl reboot'
alias restart='sudo systemctl --no-ask-password try-restart'
alias serve='python3 -m http.server'
alias services='sudo systemctl list-unit-files --no-legend --type=service --state=enabled --no-pager'
alias shutdown='sudo sync && systemctl poweroff'
alias scp='scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias ssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias systemctl='sudo systemctl'
alias top='btm -g --hide_time --hide_table_gap'
alias topcpu='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topfiles='find . -type f -exec du -Sh {} + | sort -rh | head'
alias topmem='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias topof='sudo lsof 2>/dev/null | cut -d" " -f1 | sort | uniq -c | sort -r -n | head'
alias timers='sudo systemctl list-timers --all --no-pager'
alias tree='lsd --tree'
alias root='sudo su -'
alias vi='vim'
alias q='exit'
alias quit='exit'

export VISUAL=vim
export EDITOR=$VISUAL
export PAGER=less
export HISTSIZE=3000
export HISTCONTROL=ignoredups:erasedups
export GIT_PAGER="delta -s"
export FZF_COMPLETION_TRIGGER='**'
export BAT_THEME="Sublime Snazzy"
eval "$(starship init bash)"
