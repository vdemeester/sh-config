# -*- mode: sh; -*-
# Filename:     .zlogout
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# Shutdown files are run, when a login shell exits.
#
# Order: .zshenv, .zprofile, .zshrc, .zlogin
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

sh_load_status .zlogout

[[ -e $zdotdir/.shlogout ]] && . $zdotdir/.shlogout

. $ZDOT_RUN_HOOKS .zlogout.d

# make sure screen is empty on exit
clear

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
