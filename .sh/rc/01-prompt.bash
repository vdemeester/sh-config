export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

__git_hash ()
{
    local g=$(__gitdir)
    if [ -n "$g" ]; then
        printf "$(git rev-parse --short HEAD 2>/dev/null)"
    fi
}

reset="$(tput sgr0)"
chroot="$(tput setab 7; tput setaf 0)"
if [ $(id -u) -eq 0 ]; then
   user_color="$(tput setaf 1)"
else
   user_color="$(tput setaf 2)"
fi
host="$(tput setaf 4)"
git_ps1="$(tput setaf 3)"
git_hash="$(tput bold; tput setaf 0)"

PS1='${debian_chroot:+${chroot}($debian_chroot)${reset} }${user_color}\u${reset}${host}@\h${reset}:\w $(__git_ps1 "\n${git_ps1}[%s${reset}${git_hash}($(__git_hash))${git_ps1}] ")${reset}\$ '
