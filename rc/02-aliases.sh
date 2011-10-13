UNAME=$(uname)
alias oissh="TERM=xterm luit -x -encoding ISO-8859-15 ssh"
if test "${UNAME}" == "Darwin"; then
    # hard link to luit to by-pass luit from pkgsrc
    alias luit="/usr/X11/bin/luit"
    alias gvim="mvim" # for MacVim
    # -p is for handshake. This is needed on FreeBSD and Darwin
    # to get it work right.
    alias ls="ls -G"
    alias ll="ls -"
elif test "${UNAME}" == "Linux"; then
    alias ls="ls --color=always"
    alias ll="ls -l --group-directories-first"
fi
alias la="ls -a" # Show hidden files
alias lx="ls -lXB" # Sort by extension
alias lk="ls -lSr" # Sort by size (biggest last)
alias lc="ls -ltcr"         # sort by and show change time, most recent last
alias lu="ls -ltur"         # sort by and show access time, most recent last
alias lt="ls -ltr"          # sort by date, most recent last
alias lm="ls -al |more"     # pipe through 'more'
alias lr="ls -lR"           # recursive ls
alias lt="ls -lt"

alias tree="tree -C"
# processes
alias psa='ps auxwww'
# pipe into grep to find a proc
alias psg='psa | grep'

alias lsofp='sudo lsof -p'

alias tmux="tmux -2"

# which show all versions of an executable
alias whicha="which -a"
