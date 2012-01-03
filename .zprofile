# Filename:     .zprofile
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# This file is sourced only for login shells (i.e. shells invoked with "-" or
# -l flag. It's read after .zshenv
#
# Order: .zshenv, .zprofile, .zshrc, .zlogin
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

sh_load_status .zprofile

. $ZDOT_RUN_HOOKS .sh/hook/zprofile.pre

[[ -e $zdotdir/.profile ]] && . $zdotdir/.profile

. $ZDOT_RUN_HOOKS .sh/hook/zprofile.post


# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
