export ZSH=$HOME/.oh-my-zsh

function prompt_my_cpu_temp() {
  if [[ ! -f /sys/class/thermal/thermal_zone0/temp ]]; then
    return
  fi
  integer cpu_temp="$(</sys/class/thermal/thermal_zone0/temp) / 1000"
  if ((cpu_temp >= 80)); then
    p10k segment -s HOT -f red -t "${cpu_temp}"$'\uE339' -i $'\uF737'
  elif ((cpu_temp >= 60)); then
    p10k segment -s WARM -f yellow -t "${cpu_temp}"$'\uE339' -i $'\uE350'
  else
    p10k segment -s COLD -f green -t "${cpu_temp}"$'\uE339' -i $'\uE350'
  fi
}

function batppf() {
  bat -ppf "$1"
}

function audit() {
  echo -e "\033[1mSystemD:  \033[0m $(sudo systemctl --failed --no-pager | grep -v UNIT)"
  echo -e "\033[1mDmesg:    \033[0m \n$(sudo dmesg -tP --level=err,emerg,crit,alert | sed 's/^/           /')"
  echo -e "\033[1mJournal:    \033[0m \n$(sudo journalctl -p "emerg..err" --no-pager -b | grep -v 'kernel\|Logs\|ssh'| sed 's/^/           /')"
  echo -e "\033[1mSecureBoot:  \033[0m \n$(mokutil --sb-state 2>/dev/null | sed 's/^/           /')"
  echo -e "\033[1mVulnerabilities:  \033[0m \n$(grep -r . /sys/devices/system/cpu/vulnerabilities/ 2>/dev/null | sed 's/^/           /')"
}

function keybindings() {
  {
    gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys &
    gsettings list-recursively org.gnome.desktop.wm.keybindings
  } | awk '{sub($1 FS, "")}7' | sort
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

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_beginning
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
POWERLEVEL9K_DISABLE_GITSTATUS=true
POWERLEVEL9K_TIME_FORMAT='%D{%I:%M}'
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B2'
POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B0'
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{blue}╭─'
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{blue}╰%f '
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time my_cpu_temp ram load disk_usage)

plugins=(
  fzf
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
)

source "$ZSH"/oh-my-zsh.sh
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias apt-get='sudo apt-get'
alias apt='sudo apt'
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
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias extract=extract
alias ff='find . -name'
alias flightoff='sudo rfkill unblock all'
alias flighton='sudo rfkill block all'
alias fgrep='fgrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode,node_modules,vendor,.clangd,__pycache__,.npm,.cache,.composer}'
alias halt='sudo sync && sudo systemctl halt'
alias h='history'
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias ll='lsd -lh'
alias lsa='lsd -lah'
alias climit='cpulimit -l $((20 * $(nproc --all))) -b -z -q -e'
alias mkdir='mkdir -p'
alias mute='amixer set Master mute'
alias netfiles='sudo lsof -i 4 2>/dev/null'
alias netstat='sudo netstat -tulanp'
alias netreset='sudo systemd-resolve --flush-caches && sudo nmcli networking off && sudo nmcli networking on'
alias open='xdg-open'
alias old='lsd -lt  | tail -n 10'
alias journalctl='sudo journalctl'
alias json='python3 -m json.tool'
alias keybindings=keybindings
alias more='less'
alias new='lsd -ltr  | tail -n 10'
alias path='echo $PATH | tr -s ":" "\n"'
alias poweroff='sudo sync && systemctl poweroff'
alias pkill='sudo pkill -9 -f'
alias pubip='dig @1.1.1.1 ch txt whoami.cloudflare +short | cut -d\" -f 2'
alias reboot='sudo sync && sudo systemctl reboot'
alias restart='sudo systemctl --no-ask-password try-restart'
alias serve='python3 -m http.server'
alias service='sudo service'
alias services='sudo systemctl list-unit-files --no-legend --type=service --state=enabled --no-pager'
alias shutdown='sudo sync && systemctl poweroff'
alias scp='scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias snap='sudo snap'
alias ssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias systemctl='sudo systemctl'
alias tb='nc termbin.com 9999'
alias top='btm -g --hide_time --hide_table_gap'
alias topcpu='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topfiles='find . -type f -exec du -Sh {} + | sort -rh | head'
alias topmem='sudo ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
alias topof='sudo lsof 2>/dev/null | cut -d" " -f1 | sort | uniq -c | sort -r -n | head'
alias timers='sudo systemctl list-timers --all --no-pager'
alias tree='lsd --tree'
alias root='sudo su -'
alias unmute='amixer set Master unmute && amixer set Headphone unmute'
alias vrm='vagrant box list | cut -f 1 -d " " | xargs -L 1 vagrant box remove -f'
alias vi='vim'
alias wflow='watch -n1 "sudo lsof -i TCP:80,443"'
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

bindkey -s "^[OM" "^M" 2>/dev/null
