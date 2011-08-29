# zshrc file
# vim:foldmethod=marker foldmarker={{{,}}} syntax=zsh
# Common part ----------------------------------------------------------------- {{{
SH="${SHFOLDER:-$HOME}/.sh"
# We are sourcing $HOME/.shenv at first and any time bash is launched, even it is
# not in interactive mode.
if test -f ${SH}/env; then
    . ${SH}/env
fi

# Use /bin/sh when no terminal is present (?)
[[ ${TERM:-dumb} != "dumb" ]] || exec /bin/sh
[ -t 1 ] || exec /bin/sh

# Load exports
if test -f ${SH}/exports; then
    . ${SH}/exports
fi
# }}}

export ZSH=${SH}/zsh/oh-my-zsh

# dircolors
if [[ -d $HOME/.dircolors ]]; then
	if [[ `hostname` = "gohei" || `hostname` = "kyushu" || `hostname` = "vinnsento" ]]; then
		eval `dircolors $HOME/.dircolors/dircolors.256dark`
	else
		eval `dircolors $HOME/.dircolors/dircolors.ansi-dark`
	fi
fi

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
export ZSH_THEME="shortbrain"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-flow debian vi-mode pip haskell)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
source ${SH}/zsh/function
source ${SH}/zsh/alias

# vim:syntax=zsh
