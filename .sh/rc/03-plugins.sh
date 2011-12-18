# Loading plugin(s)
for plugin in ${SH}/plugins/*.{sh,${CSHELL}}; do
    . ${plugin}
done
