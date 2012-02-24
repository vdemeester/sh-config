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
# {{{ COMPLETIONS ------------------------------------------------------------
autoload -U zutil
autoload -U compinit
autoload -U complist
compinit -i -d $HOME/.local/run/zcompdump-$HOST-$UID

setopt auto_menu
setopt auto_remove_slash
setopt complete_in_word
setopt always_to_end
setopt glob_complete
setopt complete_aliases
unsetopt list_beep

zstyle ':completion:*' completer _complete _prefix _ignored _complete:-extended
# e.g. f-1.j<TAB> would complete to foo-123.jpeg
zstyle ':completion:*:complete-extended:*' \
  matcher 'r:|[.,_-]=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:*' menu select
# {{{ Expand partial paths

# e.g. /u/s/l/D/fs<TAB> would complete to
#      /usr/src/linux/Documentation/fs
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# }}}
# {{{ Include non-hidden dirs in globbed file completions for certain commands

#zstyle ':completion::complete:*' \
#  tag-order 'globbed-files directories' all-files 
#zstyle ':completion::complete:*:tar:directories' file-patterns '*~.*(-/)'

# }}}
# {{{ Don't complete backup files (e.g. 'bin/foo~') as executables

zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# }}}
# {{{ Don't complete uninteresting users

zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs

# ... unless we really want to.
zstyle '*' single-ignored show

# }}}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -eo pid,user,comm -w -w"
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH/run/cache/
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle    ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                                  /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
# this will include newly installed programs into tab completion
_force_rehash() { (( CURRENT == 1 )) && rehash return 1 }
zstyle    ':completion:*' completers _force_rehash

