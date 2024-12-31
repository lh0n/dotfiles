# ZSH Variable Expansion Syntax
#
#  $ man zshexpn
#    ${name:=word} -> if name is unset or null then set it to word.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:=${HOME}/.config}
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"
export XDG_DATA_HOME=${XDG_DATA_HOME:=${HOME}/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:=${HOME}/.local/state}

