# zshrc file
CSHELL="zsh"
SH="${SHFOLDER:-$HOME}/.sh"
# We are sourcing $HOME/.shenv at first and any time bash is launched, even it is
# not in interactive mode.
if test -f ${SH}/env; then
    . ${SH}/env
fi

# Use /bin/sh when no terminal is present (?)
[[ ${TERM:-dumb} != "dumb" ]] || exec /bin/sh
[ -t 1 ] || exec /bin/sh

# Loading rc/ stuff
load_rcfiles

# Customize to your needs...
source ${SH}/zsh/function
source ${SH}/zsh/alias

# vim:syntax=zsh
