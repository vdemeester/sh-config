# zshrc file
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
for rcfile in ${SH}/rc/*.{sh,zsh}
do
    . ${rcfile}
done


# dircolors
if [[ -d $HOME/.dircolors ]]; then
	if [[ `hostname` = "gohei" || `hostname` = "kyushu" || `hostname` = "vinnsento" ]]; then
		eval `dircolors $HOME/.dircolors/dircolors.256dark`
	else
		eval `dircolors $HOME/.dircolors/dircolors.ansi-dark`
	fi
fi

# Customize to your needs...
source ${SH}/zsh/function
source ${SH}/zsh/alias

# vim:syntax=zsh
