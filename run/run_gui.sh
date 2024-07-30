#!/bin/bash
pid=0
# run application
echo "set winedebug to ignore the following fixme-logs:"
export WINEDEBUG=fixme-win,fixme-event,fixme-nls,fixme-treeview,fixme-gdiplus,fixme-imm,fixme-keyboard,fixme-nls,fixme-ntdll,fixme-shell,fixme-thread,fixme-toolhelp,fixme-uxtheme,fixme-wtsapi,fixme-treeview,fixme-file,fixme-font
echo $WINEDEBUG
# Indicates the width of the terminal device in character.
# Determinise the length of the line in logs (default 80 characters)
stty -F /dev/stdout cols 500
echo "xpra start --start-child-after-connect"
# Debug Clipboard
export XPRA_CLIPBOARD_DEBUG=1
# Start xpra server with gedit (notepad without wine)
xpra start --start-child-after-connect="gedit" --env=XDG_RUNTIME_DIR=/run/user/$UID --bind-tcp=0.0.0.0:8085 --no-daemon & pid=$! # a special shell variable that stores the PID of the most recently executed background process
# Start xpra server with the wine notepad (notepad without wine)
#xpra start --start-child-after-connect="wine notepad.exe" --env=XDG_RUNTIME_DIR=/run/user/$UID --bind-tcp=0.0.0.0:8085 --no-daemon &
# Start xpra server with the wine notepad (notepad without wine)
#xpra start --start-child-after-connect="wine notepad.exe" --env=XDG_RUNTIME_DIR=/run/user/$UID --bind-tcp=0.0.0.0:8085 --no-daemon &
# Start xpra server with a sample application in wine (uncomment copy in Dockerfile)
#xpra start --start-child-after-connect="wine ./program/Sample.exe" --env=XDG_RUNTIME_DIR=/run/user/$UID --bind-tcp=0.0.0.0:8085 --no-daemon &
wait ${!}