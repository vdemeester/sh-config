# Filename:     .profile
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# This file is sourced only for login shells (i.e. shells invoked with "-" or
# -l flag. It's the posix-compliant file (called from zprofile or bash_profile)

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# --------------------------------------------------------------------------- #

# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0
test -n "$profile_loaded" && return 0

sh_load_status .profile

. $ZDOT_RUN_HOOKS .sh/hook/shprofile.pre

# init me !
# FIXME This should go elsewhere (in hooks probably)
if [ ! -d $HOME/.local/log ]; then
    mkdir -p $HOME/.local/log
fi
if [ ! -d $HOME/.local/tmp ]; then
    mkdir -p $HOME/.local/tmp
fi

. $ZDOT_RUN_HOOKS .sh/hook/shprofile.post

profile_loaded=y
# vim:filetype=sh foldmethod=marker autoindent expandtab shiftwidth=4
