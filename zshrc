#export LANG="en"
#export LANGUAGE=${LANG}
#export LC_ALL="C"
export TZ="Europe/Zurich"

bindkey -e
bindkey '^R' history-incremental-search-backward

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# Setup editor
export EDITOR=$(which vim)
export VISUAL=${EDITOR}

# Setup pager
which less > /dev/null && export PAGER=$(which less)
which zless > /dev/null && export PAGER=$(which zless)

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
HISTFILE=~/.histfile
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

# Open current line in $EDITOR, awesome when editing multiline commands (ctrl+x+e) .
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Setup prompting
setopt prompt_subst # Allow parameter and arithmetic expansion and also command substitution be performed in prompts.

# Setup completion
setopt auto_list # Automatically list choices on an ambiguous completion.
setopt auto_menu # Automatically use menu completion after the second consecutive request for completion.
setopt no_list_ambiguous # Better disable that if auto_list is set.
setopt no_menu_complete  # Better disable that if auto_menu is set.
setopt no_auto_param_slash  # Don't mess with my slashes
setopt no_auto_remove_slash # Don't mess with my slashes
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' max-errors 1
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit

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
    PROMPT=$'\n[%D{%a %d-%b, %T}] %B$(git_super_status)%b\n%F{magenta}%m%f:%F{blue}[%2~]%f\n%F{cyan}%#%f '
  else
    PROMPT=$'\n[%D{%a %d-%b, %T}]\n%F{magenta}%m%f:%F{blue}[%2~]%f\n%F{cyan}%#%f '
  fi
}

## ssh_agent function helper
#run_ssh_agent() {
#  ssh-agent | grep -vi 'agent pid' > ~/.ssh-agent
#  source ~/.ssh-agent
#}
#
#
## ensure ssh-agent is running and the user's environment is up to date
#ssh_agent() {
#  if [[ -f ~/.ssh-agent ]]; then
#    source ~/.ssh-agent
#    if [[ -n ${SSH_AGENT_PID} ]]; then
#      if ! ps -p ${SSH_AGENT_PID} | grep 'ssh-agent' &>/dev/null; then
#        run_ssh_agent
#      fi
#    fi
#  else
#    run_ssh_agent
#  fi
#}


# source other scripts if found in your $HOME/.shell_include
shell_includes() {
  if [[ -d ~/.shell_include ]]; then
     for i in $(ls -a ~/.shell_include | egrep -v '^(\.|\.\.)$'); do
       source ~/.shell_include/${i}
     done
  fi
}

# This will save the DISPLAY variable to ~/.xserver_display if the terminal
# isn't screen (i.e. when you log in) and source that file in all other cases
# (when you open new screen windows)
set_xdisplay() {
  case "${TERM}" in
    screen*|tmux*)
      [[ -f ~/.xserver_display ]] && source ~/.xserver_display
      ;;
    *)
      echo "export DISPLAY=${DISPLAY}" > ~/.xserver_display
  esac
}

# Setup golang environment if it's installed.
set_golang() {
  local go_bin="/usr/local/go/bin"

  if [[ -d ${go_bin} ]]; then
    export GOPATH="${HOME}/code/go"
    path+=("${go_bin}" "${GOPATH}/bin")
  fi
}

# other common settings
set_common() {
  # disable bell
  [[ ! -z ${DISPLAY} ]] && which xset &> /dev/null && xset b off

  # enable color support of ls and also add handy aliases
  if [[ ${TERM} != "dumb" && -f ${HOME}/.dircolors ]]; then
    eval "$(dircolors -b ${HOME}/.dircolors)"
    ls --color=auto &> /dev/null && alias ls="ls --color=auto"
  fi

  # if personal bin directory exists, add it to the path.
  [[ -d ~/bin ]] && path+=('~/bin')
}

set_prompt
set_xdisplay
set_common
shell_includes
set_golang
#ssh_agent
