# bashrc file
CSHELL="bash"
# This file is sourced when starting bash.
SH="${SHFOLDER:-$HOME}/.sh"
# We are sourcing $HOME/.shenv at first and any time bash is launched, even it is
# not in interactive mode.
if test -f ${SH}/env; then
    . ${SH}/env
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

load_rcfiles

HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
