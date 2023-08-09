#netinfo - shows network information for your system
netinfo () {
  horizontal-rule Network Information
  /sbin/ifconfig | awk /'inet addr/ {print $2}'
  /sbin/ifconfig | awk /'Bcast/ {print $3}'
  /sbin/ifconfig | awk /'inet addr/ {print $4}'
  /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'

  # myip="External IP not available because lynx is not installed"
  # which lynx &&  myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
  # echo "${myip}"

  curl ipinfo.io
  curl ifconfig.co/json
  curl echoip.xyz



  printf "IPv6 is "
  [ $(cat /proc/sys/net/ipv6/conf/all/disable_ipv6) -eq 0 ] \
    && printf "enabled\n" || printf "disabled\n"

  horizontal-rule 
}



# Extracts files of various formats to a directory with the same name as the file (without the extension).
# Usage: extract4 file
extract() {
  # Validate input
  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file" >&2
    return 1
  fi

  # Extract file to a directory with the same name as the file (without the extension)
  dir_name=$(basename "$1" | sed 's/\.[^.]*$//')
  mkdir -p "$dir_name"

  # Determine file type and extract accordingly
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    *.tar.bz2 | *.tbz2) tar xjf "$1" -C "$dir_name" ;;
    *.tar.gz | *.tgz) tar xzf "$1" -C "$dir_name" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) rar x "$1" "$dir_name" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" -C "$dir_name" ;;
    *.zip) unzip "$1" -d "$dir_name" ;;
    *.z) uncompress "$1" ;;
    *.7z) 7z x "$1" -o"$dir_name" ;;
    *) echo "Error: '$1' cannot be extracted via extract()" >&2 ;;
  esac
}


# Runs alias before running sudo, somehow preserving all your alias bindings in
# the sudo command. So if I did sudo tf /var/log/file, it would still work even
# though root doesn't have my alias file.
# alias sudo='A=`alias` sudo '

# Preserves my env variables when I switch user. Useful because it includes my
# prompt, which flashes red when I'm root. Sometimes I don't want it so I fall
# back to /bin/su to ignore the alias.
# alias su='su -m'

