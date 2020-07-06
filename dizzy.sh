#!/bin/sh
# live-build configuration script
# see 'man lb config'

# lb config
lb config noauto \
    --mode debian \
    --system live \
    --apt-recommends false \
    --architectures amd64 \
    --archive-areas 'main contrib non-free' \
    --security true \
    --source false \
    --binary-images iso-hybrid \
    --clean \
    --debconf-frontend dialog \
    --debian-installer live \
    --debian-installer-distribution buster \
    --debian-installer-gui true \
    --distribution buster \
    --firmware-binary true \
    --firmware-chroot true \
    --initramfs live-boot \
    --bootappend-live "boot=live config splash" \
    --memtest none \
    --win32-loader true

"${@}"
