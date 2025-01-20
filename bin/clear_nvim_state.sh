#!/usr/bin/env bash

# Script for automating clearing Neovim state.
# Useful for ensuring a total config refresh.

set -o xtrace   # verbose
set -o errexit  # stop on error

# Ensure only one argument (NVIM_APP path) is supported.
if [[ $# > 1 ]]; then
  echo "Enter a single config path: "
  read config
elif [[ $# == 1 ]]; then
  config="$1"
  echo "Custom config name: ${config}"
else
  config="nvim"
  echo "Default config name: ${config}"
fi

SHARE_DIR="${HOME}/.local/share/${config}"
STATE_DIR="${HOME}/.local/state/${config}"
CACHE_DIR="${HOME}/.cache/${config}"

echo "Removing: ${SHARE_DIR}"
rm -vrf "${SHARE_DIR}/"

echo "Removing: ${STATE_DIR}"
rm -vrf "${STATE_DIR}/"

echo "Removing: ${CACHE_DIR}"
rm -vrf "${CACHE_DIR}/"