# Use like `lw ls`
function lw() {
  if [ $# -gt 0 ] ; then
    for bin in $@ ; do ls -lh `which $bin` ; done
  else
    echo "lw (ls which) requires more than 0 arguments"
  fi
}

uinf() {
  echo "current directory="`pwd`;
  echo "you are="`whoami`
  echo "groups in="`id -n -G`;
  # tree -L 1 -h $HOME;
  echo "terminal="`tty`;

  echo -n "Boot mode: "
  [[ -d "/sys/firmware/efi" ]] && echo "UEFI" || echo "BIOS"
}

#top10 largest in directory
t10(){
  pwd&&du -ab $1|sort -n -r|head -n 10
}

#top10 apparent size
t10a(){
  pwd&&du -ab --apparent-size $1|sort -n -r|head -n 10
}

#system roundup
system-roundup(){
  if [ `id -u` -ne 0 ]; then echo "you are not root"&&exit;fi;
  uname -a
  echo "runlevel" `runlevel`
  uptime
  last|head -n 5;
  who;

  horizontal-rule CPUs
  
  grep "model name" /proc/cpuinfo #show CPU(s) info
  cat /proc/cpuinfo | grep 'cpu MHz'
  echo ">>>>>current process"
  pstree
  echo "============= MEM ============="
  #KiB=`grep MemTotal /proc/meminfo | tr -s ' ' | cut -d' ' -f2`
  #MiB=`expr $KiB / 1024`
  #note various mem not accounted for, so round to appropriate sizeround=32
  #echo "`expr \( \( $MiB / $round \) + 1 \) \* $round` MiB"
  # free -otm;
  echo "============ NETWORK ============"
  ip link show
  /sbin/ifconfig | awk /'inet addr/ {print $2}'
  /sbin/ifconfig | awk /'Bcast/ {print $3}'
  /sbin/ifconfig | awk /'inet addr/ {print $4}'
  /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
  echo "============= DISKS =============";
  df -h;
  echo "============= MISC =============="
  echo "==<kernel modules>=="
  lsmod|column -t|awk '{print $1}';
  echo "=======<pci>========"
  lspci -tv;
  echo "=======<usb>======="
  lsusb;
}

miso() {
  _mountpoint="/tmp/iso"
  if [ "$EUID" -ne 0 ]; then
    sudo miso "$@"  # Call itself again with sudo
    return
  fi

  if [ -z "$1" ]; then
    echo "usage:"
    echo "  miso file.iso to   mount FILE.iso at   '$_mountpoint'"
    echo "  miso -u       to unmount FILE.iso from '$_mountpoint'"
    echo "  Where FILE.iso is the name, or path and name, of the iso file to mount"
  elif [ "$1" = "-u" ]; then
    umount "$_mountpoint"
    echo "'$_mountpoint' unmounted."
  elif [ -r "$1" ] && [ ! -z "`echo "$1" | grep -i .iso$`" ]; then
    if [ `ls "$_mountpoint" | wc -w` -ne 0 ]; then
      echo -e "error: '$_mountpoint' is not empty, \ntry miso -u to unmount it"
    else
      mount -o loop "$1" "$_mountpoint"
      echo -e "'$1'\n  is mounted at\n'$_mountpoint'"
    fi
  else
    echo "error: '$1' is not a readable *.iso file."
  fi
}


miso2() {
  _mountpoint="/tmp/iso"
  if [ -z "$1" ]; then
    echo "usage:"
    echo "  miso file.iso to   mount FILE.iso at   '$_mountpoint'"
    echo "  miso -u       to unmount FILE.iso from '$_mountpoint'"
    echo "  Where FILE.iso is the name, or path and name, of the iso file to mount"
  elif [ "$1" = "-u" ]; then
    sudo umount "$_mountpoint"
    echo "'$_mountpoint' unmounted."
    # if you don't want to verify if the file name ends in a .iso
    # (case insensitive, -i) remove
    # && [ ! -z "`echo "$1" | grep -i .iso$`" ]
  elif [ -r "$1" ] && [ ! -z "`echo "$1" | grep -i .iso$`" ]; then
    if [ `ls "$_mountpoint" | wc -w` -ne 0 ]; then
      echo -e "error: '$_mountpoint' is not empty, \ntry miso -u to unmount it"
    else
      sudo mount -o loop "$1" "$_mountpoint"
      echo -e "'$1'\n  is mounted at\n'$_mountpoint'"
    fi
  else
    echo "error: '$1' is not a readable *.iso file."
  fi
}

function apt-history(){
      case "$1" in
        install)
              cat /var/log/dpkg.log | grep 'install '
              ;;
        upgrade|remove)
              cat /var/log/dpkg.log | grep $1
              ;;
        rollback)
              cat /var/log/dpkg.log | grep upgrade | \
                  grep "$2" -A10000000 | \
                  grep "$3" -B10000000 | \
                  awk '{print $4"="$5}'
              ;;
        *)
              cat /var/log/dpkg.log
              ;;
      esac
}

# Counts files, subdirectories and directory size and displays details
# about files depending on the available space
function lls () {
    # count files
    echo -n "<`find . -maxdepth 1 -mindepth 1 -type f | wc -l | tr -d '[:space:]'` files>"
    # count sub-directories
    echo -n " <`find . -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d '[:space:]'` dirs/>"
    # count links
    echo -n " <`find . -maxdepth 1 -mindepth 1 -type l | wc -l | tr -d '[:space:]'` links@>"
    # total disk space used by this directory and all subdirectories
    echo " <~`du -sh . 2> /dev/null | cut -f1`>"
    ROWS=`stty size | cut -d' ' -f1`
    FILES=`find . -maxdepth 1 -mindepth 1 |
    wc -l | tr -d '[:space:]'`
    # if the terminal has enough lines, do a long listing
    if [ `expr "${ROWS}" - 6` -lt "${FILES}" ]; then
        ls
    else
        ls -hlAF --full-time
    fi
}

function fstr()
{
    OPTIND=1
    local case=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | \
sed "s/$1/${SMSO}\0${RMSO}/gI" | more
}


