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

# Load zshrc.d
. $ZDOT_RUN_HOOKS .sh/hook/zshrc.pre

[[ -e $zdotdir/.shrc ]] && . $zdotdir/.shrc

autoload -U is-at-least
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
# {{{ PROMPT(S) --------------------------------------------------------------
# {{{ precmd -----------------------------------------------------------------
_vde_prompt_precmd () {
    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS}))

    ###
    # Truncate the path if it's too long.
    PR_FILLBAR=""
    PR_PWDLEN=""
    local promptsize=${#${(%):---(%n@%m)---()--}}
    local pwdsize=${#${(%):-%~}}
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi
}
if (( $+functions[add-zsh-hook] )); then
    add-zsh-hook precmd _vde_prompt_precmd
else
    precmd () {
    _vde_prompt_precmd
    }
fi
# }}}
# {{{ colors -----------------------------------------------------------------
###
# See if we can use colors.

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"
# }}}
# {{{ extended characters ----------------------------------------------------
# See if we can use extended characters to look nicer.
__() {
    local -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}
} && __
# }}}
# {{{ set_prompt -------------------------------------------------------------
# This is the real stuff.
_vde_setprompt () {
    setopt prompt_subst
    local return_code

    PROMPT='$PR_SET_CHARSET\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_HBAR$PR_SHIFT_OUT$PR_GREY(\
%(!.$PR_RED%n.${PR_GREEN}${SSH_TTY:+$PR_MAGENTA}%n)$PR_GREY@$PR_LIGHT_GREEN${SSH_TTY:+$PR_MAGENTA}%m\
$PR_GREY)$PR_CYAN$PR_SHIFT_IN$PR_HBA$PR_HBAR${(e)PR_FILLBAR}$PR_HBAR$PR_SHIFT_OUT$PR_GREY(\
$PR_GREEN${SSH_TTY:+$PR_MAGENTA}%$PR_PWDLEN<...<%~%<<\
$PR_GREY)$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR'$(_vde_add_lprompt)'\
 %(!.${PR_RED}#.${PR_LIGHT_GREEN}%%)$PR_NO_COLOUR '

    # display exitcode on the right when >0
    if is-at-least 4.3.4 && [[ -o multibyte ]]; then
        return_code="%(?..%{$PR_RED%}%? ↵ $PR_NO_COLOUR)"
    else
        return_code="%(?..%{$PR_RED%}<%?> $PR_NO_COLOUR)"
    fi
    RPROMPT=' '$return_code''$(_vde_add_rprompt)'$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_LIGHT_CYAN$PR_HBAR$PR_SHIFT_OUT\
$PR_GREY($PR_WHITE%D{%H:%M}$PR_GREY)$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_GREY(\
$PR_LIGHT_GREEN%_$PR_GREY)$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}
# Collect additional information from functions matching _vde_add_prompt_*
_vde_add_lprompt () {
    for f in ${(k)functions}; do
        [[ $f == _vde_add_lprompt_* ]] || continue
        $f
        print -n '${PR_NO_COLOUR}'
    done
}
_vde_add_rprompt () {
    for f in ${(k)functions}; do
        [[ $f == _vde_add_rprompt_* ]] || continue
        $f
        print -n '${PR_NO_COLOUR}'
    done
}
# }}}
# Call setprompt !
_vde_setprompt
# }}}
# Load zshrc.d
. $ZDOT_RUN_HOOKS .sh/hook/zshrc.post

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
