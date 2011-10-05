#!/bin/sh
# vim:foldmethod=marker foldmarker={{{,}}} syntax=sh
# PATH ------------------------------------------------------------------------ {{{
# Working with PATH.
# FIXME: Detect if already present in path !
build_path() {
# OSX Hack - starting with the worst
local NEW_PATH=$PATH
if test $(uname) = "Darwin"; then
    NEW_PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/opt/X11/bin:/usr/local/MacGPG2/bin:/usr/texbin:/usr/X11/bin
fi
# Test if LOCAL_CABAL_DISABLE is set or not. If set, no $HOME/.cabal/bin in PATH
if ! test -z "${LOCAL_CABAL_DISABLE}"; then
    if test -d $HOME/.cabal/bin; then
        NEW_PATH=$HOME/.cabal/bin:$NEW_PATH
    fi
fi
# pkgsrc (macosx & co) -> /usr/pkg
if test -d /usr/pkg/bin; then
    NEW_PATH=/usr/pkg/bin:$NEW_PATH
fi
if test -d /usr/pkg/sbin; then
    NEW_PATH=/usr/pkg/sbin:$NEW_PATH
fi
# $HOME/.local/bin have to be *first* in the PATH
if test -d $HOME/.local/bin; then
    NEW_PATH=$HOME/.local/bin:$NEW_PATH
fi
export PATH=$NEW_PATH
}
build_path
# }}}
# TERM ------------------------------------------------------------------------ {{{
# Gnome terminal support 256 if terminfo of xterm-256color is set as TERM
if test "${COLORTERM}" = "gnome-terminal"; then
    if test -e /usr/share/terminfo/x/xterm-256color || test -e /lib/terminfo/x/xterm-256color; then
        export TERM="xterm-256color"
    else
        export TERM='xterm-color'
    fi
elif test "${COLORTERM}" = "rxvt-xpm"; then
    # Forcing 256 to screen if inside a term with rxvt (urvxt is one of them)
    if test "${TERM}" = "screen"; then
        if test -e /usr/share/terminfo/s/screen-256color; then
            export TERM="screen-256color"
        fi
    fi
elif test "${TERM}" = "xterm"; then
    if test -e /usr/share/terminfo/x/xterm-256color || test -e /lib/terminfo/x/xterm-256color; then
        export TERM="xterm-256color"
    fi
fi
# OSX Hack
# Forcing 256color (works with iTerm tha set TERM as xterm
if test $(uname) = 'Darwin'; then
    if test "${TERM}" = "xterm"; then
        export TERM="xterm-256color"
    fi
fi
# }}}
# PAGER ----------------------------------------------------------------------- {{{
command -v most >/dev/null && {
    MOST=$(which most)
    # export PAGER="${MOST}"
    export MANPAGER="${MOST} -s"
    unset MOST
}
# }}}
# Miscellaneous --------------------------------------------------------------- {{{
export TASKS_FOLDER=$HOME/src/git/tasks
# }}}
