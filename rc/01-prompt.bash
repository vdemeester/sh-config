#
# The prompt should be the following :
#
#     $user at $host in $path on $scm:$branch [$revision]
#     ?+ $
#
COLOR_DEFAULT="[00m"
COLOR_WHITE="[37m"
COLOR_GREEN="[32m"
COLOR_RED="[31m"
COLOR_ORANGE="[1;31m"
COLOR_BLUE="[34m"
COLOR_YELLOW="[33m"
COLOR_MAGENTA="[35m"
COLOR_VIOLET="[1;35m"

if test `id -u` == 0; then
    USER_COLOR=$COLOR_RED
else
    USER_COLOR=$COLOR_GREEN
fi

VCPROMPT=`which vcprompt`
lastcommanedfailed_prompt() {
    code=$?
    if test $code != 0; then
        echo -n $'\033[31m'
        echo -n "exited ${code} "
        echo -n $'\033[00m'
    fi
}

vde_vcprompt() {
    if ! test -z "${VCPROMPT}"; then
        ${VCPROMPT} -f $'on \033[35m%n:%b \033[1;35m[%r]\033[32m%u%m\033[00m'
    fi
}

export VDE_PROMPT='\e${USER_COLOR}\u \e${COLOR_DEFAULT}at \e${COLOR_BLUE}\h \
\e${COLOR_DEFAULT}in \e${COLOR_YELLOW}\w\e${COLOR_DEFAULT} \
`lastcommanedfailed_prompt`\
`vde_vcprompt`\
\n\e${COLOR_DEFAULT}$ '
export PS1="${VDE_PROMPT}"
