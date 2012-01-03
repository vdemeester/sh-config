# Filename:     .zshrc
# Authors:      Vincent Demeester
# License:      This file is licensed under the GPL v2.
# --------------------------------------------------------------------------- #
# This file is sourced only for interactive shells.
#
# This file is the center of the zsh configuration. It should contains aliases,
# keybinding, functions, options, …
# But, this will be modularized a bit, so this file will be very light. Its
# only work is to load stuff from ZDOTDIR.
#
# Order: .zshenv, .zprofile, .zshrc, .zlogin
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

sh_load_status .zshrc

[[ -e $zdotdir/.shrc ]] && . $zdotdir/.shrc

# Load zshrc.d
. $ZDOT_RUN_HOOKS .zshrc.d

# {{{ Clear up after status display ------------------------------------------
# We clean if in interactive mode, else, there is zlogin that comes after.
if test -n "$shell_interactive"; then
    if [[ $TERM == tgtelnet ]]; then
      echo
    else
      echo -n "\r"
    fi
fi
# }}}

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
