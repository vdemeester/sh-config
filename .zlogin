# Filename:     .zlogin
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# This file is sourced only for login shells. It should contain commands that 
# should be executed in login shells. Note the using zprofile and zlogin, you
# are able to run commands for login shells before and after zshrc.
#
# Order: .zshenv, .zprofile, .zshrc, .zlogin
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

sh_load_status .zlogin

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
