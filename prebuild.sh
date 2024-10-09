#!/bin/ash

# This script runs in the chroot after the overlay has been copied in and before appimage building

set -e
. /etc/profile

# Delete the cache from installing packages
rm -rf /var/cache/apk