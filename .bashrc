# -*- mode: sh; -*-
# bashrc file
CSHELL="bash"
SH="${SHFOLDER:-$HOME}/.sh"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# SSH agent --------------------------------------------------------------- {{{
SSH_ENV=$HOME/.ssh/environment
start_agent () {
    # echo "Initialising new SSH agent..."
    # /usr/bin/ssh-agent | sed 's/^echo/#echo/' >! ${SSH_ENV}
    # chmod 600 ${SSH_ENV}
    #. ${SSH_ENV} > /dev/null
    if test -n "`ps -e|grep ssh-agent`"; then
        echo ""
    else
        eval `ssh-agent`
        /usr/bin/ssh-add;
    fi
}
if test `id -u` != 0; then
    KEYCHAIN="/usr/bin/keychain"
    if test -f /usr/local/bin/keychain; then
        KEYCHAIN="/usr/local/bin/keychain"
    elif test -f /usr/pkg/bin/keychain; then
        KEYCHAIN="/usr/pkg/bin/keychain"
    fi
    # Source SSH settings, if applicable
    if test -x "${KEYCHAIN}"
    then
        eval `${KEYCHAIN} --eval id_rsa --quiet`
    elif test -f "${SSH_ENV}"
    then
        . ${SSH_ENV} > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent > /dev/null || {
            start_agent;
        }
    else
        start_agent;
    fi
fi
# }}}

HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
