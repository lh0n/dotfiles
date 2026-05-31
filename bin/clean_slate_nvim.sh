#!/usr/bin/env bash

fd --type d '.*nvim.*' ~/.local/share/ -x echo rm -vrf
fd --type d '.*nvim.*' ~/.local/state/ -x echo rm -vrf
fd --type f 'lazy-lock.json' ~/.config/ -x echo rm -vrf

if [[ $1 == 'letsgo' ]]; then
    fd --type d '.*nvim.*' ~/.local/share/ -x rm -vrf
    fd --type d '.*nvim.*' ~/.local/state/ -x rm -vrf
    fd --type f 'lazy-lock.json' ~/.config/ -x rm -vrf
fi
