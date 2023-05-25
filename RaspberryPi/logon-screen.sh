#sudo nano /etc/profile.d/motd.sh

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.    
  : .~.'~'.~. :   Uptime.............: ${UPTIME}
 ~ (   ) (   ) ~  Memory.............: `cat /proc/meminfo | grep MemFree | awk {'print $2/1024'}`MB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2/1024'}`MB (Total)
( : '~'.~.'~' : ) Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
 ~ .~ (   ) ~. ~  Running Processes..: `ps ax | wc -l | tr -d " "`
  (  : '~' :  )   IP Addresses.......: 
   '~ .~~~. ~'    Disk Space............: Free: `df -Ph | grep -E '^/dev/root' | awk '{ print $4 }'` | Used: `df -Ph | grep -E '^/dev/root' | awk '{ print $3 }'` $(tput setaf 2)`df -Ph | grep -E '^/dev/root' | awk '{ print $5 }'`$(tput setaf 1)
       '~'
$(tput sgr0)"

