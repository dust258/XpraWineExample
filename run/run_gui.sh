#!/bin/bash
pid=0

# run application
echo "set winedebug to ignore the following fixme-logs:"
export WINEDEBUG=fixme-win,fixme-event,fixme-nls,fixme-treeview,fixme-gdiplus,fixme-imm,fixme-keyboard,fixme-nls,fixme-ntdll,fixme-shell,fixme-thread,fixme-toolhelp,fixme-uxtheme,fixme-wtsapi,fixme-treeview,fixme-file,fixme-font
echo $WINEDEBUG

# Make sure Wine is running
wine  wineserver -w

# Indicates the width of the terminal device in character.
# Determinise the length of the line in logs (default 80 characters)
stty -F /dev/stdout cols 500

echo "xpra start --start-child-after-connect"

# Debug Clipboard
export XPRA_CLIPBOARD_DEBUG=1

# Start xpra server
xpra start --start-child-after-connect="wine notepad" --env=XDG_RUNTIME_DIR=/run/user/$UID --bind-tcp=0.0.0.0:8085 --no-daemon &
pid=$! # a special shell variable that stores the PID of the most recently executed background process
wait ${!}