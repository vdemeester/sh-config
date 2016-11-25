# -*- mode: sh; -*-
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
# Order interactive login           : .zshenv (.shenv), .zprofile (.shprofile),
#                                     .zshrc (.shrc), .zlogin (.shlogin)
# Order interactive non-login       : .zshenv (.shenv), .zshrc (.shrc)
# Order non-interactive login       : .zshenv (.shenv), .zprofile (.shprofile),
#                                     .zlogin (.shlogin)
# Order non-interactive non-login   : .zshenv (.shenv)
# --------------------------------------------------------------------------- #
# Allow disabling of entire environment suite
test -n "$INHERIT_ENV" && return 0

# {{{ zdotdir ----------------------------------------------------------------
zdotdir=${ZDOTDIR:-$HOME}
export ZDOTDIR="${zdotdir}"
# }}}

[[ -e $zdotdir/.shenv ]] && . $zdotdir/.shenv

sh_load_status ".zshenv already started before .shenv"

# Load shared_env hooks (if present)
. $ZDOT_RUN_HOOKS .sh/hook/zshenv.pre

# Enable extended_glob for zsh "everywhere"
setopt extended_glob

# {{{ fpath/autoloads --------------------------------------------------------

sh_load_status "fpath/autoloads"

fpath=(
        $zdotdir/.sh/functions{,.local,.$HOST}(N)
        $zdotdir/.sh/completions(N)
        $fpath
        # very old versions
        # /usr/doc/zsh*/[F]unctions(N)
      )
# Autoload shell functions from all directories in $fpath.  Restrict
# functions from $zdotdir/.zsh to ones that have the executable bit
# on.  (The executable bit is not necessary, but gives you an easy way
# to stop the autoloading of a particular shell function).
#
# The ':t' is a history modifier to produce the tail of the file only,
# i.e. dropping the directory path.  The 'x' glob qualifier means
# executable by the owner (which might not be the same as the current
# user).

for dirname in $fpath; do
  case "$dirname" in
    $zdotdir/.[z]sh*) fns=( $dirname/*~*~(-N.x:t) ) ;;
                   *) fns=( $dirname/*~*~(-N.:t)  ) ;;
  esac
  (( $#fns )) && autoload "$fns[@]"
done

# }}}


# {{{ PATH / … ---------------------------------------------------------------
# Prevent duplicates in path variables
typeset -U path
typeset -U manpath
export MANPATH
# }}}
# Load shared_env hooks (if present)
. $ZDOT_RUN_HOOKS .sh/hook/zshenv.post

# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
