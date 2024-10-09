#!/bin/sh

. /etc/profile
export PS1="(INTERNAL_FS) $PS1"

cd "/mnt/$OWD"

shift 2

# This can be changed to only execute a specific program

#exec bash --norc "$@"

if echo "$ARGV0" | grep '\.AppImage$' &> /dev/null; then
    exec bash --norc "$@"
else
    exec "$(basename "$ARGV0")" "$@"
fi
