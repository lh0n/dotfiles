export EDITOR=$(which vim)
export VISUAL=${EDITOR}
export LANG="en"
export LANGUAGE=${LANG}
export LC_ALL="C"
export TZ="Europe/Zurich"

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

setopt auto_pushd
setopt autocd
setopt clobber
setopt extended_glob
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt histignorealldups
setopt hist_save_no_dups
setopt hist_verify
setopt inc_appendhistory
setopt no_beep
setopt notify
setopt prompt_subst
setopt pushd_ignore_dups
setopt pushd_silent
setopt share_history

bindkey -e
bindkey '^R' history-incremental-search-backward

which less > /dev/null && export PAGER=$(which less)
which zless > /dev/null && export PAGER=$(which zless)

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '$HOME/.zshrc'

autoload -U compinit
compinit


# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# set color prompt
# %D date (strftime)
# %? last exit code
# %F fg color
# %f fg color reset
# %n username
# %s hostname
#PROMPT=$'\n%D{%a %b %d %T %Z %Y}\n\n[$?] %F{27}%~%f\n%F{green}%n@%m%f %# '
#PROMPT=$'\n[$?] %F{27}%~%f\n%F{green}%n@%m%f %# '

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

# Set git-aware prompt.
# Depends on: https://github.com/olivierverdier/zsh-git-prompt.git
PROMPT=$'\n%B%F{white}[$?]\n%B%F{yellow}%m %F{blue}%~ %f%b$(git_super_status)%F{cyan}%#%f '

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


# other common settings
set_common() {
  # disable bell
  [[ ! -z ${DISPLAY} ]] && which xset &> /dev/null && xset b off

  # enable color support of ls and also add handy aliases
  if [[ "$TERM" != "dumb" && -f ~/.dir_colors ]]; then
    eval "$(dircolors -b ~/.dir_colors)"
    ls --color=auto > /dev/null 2>&1 && alias ls="ls --color=auto"
  fi

  # if present, add ~/bin to PATH
  [[ -d ~/bin ]] && export PATH="~/bin:${PATH}"
}


set_common
shell_includes
#ssh_agent