LISTMAX=0       # only ask if completion should be shown if it is larger than our screen
# this will not complete dotfiles in ~, unless you provide at least .<tab>
zstyle -e ':completion:*' ignored-patterns 'if [[ $PWD = ~ ]] && [[ ! $words[-1] == .* ]]; then reply=(.*); fi'
# Don't complete backup files (e.g. 'bin/foo~') as executables
zstyle    ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# In menu, select items with +
zmodload -i zsh/complist
bindkey -M menuselect "+" accept-and-menu-complete
# }}}
# {{{ KEYS -------------------------------------------------------------------
# insert Unicode character
autoload      insert-unicode-char
zle -N        insert-unicode-char
bindkey '^xi' insert-unicode-char
# "ctrl-e D" to insert the actual datetime YYYY/MM
              __insert-datetime-directory() { BUFFER="$BUFFER$(date '+%Y/%m')"; CURSOR=$#BUFFER; }
zle -N        __insert-datetime-directory
bindkey '^eD' __insert-datetime-directory

# "ctrl-e d" to insert the actual datetime YYYY-MM-DD--hh-mm-ss-TZ
              __insert-datetime-default() { BUFFER="$BUFFER$(date '+%F--%H-%M-%S-%Z')"; CURSOR=$#BUFFER; }
zle -N        __insert-datetime-default
bindkey '^ed' __insert-datetime-default
# "ctrl-e w" to delete to prior whitespace
autoload -U   delete-whole-word-match
zle -N        delete-whole-word-match
bindkey "^ew" delete-whole-word-match

# "ctrl-e ." to insert last typed word again
              __insert-last-typed-word() { zle insert-last-word -- 0 -1 };
zle -N        __insert-last-typed-word;
bindkey "^e." __insert-last-typed-word
# "ctrl-e q" to quote line
__quote_line () {
	zle beginning-of-line
	zle forward-word
	RBUFFER=${(q)RBUFFER}
	zle end-of-line
}
zle -N        __quote_line
bindkey '^eq' __quote_line
# "ctrl-e 1" to jump behind the first word on the cmdline
function __jump_behind_first_word() {
	local words
	words=(${(z)BUFFER})

	if (( ${#words} <= 1 )) ; then
		CURSOR=${#BUFFER}
	else
		CURSOR=${#${words[1]}}
	fi
}
zle -N        __jump_behind_first_word
bindkey '^e1' __jump_behind_first_word
# "ctrl-e e" : open iZLE buffer in $EDITOR
autoload      edit-command-line
zle -N        edit-command-line
bindkey '^ee' edit-command-line
bindkey '^e^e' edit-command-line
# }}}
# {{{ ALIAS ------------------------------------------------------------------
# Sweet trick from zshwiki.org :-)
cd () {
  if (( $# != 1 )); then
    builtin cd "$@"
    return
  fi

  if [[ -f "$1" ]]; then
    builtin cd "$1:h"
  else
    builtin cd "$1"
  fi
}

z () {
  cd ~/"$1"
}
# {{{ Renaming

autoload zmv
alias mmv='noglob zmv -W'

# }}}
# {{{ MIME handling

autoload zsh-mime-setup
zsh-mime-setup

# }}}
# {{{ Paging with less / head / tail

alias -g L='| less'
alias -g LS='| less -S'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g TRIM='| trim-lines'

alias -g H='| head'
alias -g HL='| head -n $(( +LINES ? LINES - 4 : 20 ))'
alias -g EH='|& head'
alias -g EHL='|& head -n $(( +LINES ? LINES - 4 : 20 ))'

alias -g T='| tail'
alias -g TL='| tail -n $(( +LINES ? LINES - 4 : 20 ))'
alias -g ET='|& tail'
alias -g ETL='|& tail -n $(( +LINES ? LINES - 4 : 20 ))'

# }}}
alias -g V='| vim -'
alias -g X='| xargs'
# {{{ Sorting / counting

alias -g C='| wc -l'

alias -g S='| sort'
alias -g Su='| sort -u'
alias -g Sn='| sort -n'
alias -g Snr='| sort -nr'
alias -g SUc='| sort | uniq -c'
alias -g SUd='| sort | uniq -d'
alias -g Uc='| uniq -c'
alias -g Ud='| uniq -d'

# }}}
# {{{ awk

alias -g A='| awk '
alias -g A1="| awk '{print \$1}'"
alias -g A2="| awk '{print \$2}'"
alias -g A3="| awk '{print \$3}'"
alias -g A4="| awk '{print \$4}'"
alias -g A5="| awk '{print \$5}'"
alias -g A6="| awk '{print \$6}'"
alias -g A7="| awk '{print \$7}'"
alias -g A8="| awk '{print \$8}'"
alias -g A9="| awk '{print \$9}'"
alias -g EA='|& awk '
alias -g EA1="|& awk '{print \$1}'"
alias -g EA2="|& awk '{print \$2}'"
alias -g EA3="|& awk '{print \$3}'"
alias -g EA4="|& awk '{print \$4}'"
alias -g EA5="|& awk '{print \$5}'"
alias -g EA6="|& awk '{print \$6}'"
alias -g EA7="|& awk '{print \$7}'"
alias -g EA8="|& awk '{print \$8}'"
alias -g EA9="|& awk '{print \$9}'"

# }}}
# }}}
# {{{ HASHES -----------------------------------------------------------------
hash -d deb=/var/cache/apt/archives
hash -d doc=/usr/share/doc
hash -d grub=/boot/grub
hash -d log=/var/log
hash -d www=/var/www
hash -d sh=$HOME/.sh
hash -d mr=$XDG_CONFIG_HOME/mr
hash -d repo.d=$XDG_CONFIG_HOME/vcsh/repo.d
hash -d work.d=$HOME/documents/work
hash -d work.s=$HOME/src/work
# }}}
# {{{ PROFILES ---------------------------------------------------------------
# Setting a default profile for 'any other folder'
# directory based profiles
# {{{ function ---------------------------------------------------------------
if is-at-least 4.3.3 ; then

CHPWD_PROFILE='default'
function chpwd_profiles() {
    # Say you want certain settings to be active in certain directories.
    # This is what you want.
    #
    # zstyle ':chpwd:profiles:/usr/src/grml(|/|/*)'   profile grml
    # zstyle ':chpwd:profiles:/usr/src/debian(|/|/*)' profile debian
    #
    # When that's done and you enter a directory that matches the pattern
    # in the third part of the context, a function called chpwd_profile_grml,
    # for example, is called (if it exists).
    #
    # If no pattern matches (read: no profile is detected) the profile is
    # set to 'default', which means chpwd_profile_default is attempted to
    # be called.
    #
    # A word about the context (the ':chpwd:profiles:*' stuff in the zstyle
    # command) which is used: The third part in the context is matched against
    # ${PWD}. That's why using a pattern such as /foo/bar(|/|/*) makes sense.
    # Because that way the profile is detected for all these values of ${PWD}:
    #   /foo/bar
    #   /foo/bar/
    #   /foo/bar/baz
    # So, if you want to make double damn sure a profile works in /foo/bar
    # and everywhere deeper in that tree, just use (|/|/*) and be happy.
    #
    # The name of the detected profile will be available in a variable called
    # 'profile' in your functions. You don't need to do anything, it'll just
    # be there.
    #
    # Then there is the parameter $CHPWD_PROFILE is set to the profile, that
    # was is currently active. That way you can avoid running code for a
    # profile that is already active, by running code such as the following
    # at the start of your function:
    #
    # function chpwd_profile_grml() {
    #     [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1
    #   ...
    # }
    #
    # The initial value for $CHPWD_PROFILE is 'default'.
    #
    # Version requirement:
    #   This feature requires zsh 4.3.3 or newer.
    #   If you use this feature and need to know whether it is active in your
    #   current shell, there are several ways to do that. Here are two simple
    #   ways:
    #
    #   a) If knowing if the profiles feature is active when zsh starts is
    #      good enough for you, you can put the following snippet into your
    #      .zshrc.local:
    #
    #   (( ${+functions[chpwd_profiles]} )) && print "directory profiles active"
    #
    #   b) If that is not good enough, and you would prefer to be notified
    #      whenever a profile changes, you can solve that by making sure you
    #      start *every* profile function you create like this:
    #
    #   function chpwd_profile_myprofilename() {
    #       [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1
    #       print "chpwd(): Switching to profile: $profile"
    #     ...
    #   }
    #
    #      That makes sure you only get notified if a profile is *changed*,
    #      not everytime you change directory, which would probably piss
    #      you off fairly quickly. :-)
    #
    # There you go. Now have fun with that.
    local -x profile

    zstyle -s ":chpwd:profiles:${PWD}" profile profile || profile='default'
    if (( ${+functions[chpwd_profile_$profile]} )) ; then
        chpwd_profile_${profile}
    fi

    CHPWD_PROFILE="${profile}"
    return 0
}
chpwd_functions=( ${chpwd_functions} chpwd_profiles )

fi # is433
# }}}
# Default profile
# Doesn't do so much…
chpwd_profile_default() {
    [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1

    echo "<<< Back to default profile"
    # Remove some environment variables possibly set
    unset GIT_AUTHOR_EMAIL
    unset GIT_COMMITTER_EMAIL
    unset DEBMAIL
}
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
