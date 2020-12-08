# Disable ctrl+s|q
setopt noflowcontrol

# Enable vi mode.
export KEYTIMEOUT=1
bindkey -v

# Setup globbing
setopt extended_glob # Treat the '#', '~' and '^' characters as part of patterns for filename generation,
setopt nomatch # If a pattern for filename generation has no matches, print an error.
setopt bad_pattern # Print error for mal-formed patterns.

# Setup history
setopt hist_allow_clobber # Add '|' to output redirections in the history.
setopt hist_ignore_all_dups # Discard oldest line when a new dup occurs.
setopt hist_save_no_dups # When writing out the history file, discard dups.
setopt hist_ignore_space # Do no add to history if first character is a space.
setopt hist_reduce_blanks # Remove superfluous blanks.
setopt hist_verify # If line contains history expansion, don't execute.
setopt share_history # Import from and append commands to the history file.
HISTFILE=${HOME}/.cache/zsh/history
HISTSIZE=100000
SAVEHIST=100000

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
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# Setup pager
which less > /dev/null && export PAGER=$(which less)
which zless > /dev/null && export PAGER=$(which zless)

# Setup dircolors theme
[[ -r ${HOME}/.dircolors ]] && eval $(dircolors ${HOME}/.dircolors)

# FZF - Fuzzy Finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--extended --height 40% --layout=reverse --border'
# Follow symbolic links and do not ignore hidden files.
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

# Configures a nice prompt with helpful information.
# Depends on: https://github.com/olivierverdier/zsh-git-prompt.git
#
# This is just a reminder for the metadata available to configure the prompt:
#
#   %D date (strftime)
#   %? last exit code
#   %F fg color
#   %f fg color reset
#   %n username
#   %s hostname
set_prompt() {
  local git_prompt="${HOME}/github/zsh-git-prompt/zshrc.sh"
  if [[ -e ${git_prompt} ]]; then
    source "${git_prompt}"
    PROMPT=$'\n[%D{%a %d-%b, %T}] %B$(git_super_status)%b\n%F{green}%m%f:%F{blue}[%2~]%f\n%F{cyan}%#%f '
  else
    PROMPT=$'\n[%D{%a %d-%b, %T}]\n%F{yellow}%m%f:%F{blue}[%2~]%f\n%F{cyan}%#%f '
  fi
}

logging() {
  logger --id=$$ - $(basename "$0") - "$@"
}

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
  add_to_path "${HOME}/.local/bin"
  add_to_path "${HOME}/miniconda3/bin"
  add_to_path "/usr/local/go/bin"
}

set_path
shell_includes
#set_prompt

## zsh-vim-mode plugin
source "${HOME}/github/zsh-vim-mode/zsh-vim-mode.plugin.zsh"

# starship prompt
#   installed with: install.sh --bin-dir ~/.local/bin --verbose
[[ -x ${HOME}/.local/bin/starship ]] && eval $(starship init zsh)

# Load auto-suggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_USE_ASYNC="yes please"
ZSH_AUTOSUGGEST_STRATEGY=(completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#504945"

# Load syntax highlighting - Must be last
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Override bindings set by `zsh-vim-mode.plugin.zsh`
bindkey '^R' fzf-history-widget

