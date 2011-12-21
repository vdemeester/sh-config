# rbenv plugin
# Start rbenv stuff if present
if test -d $HOME/.rbenv; then
    command -v rbenv >/dev/null || {
        echo "plugins/rbenv: rbenv not in PATH, you are missing something… I guess"
        return
    }
    eval "$(rbenv init -)"
fi
