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


GIT_PROMPT_THEME=Default
GIT_PROMPT_ONLY_IN_REPO=1
source ~/bin-shared/bin/bash-git-prompt/gitprompt.sh