# Usage: repeat PERIOD COMMAND
function repeat() {

  if [ -z "$1" ]; then
    echo "usage:"
    echo "  repeat <count> <command>"
    return
  fi

  local period
  period=$1; shift;
  while (true); do
    eval "$@";
  sleep $period;
  done
}

function ds()
{
    echo "size of directories in MB"
    if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "you did not specify a directy, using pwd"
        DIR=$(pwd)
        find $DIR -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    else
        find $1 -maxdepth 1 -type d -exec du -sm \{\} \; | sort -nr
    fi
}

# show the 10 largest files sorted and in human readable format
# duf *
function duf {
du -sk "$@" | sort -n | while read size fname;
	do for unit in k M G T P E Z Y;
		do if [ $size -lt 1024 ];
		then echo -e "${size}${unit}\t${fname}";
			break; fi; size=$((size/1024));
		done;
	done | tail -n 10 | tac
}

# Get media metadata easily
######   $1 = media file name
function mediainfo() {
    EXT=`echo "${1##*.}" | sed 's/\(.*\)/\L\1/'`
    if [ "$EXT" == "mp3" ]; then
        id3v2 -l "$1"
        echo
        mp3gain -s c "$1"
    elif [ "$EXT" == "flac" ]; then
        metaflac --list --block-type=STREAMINFO,VORBIS_COMMENT "$1"
    else
        echo "ERROR: Not a supported file type."
    fi
}

alias aptup='sudo apt update && sudo apt upgrade'

watch-mem() {
	watch -n 5 -d '/bin/free -m'
}

up() {
  local d=""
  local limit="$1"

  # default to a limit of 1
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi
  for ((i=1;i<=limit;i++)); do
    d="../$d"
  done
  
  # perform CD. Show error if it fails.
  if ! cd "$d"; then
    echo "Couldn't go up $limit dirs.";
  fi
}

alias bulkrename="find . -name '*jpg' -exec bash -c 'echo mv $0 ${0/IMG/VACATION}' {} \; "


alias rmlint="rmlint"

tv-snow() {
	while true
	do printf "$(awk -v c="$(tput cols)" -v s="$RANDOM" 'BEGIN{srand(s);while(--c>=0){printf("\xe2\x96\\%s",sprintf("%o",150+int(10*rand())));}}')"
	done
}

horizontal-rule() {
  # Fit the width of the screen
    WORDS=$@; 
    termwidth="$(tput cols)";
    padding="$(printf '%0.1s' ={1..500})"
    printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#WORDS})/2))" "$padding" "$WORDS" 0 "$(((termwidth-1-${#WORDS})/2))" "$padding"
}

blink-keyboard() {
	for a in $(seq 16); do 
		xdotool key Num_Lock
		sleep .5
		xdotool key Caps_Lock
	done
}

flash-alert() {
	while true; do 
		echo -e "\e[?5h\e[38;5;1m A L E R T $(date)"
		sleep 0.1
		printf \\e[?5l
		read -s -n1 -t1 && printf \\e[?5l && break
	 done
}

wifi-scan() {
	nmcli device wifi list
}

brickwall() {
	tput setaf 1 && tput rev && seq -ws "___|" 81|fold -69|tr "0-9" "_" && tput sgr0 # (brick wall)
}

friday-the-13th() {
  for i in {2018..2025}-{01..12}-13; do 
    [[ $(date --date $i "+%u") == 5 ]] && echo "$i Friday the 13th" 
  done
}

terminal-clock() {

while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-11));echo -e "\e[31m`date +%T`\e[39m";tput rc;done &

}

stopwatch() {
stf=$(date +%s.%N);for ((;;));do ctf=$( date +%s.%N );echo -en "\r$(date -u -d "0 $ctf sec - $stf sec" "+%H:%M:%S.%N")";done
}

find_git_root() {
    local cur_dir="$PWD"

    while [[ "$cur_dir" != "/" ]]; do
        if [[ -d "$cur_dir/.git" ]]; then
            cd "$cur_dir" || return 1
            return 0
        fi
        cur_dir=$(dirname "$cur_dir")
    done

    echo "No .git directory found in hierarchy"
    return 1
}

alias goto_git_root=find_git_root


