# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# From man sh :
# > If the environment variable ENV is set on entry to an interactive shell, or is
# > set in the .profile of a login shell, the shell next reads commands from the
# > file named in ENV.
ENV=$HOME/.shenv; export ENV

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# init me !
if [ ! -d $HOME/.local/logs ]; then
    mkdir -p $HOME/.local/logs
fi

# Staring Xorg if we are on tty1
if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ]; then
	while true
	do
		startx > $HOME/.local/logs/.xsession.log 2>&1
		sleep 10
	done
fi 


