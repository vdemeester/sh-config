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

# {{{ HOOKS ------------------------------------------------------------------
# Simulate hooks using _functions arrays for Zsh versions older than 4.3.4. At
# the moment only precmd(), preexec() and chpwd() are simulated.
#
# At least 4.3.4 (not sure about later versions) has an error in add-zsh-hook
# so the compatibility version is used there too.
if [[ $ZSH_VERSION != (4.3.<5->|4.<4->*|<5->*) ]]; then
    # Provide add-zsh-hook which was added in 4.3.4.
    fpath=(~/.sh/functions/compatibility $fpath)

    # Run all functions defined in the ${precmd,preexec,chpwd}_functions
    # arrays.
    function precmd() {
        for function in $precmd_functions; do
            $function $@
        done
    }
    function preexec() {
        for function in $preexec_functions; do
            $function $@
        done
    }
    function chpwd() {
        for function in $chpwd_functions; do
            $function $@
        done
    }
fi
# Autoload add-zsh-hook to add/remove zsh hook functions easily.
autoload -Uz add-zsh-hook
# }}}

# Load zshrc.d
. $ZDOT_RUN_HOOKS .zshrc.d

# {{{ Clear up after status display ------------------------------------------
# We clean if in login mode, else, there is zlogin that comes after.
if test -z "$shell_login"; then
    if [[ $TERM == tgtelnet ]]; then
      echo
    else
      echo -n "\r"
    fi
fi
# }}}

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
