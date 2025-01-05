#!/bin/sh

set -e
set -x

device="$1"
partition="$2"

sudo umount "${partition?}"
sudo parted "${device?}" print
sudo parted "${device?}" rm 1
sudo parted "${device?}" mklabel msdos
sudo parted -a optimal "${device?}" mkpart primary fat32 0% 100%
sudo parted "${device?}" set 1 boot on
sudo parted "${device?}" print
sudo mkfs.fat -F 32 "${partition?}"

