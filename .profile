# -*- mode: sh; -*-
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

#sh_load_status .profile

. $ZDOT_RUN_HOOKS .sh/hook/shprofile.pre

# Nothing to do ?
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi # added by Nix installer


. $ZDOT_RUN_HOOKS .sh/hook/shprofile.post

profile_loaded=y
# vim:filetype=sh foldmethod=marker autoindent expandtab shiftwidth=4
