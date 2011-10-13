# ssh plugin.. we will override ssh command to test hosts
ssh() {
    SSH_COMMAND=`which ssh`
    echo "ssh-wrap called"
    # Read .ssh/config file
    # Get the option for the given host
    # Look for #encoding
    # Use the value with luit if different from current locale
    $SSH_COMMAND $*
}
