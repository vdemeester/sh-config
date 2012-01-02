# Filename:     .zshenv
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# This file is sourced on all invocations of the shell (for $USER).
# It is the 1st file zsh reads; It is just not read when -f (setopt NO_RCS)
#
# This file contains commands to set the command search path and miscellaneous
# environment variables. It should not contain commands that produce output or
# assume the shell is attached to a tty. Keep it light
#
# Order : .zshenv (-> .shenv), .zprofile, .zshrc, .zlogin
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

# {{{ zdotdir ----------------------------------------------------------------
zdotdir=${ZDOTDIR:-$HOME}
export ZDOTDIR="${zdotdir}"
# }}}

[[ -e $zdotdir/.shenv ]] && . $zdotdir/.shenv

sh_load_status ".zshenv already started before .shenv"
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
