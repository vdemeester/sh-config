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
if [[ $1 == eval ]]; then
  shift
  ICMD="$@"
  set --
  zle-line-init() {
    BUFFER="$ICMD"
    zle accept-line
    zle -D zle-line-init
  }
  zle -N zle-line-init
fi
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
    eval BG_PR_$color='%{$terminfo[bold]$bg[${(L)color}]%}'
    eval BG_PR_LIGHT_$color='%{$bg[${(L)color}]%}'
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"
# }}}
# {{{ extended characters ----------------------------------------------------
# See if we can use extended characters to look nicer.
#__() {
#    local -A altchar
#    set -A altchar ${(s..)terminfo[acsc]}
#    PR_SET_CHARSET="%{$terminfo[enacs]%}"
#    PR_SHIFT_IN="%{$terminfo[smacs]%}"
#    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
#    PR_HBAR=${altchar[q]:--}
#    PR_ULCORNER=${altchar[l]:--}
#    PR_LLCORNER=${altchar[m]:--}
#    PR_LRCORNER=${altchar[j]:--}
#    PR_URCORNER=${altchar[k]:--}
#} && __
# }}}
# {{{ set_prompt -------------------------------------------------------------
# This is the real stuff.
_vde_setprompt () {
    setopt prompt_subst
    local return_code

#    PROMPT='%(!.$PR_RED%n.$PR_LIGHT_YELLOW${SSH_TTY:+$PR_MAGENTA})$PR_LIGHT_GREEN${SSH_TTY:+$PR_MAGENTA}%m\
#$PR_GREY $PR_GREEN${SSH_TTY:+$PR_MAGENTA}%$PR_PWDLEN<...<%~%<< $PR_NO_COLOUR'$(_vde_add_lprompt)'
#'$(_vde_add_rprompt)'%(!.${PR_RED}#.${PR_LIGHT_GREEN}%%)$PR_NO_COLOUR '

    PROMPT='$BG_PR_WHITE$PR_LIGHT_GREY%(!.%n@%m.$PR_LIGHT_GREEN)${SSH_TTY:+$BG_PR_WHITE$PR_LIGHT_GREY %n@%m }\
$PR_WHITE$BG_PR_GREY $PR_LIGHT_WHITE%$PR_PWDLEN<...<%~%<< $PR_NO_COLOUR'$(_vde_add_lprompt)'
'$(_vde_add_rprompt)'%(!.${PR_RED}#.${PR_LIGHT_BLUE}λ)$PR_NO_COLOUR '

    # display exitcode on the right when >0
    if is-at-least 4.3.4 && [[ -o multibyte ]]; then
        return_code="%(?..%{$PR_RED%}%? ↵ $PR_NO_COLOUR)"
    else
        return_code="%(?..%{$PR_RED%}<%?> $PR_NO_COLOUR)"
    fi
    RPROMPT=' '$return_code''
#    RPROMPT=' '$return_code''$(_vde_add_rprompt)'$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_LIGHT_CYAN$PR_HBAR$PR_SHIFT_OUT\
#$PR_GREY($PR_WHITE%D{%H:%M}$PR_GREY)$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

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
# {{{ OPTIONS ----------------------------------------------------------------
if [ ${ZSH_VERSION//\./} -ge 420 ]; then
    autoload -U url-quote-magic
    zle -N self-insert url-quote-magic
fi
# }}}
# {{{ COMPLETIONS ------------------------------------------------------------
autoload -U zutil
autoload -U compinit
autoload -U complist
compinit -i -d $HOME/run/zcompdump-$HOST-$UID

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
# Force file name completion on C-x TAB, Shift-TAB.
# From http://chneukirchen.org/blog/archive/2011/02/10-more-zsh-tricks-you-may-not-know.html
zle -C complete-files complete-word _generic
zstyle ':completion:complete-files:*' completer _files
bindkey "^X^I" complete-files
bindkey "^[[Z" complete-files
# Force menu on C-x RET.
zle -C complete-first complete-word _generic
zstyle ':completion:complete-first:*' menu yes
bindkey "^X^M" complete-first
# Copy-earlier-word (M-.M-.M-m)
# From http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word
# insert Unicode character
autoload      insert-unicode-char
zle -N        insert-unicode-char
bindkey '^xi' insert-unicode-char
#o "ctrl-e D" to insert the actual datetime YYYY/MM
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
              __insert-last-typed-word() { zle insert-last-word -- -1 -1 };
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
# History
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[OA" history-beginning-search-backward
bindkey "^[OB" history-beginning-search-forward
# Better CTRL-R
# From http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html
autoload -Uz narrow-to-region
function _history-incremental-preserving-pattern-search-backward
{
  local state
  MARK=CURSOR  # magick, else multiple ^R don't work
  narrow-to-region -p "$LBUFFER${BUFFER:+>>}" -P "${BUFFER:+<<}$RBUFFER" -S state
  zle end-of-history
  zle history-incremental-pattern-search-backward
  narrow-to-region -R state
}
zle -N _history-incremental-preserving-pattern-search-backward
bindkey "^R" _history-incremental-preserving-pattern-search-backward
bindkey -M isearch "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward
# }}}
# {{{ ALIAS ------------------------------------------------------------------
test -f $HOME/.sh/plugins/z/z.sh && . $HOME/.sh/plugins/z/z.sh
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
hash -d grub=/boot/grub
hash -d log=/var/log
hash -d www=/var/www
hash -d sh=$HOME/.sh
hash -d mr=$XDG_CONFIG_HOME/mr
hash -d repo.d=$XDG_CONFIG_HOME/vcsh/repo.d
hash -d gh=$HOME/src/github
hash -d exercism=$HOME/src/exercism
hash -d znk=$HOME/src/zenika
hash -d jcd=$HOME/src/jcdecaux
hash -d configs=$HOME/src/configs
hash -d sites=$HOME/src/sites
hash -d go=$HOME/lib/go/src
hash -d docker=$HOME/lib/go/src/github.com/docker
hash -d shakers=$HOME/lib/go/src/github.com/vdemeester/shakers
hash -d traefik=$HOME/lib/go/src/github.com/emilevauge/traefik
hash -d ansibles=$HOME/src/configs/ansibles
hash -d experiments=$HOME/src/experiments
# few more default dirs {{{
command -v xdg-user-dir >/dev/null && {
hash -d docs=$(xdg-user-dir DOCUMENTS)
hash -d org=$(xdg-user-dir DESKTOP)/org
hash -d notes=$(xdg-user-dir DESKTOP)/org/notes
hash -d todos=$(xdg-user-dir DESKTOP)/org/todos
hash -d pics=$(xdg-user-dir PICTURES)
hash -d pictures=$(xdg-user-dir PICTURES)
hash -d downloads=$(xdg-user-dir DOWNLOAD)
hash -d dls=$(xdg-user-dir DOWNLOAD)
hash -d music=$(xdg-user-dir MUSIC)
hash -d videos=$(xdg-user-dir VIDEOS)
hash -d templates=$(xdg-user-dir TEMPLATES)
hash -d public=$(xdg-user-dir PUBLICSHARE)
}
# }}}
# }}}
# {{{ PLUGINS
source $zdotdir/.sh/plugins/zaw/zaw.zsh
bindkey '^x,' zaw
#source $zdotdir/.sh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source $zdotdir/.sh/plugins/zsh-autosuggestions/autosuggestions.zsh
#AUTOSUGGESTION_HIGHLIGHT_COLOR='fg=4'
#bindkey '^T' autosuggest-toggle
#zle-line-init() {
#    zle autosuggest-start
#}
#zle -N zle-line-init
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

[ -s "/home/vincent/.nvm/nvm.sh" ] && . "/home/vincent/.nvm/nvm.sh" # This loads nvm
