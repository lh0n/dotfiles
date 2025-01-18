#!/usr/bin/env bash

# Script for automating the initial setup and maintenance of dotfiles.
#
# Goals:
#   1) Idempotency. It should always produce the same result, regardless of
#      how many times this script is executed.
#   2) Dependencies. It assumes dependencies are already installed via ansible.
#      Therefore, it won't validade whether dependencies already exist.

#set -o xtrace   # verbose
set -o errexit  # stop on error

echo "[STOW]: Main Package"
stow --verbose --restow --adopt .
echo

echo "[STOW]: Outdoor (/etc) Package"
pushd outdoor
sudo stow --verbose --restow --adopt --target /etc etc
popd
echo

echo "[STOW]: Outdoor (/usr) Package"
pushd outdoor
sudo stow --verbose --restow --adopt --target /usr usr
popd
echo

echo "[ACLs]: Ensure permissions are set correctly"

# outdoor: otherwise tools such as GDM cannot read custom configs.
sudo chown -R lhon:lhon ./outdoor/
find ./outdoor/ -type d | xargs chmod --changes 755
find ./outdoor/ -type f | xargs chmod --changes 644
