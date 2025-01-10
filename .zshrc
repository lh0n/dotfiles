export LANG="en_US.UTF-8"
export LANGUAGE=${LANG}
#export LC_ALL="C"
export TZ="Europe/Zurich"

# Ensure safer umask
umask 027

# Disable ctrl+s|q
setopt noflowcontrol

# Enable vim mode.
export KEYTIMEOUT=1
bindkey -v

# Setup globbing
setopt extended_glob # Treat the '#', '~' and '^' characters as part of patterns for filename generation,
setopt nomatch # If a pattern for filename generation has no matches, print an error.
setopt bad_pattern # Print error for mal-formed patterns.

# Setup history
setopt extended_history # Include timestamps
setopt hist_allow_clobber # Add '|' to output redirections in the history.
setopt hist_ignore_all_dups # Discard oldest line when a new dup occurs.
setopt hist_save_no_dups # When writing out the history file, discard dups.
setopt hist_ignore_space # Do no add to history if first character is a space.
setopt hist_reduce_blanks # Remove superfluous blanks.
setopt hist_verify # If line contains history expansion, don't execute.
setopt inc_append_history # Add lines to history right-away
setopt share_history # Import from and append commands to the history file.

# Setup history file
[[ ! -d ${HOME}/.cache/zsh ]] && mkdir -p ${HOME}/.cache/zsh
export HISTFILE=${HOME}/.cache/zsh/history
export HISTSIZE=100000
export SAVEHIST=100000

# Setup pushd popd
setopt auto_pushd # Make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups # Don't push multiple copies of the same directory onto the directory stack.

# Setup Input/Output
setopt clobber # Allows '>' redirection to truncate existing files, and '>>' to create files.
setopt interactive_comments # Allow interactive comments.
setopt mail_warning # Warn if new mail arrived.
# setopt print_exit_value # Print non-zero status codes.

# Job control
setopt monitor # Allow job control.
setopt long_list_jobs # List jobs in the long format by default.
setopt check_jobs # Report the status of background and suspended jobs before exiting a shell.
setopt notify # Report the status of background jobs immediately.

# Setup ZLE (ZSH Line Editor)
setopt no_beep # No beep on error.

# Open current line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Setup prompting
setopt prompt_subst # Allow parameter and arithmetic expansion and also command substitution be performed in prompts.

# Setup completion
setopt no_auto_param_slash  # Don't mess with my slashes
setopt no_auto_remove_slash # Don't mess with my slashes
autoload -Uz compinit bashcompinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
bashcompinit
rpa='/usr/bin/register-python-argcomplete'  # provided by system package: 'python3-argcomplete'.
# Load pipx completion
eval "$(${rpa} pipx)"
# alias completion definitions for cfg
compdef cfg=git

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# Setup pager
which less > /dev/null && export PAGER=$(which less)
which zless > /dev/null && export PAGER=$(which zless)

# Setup logging
logging() {
  logger --id=$$ - $(basename "$0") - "$@"
}

# Setup editor
setup_editor() {
  local -r vim_path="$(command -v vim)"
  local -r nvim_cmd="$(command -v nvim)"
  nvim_path=${nvim_cmd#*=}  # captures only the path if this is an alias.
  if [[ -x ${nvim_path} ]]; then
    export EDITOR="${nvim_path}"
  elif [[ -x ${vim_path} ]]; then
    export EDITOR="${vim_path}"
  else
    export EDITOR="$(which nano)"
  fi
  export VISUAL="${EDITOR}"
}

# Setup dircolors theme
[[ -r ${HOME}/.dircolors ]] && eval $(dircolors ${HOME}/.dircolors)

# Source other scripts from $HOME/.shell_include.
# Hidden/dotfiles files are ignored.
shell_includes() {
  local -r include_dir="${HOME}/.shell_include"
  if [[ -d ${include_dir} ]]; then
     for i in $(ls "${include_dir}"); do
       if source "${include_dir}/${i}"; then
         logging "[ZSHRC]: Sourced ${i}"
       else
         logging "[ZSHRC]: Failed to source: ${i}"
       fi
     done
  fi
}

ssh_agent() {
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"
  if ! ssh-add -l &> /dev/null; then
    logging "ssh-agent not available yet"
    logging "attempting to start ssh-agent systemd service"
    systemctl --user start ssh-agent.service
    # ssh-agent -a ${SSH_AUTH_SOCK} &> /dev/null
  else
    logging "Reusing available ssh-agent"
  fi
}

# Add to PATH
add_to_path() {
  local -r dirpath="${1:?'Required path is missing.'}"
  if [[ -d ${dirpath} ]]; then
    path+=("${dirpath}")
  fi
}

# Set PATH
set_path() {
  add_to_path "${HOME}/bin"
  add_to_path "${HOME}/.cargo/bin"
  add_to_path "${HOME}/.local/bin"
  add_to_path "${HOME}/miniconda3/bin"
  add_to_path "/usr/local/go/bin"
  add_to_path "${HOME}/go/bin"
}

set_path 
export PATH
setup_editor
#ssh_agent
shell_includes

# junegunn/fzf
#   installed with: ./install --no-bash --no-fish --xdg --all
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
export FZF_DEFAULT_OPTS='--extended --height 40% --layout=reverse --border'
# Follow symbolic links and do not ignore hidden files.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

# starship prompt
#   installed with: cargo install starship [--locked]
[[ $+command[starship] ]] && eval "$(starship init zsh)"  # this sub-shell must be quoted, otherwise, nothing happens.

# Override bindings set by `zsh-vim-mode.plugin.zsh`
# bindkey '^R' fzf-history-widget

