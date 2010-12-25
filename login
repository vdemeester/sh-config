#!/bin/zsh
#
echo "Login..."
SSH_ENV=$HOME/.ssh/environment

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' >! ${SSH_ENV}
     chmod 600 ${SSH_ENV}
     . ${SSH_ENV} > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [[ -f /usr/bin/keychain ]]; then
	eval `keychain --eval id_rsa`
elif [[ -f "${SSH_ENV}" ]]; then
     . ${SSH_ENV} > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi

# Staring Xorg if we are on tty1
if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ]; then
	while true
	do
		startx -- 2>&1 > ~/.xsession.log
		sleep 10
	done
fi 
