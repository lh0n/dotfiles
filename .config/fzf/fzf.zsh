# Setup fzf
#
# This assumes fzf was installed via: sudo apt install fzf
# ---------

examples="/usr/share/doc/fzf/examples"
completion="${examples}/completion.zsh"
bindings="${examples}/key-bindings.zsh"

# auto-completion
if [[ ! -f ${completion} ]]; then
  echo "Missing fzf completion.zsh config."
else
  source "${completion}" 2> /dev/null
fi

# key bindings
if [[ ! -f ${bindings} ]]; then
  echo "Missing fzf key-bindings.zsh config."
else
  source "${bindings}"
fi

