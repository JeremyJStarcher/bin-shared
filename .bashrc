# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm|xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    if [[ ${EUID} == 0 ]] ; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h \w \$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Detect the platform.
case "$OSTYPE" in

  solaris*)
    ;;

  darwin*) # Mac (OSX)

    # Set LC encoding to UTF-8.
    #export LC_ALL=en_GB.UTF-8

    # Fixes for illegal byte sequence (http://stackoverflow.com/q/19242275/55075).
    export LC_ALL=C
    export LANG=C

    # For MAMP (OSX)
    PHP_VER="5.6.20" # Or: 5.4.19/5.5.3 ($ls /Applications/MAMP/bin/php/php*)

    # Mule ESB configuration.
    export MULE_HOME=/usr/local/opt/mule
    [ -d "$MULE_HOME" ] && export PATH=$PATH:$MULE_HOME/bin

    # Set PATH for OSX
    export PATH="$HOME/bin:$HOME/binfiles:/usr/local/sbin:/usr/local/bin:$PATH"
    type brew > /dev/null && brew --prefix homebrew/php/php56 > /dev/null && export PATH="$(brew --prefix homebrew/php/php56)/bin:$PATH"
    export PATH="$PATH:/Applications/MAMP/Library/bin:/Applications/MAMP/bin/php/php$PHP_VER/bin:/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin/gcc"
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" # add a "gnubin" for coreutils
    export PYTHONPATH="$PYTHONPATH:$HOME/.python" # /usr/local/lib/python3.4/site-packages"
    # :/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang

    # Development variables.
    export FLEX_HOME="/usr/local/Cellar/flex_sdk/4.6.0.23201/libexec"
    export DYLD_FALLBACK_LIBRARY_PATH="/usr/X11/lib:/usr/lib" # See: http://stackoverflow.com/questions/10820981/dylibs-and-os-x
    #export PHP_AUTOCONF="$(which autoconf)" # Install autoconf, which is needed for the installation of phpMyAdmin.

    # Fix for Git-SVN (OSX) [Error: Can't locate SVN/Core.pm in @INC]. See: http://stackoverflow.com/questions/13571944/git-svn-unrecognized-url-scheme-error
    export PERL5LIB="$HOME/perl5/lib/perl5:/Applications/Xcode.app/Contents/Developer/Library/Perl/5.16"

    # OSX specific aliases.
    alias diffmerge="/Applications/DiffMerge.app/Contents/MacOS/DiffMerge"
    alias xt-files="egrep -o '/[^/]+:[0-9]+'"
    alias iphone="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app/Contents/MacOS/iPhone Simulator" # OSX Lion

    # Set prompt
    export GIT_PS="\[$txtcyn\]\$git_branch\[$txtred\]\$git_dirty\[$txtrst\] "
    export PS1="\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\W \[\033[01;35m\]\$ $GIT_PS\[\033[00m\]"

    # Set other options.
    export LS_OPTIONS='-G -h'

    # OSX: Enable bash_completion (Install by: brew install bash-completion)
    #       Homebrew's own bash completion script: /usr/local/etc/bash_completion.d
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi

    ;;

  linux-gnu*) # Debian

    # Debian specific
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
      debian_chroot=$(cat /etc/debian_chroot)
    fi


    if [ "$color_prompt" = yes ]; then
      PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
      PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
      PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
      ;;
    *)
      ;;
    esac

    ;;& # fall-through syntax requires bash >= 4; (OSX, check: http://apple.stackexchange.com/q/141752/22781)

  linux*)
    # Set LC encoding to UTF-8.
    # Ubuntu way: Use locale-gen (part of locales).
    export LANG=en_US.UTF-8
    export LANGUAGE="en_US:en"

    # Set PATH for Linux
    export PATH=/usr/local/bin:$PATH:/opt/local/bin

    # Linux: enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    fi

    # Linux: Enable bash_completion (Install by: brew install bash-completion)
    # enable programmable completion features (you don't need to enable
    # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
    # sources /etc/bash.bashrc).
    # Install by: sudo apt-get install bash-completion
    if ! shopt -oq posix; then
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
    fi

    # Linux aliases
    # Add an "alert" alias for long running commands. Use like so: sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

    # Set other options.
    export LS_OPTIONS='--color=auto -h'

    ;;

  bsd*)
    export LS_OPTIONS='-G'
    ;;

  *)
    echo "Unknown: $OSTYPE"
    ;;
esac

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -x /usr/bin/mint-fortune ]; then
     /usr/bin/mint-fortune
fi

unset color_prompt force_color_prompt

# Add OS-specific directories.
export PATH=${PATH}:${HOME}/bin-shared/$(uname)

#netinfo - shows network information for your system
netinfo () {
  echo "--------------- Network Information ---------------"
  /sbin/ifconfig | awk /'inet addr/ {print $2}'
  /sbin/ifconfig | awk /'Bcast/ {print $3}'
  /sbin/ifconfig | awk /'inet addr/ {print $4}'
  /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'

  # myip="External IP not available because lynx is not installed"
  # which lynx &&  myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
  # echo "${myip}"

  curl ipinfo.io

  echo "---------------------------------------------------"
}


# Extract various compression formats
extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1;;
             *.tar.gz)    tar xzf $1;;
             *.bz2)       bunzip2 $1;;
             *.rar)       rar x $1;;
             *.gz)        gunzip $1;;
             *.tar)       tar xf $1;;
             *.tbz2)      tar xjf $1;;
             *.tgz)       tar xzf $1;;
             *.zip)       unzip $1;;
             *.Z)         uncompress $1;;
             *.7z)        7z x $1;;
             *)           echo "'$1' cannot be extracted via extract()";;
         esac
     else
         echo "'$1' is not a valid file"
     fi
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
sys(){
  if [ `id -u` -ne 0 ]; then echo "you are not root"&&exit;fi;
  uname -a
  echo "runlevel" `runlevel`
  uptime
  last|head -n 5;
  who;
  echo "============= CPUs ============="
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


# GIT_PROMPT_START="_LAST_COMMAND_INDICATOR_ ${Yellow}${PathShort}${ResetColor}"
# if ! [ $(id -u) = 0 ]; then
#   GIT_PROMPT_END=" \n${Red}[${USER}@${HOSTNAME%%.*}]${ResetColor} ${Time12a} # "
# else
#   GIT_PROMPT_END=" \n${White}[${USER}@${HOSTNAME%%.*}] ${Time12a}${ResetColor} $ "
# fi


GIT_PROMPT_THEME=JeremyStarcher
GIT_PROMPT_ONLY_IN_REPO=1
source ~/bin-shared/bin/bash-git-prompt/gitprompt.sh


export VISUAL=vim
export EDITOR="$VISUAL"
