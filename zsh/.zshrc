export LANG="en_US.UTF-8"
export LANGUAGE=${LANG}
#export LC_ALL="C"
export TZ="Europe/Zurich"

# Ensure safer umask
umask 027

# Disable ctrl+s|q
setopt noflowcontrol

# Enable vim mode (managed by plugin zsh-vi-mode)
# export KEYTIMEOUT=1
# bindkey -v

# Setup globbing
setopt extended_glob # Treat the '#', '~' and '^' characters as part of patterns for filename generation,
setopt nomatch # If a pattern for filename generation has no matches, print an error.
setopt bad_pattern # Print error for mal-formed patterns.

# History settings
setopt extended_history       # Include timestamps.
setopt hist_allow_clobber     # Add '|' to output redirections in the history.
setopt hist_ignore_space      # Do not add to history if first character is a space.
setopt hist_reduce_blanks     # Remove superfluous blanks.
setopt hist_verify            # If line contains history expansion, don't execute.
setopt inc_append_history     # Add lines to history right-away.
setopt share_history          # Import from and append commands to the history file.

# History deduplication settings
setopt hist_ignore_all_dups   # Discard oldest line when a new dup occurs in internal history.
setopt hist_save_no_dups      # When writing out the history file, discard dups.
setopt hist_find_no_dups      # Do not display duplicates when searching history.
setopt hist_expire_dups_first # When history fills up, delete duplicates before unique commands.

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

# Open current line in $EDITOR - (vv -> managed by zsh-vim-mode)
# autoload -U edit-command-line
# zle -N edit-command-line
# bindkey '^X^E' edit-command-line

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

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# Setup pager
which less > /dev/null && export PAGER=$(which less)
which zless > /dev/null && export PAGER=$(which zless)

# Setup logging
logging() {
  local level="${1:-info}"  # man logger - for possible levels.
  local message="${2:-}"
  logger ${level} --id=$$ $(basename "$0") "[ZSHRC]:" "${message}"
}

setup_editor() {
  local -r vim_path="$(command -v vim)"
  local nvim_path="$(command -v nvim)"
  nvim_path="${nvim_path#*=}"  # excludes alias prefix including the `=` sign.
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
     # (N-.) is a Zsh glob qualifier that ensures we only source normal, existing files
     for i in "${include_dir}"/*(N-.); do
       if source "${i}"; then
         logging info "Sourced: $(basename "${i}")"
       else
         logging error "Failed to source: $(basename "${i}")"
       fi
     done
  fi
}

safe_symlink() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: safe_symlink <target> <link_name>"
    echo "  - target: The actual file/directory you want to point to."
    echo "  - link_name: The path where the symlink should be created."
    return 1
  fi

  local target="$1"
  local link="$2"

  # 1. If it's already a valid symlink pointing to the exact target, do nothing.
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    logging info "The symlink is already correct. Target: ${target}, Link: ${link}"
    return 0
  fi

  # 2. If something exists at the link path (file, dir, or broken/wrong symlink)
  if [[ -e "$link" || -L "$link" ]]; then

    # If it's just a symlink pointing to the wrong place, it's safe to delete
    if [[ -L "$link" ]]; then
      logging info "Removing old/incorrect symlink: ${link}"
      rm "$link"
    else
      # It's a real file or directory! Time to back it up safely.
      local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
      local backup="${link}_bkp_${timestamp}"

      logging warn "Existing file found at ${link}. Backing up to ${backup}"
      mv "$link" "$backup"
    fi
  fi

  # 3. Create the parent directory if it doesn't exist, then symlink
  mkdir -p "$(dirname "$link")"
  if ln -s "$target" "$link"; then
    logging info "Successfully created symlink: ${link} -> ${target}"
  else
    logging error "Failed to create symlink: ${link} -> ${target}"
    return 1
  fi
}

setup_prompt() {
  local chassis="$(hostnamectl chassis)"
  local parent="${XDG_CONFIG_HOME:-$HOME/.config}"
  local target="${parent}/starship/${chassis}.toml"
  local link="${parent}/starship.toml"

  case $chassis in
    "laptop")
      safe_symlink "${target}" "${link}"
      logging info "prompt configured for chassis: ${chassis}"
    ;;
    "desktop")
      safe_symlink "${target}" "${link}"
      logging info "prompt configured for chassis: ${chassis}"
      ;;
    "vm")
      safe_symlink "${target}" "${link}"
      logging info "prompt configured for chassis: ${chassis}"
      ;;
    "*")
      safe_symlink "${parent}/starship/default.toml" "${link}"
      logging info "prompt  configured for chassis: default"
      ;;
  esac

  #   Launch the starship.
  #     installed with: cargo install starship [--locked]
  if [[ $+command[starship] ]]; then
    eval "$(starship init zsh)"  # This sub-shell must be quoted, otherwise nothing happens.
    logging info "Starship prompt loaded successfully."
  else
    logging error "Starship is not installed or not in the PATH."
  fi
}

setup_zoxide() {
  local zoxide="${HOME}/.cargo/bin/zoxide"
  if [[ ! -x ${zoxide} ]]; then
    logging warning "zoxide: CLI is not installed."
    return
  fi
  eval "$(zoxide init --cmd cd zsh)"
}

dump_motd() {
  local motd="${HOME}/.cargo/bin/dump-motd"
  if [[ ! -x ${motd} ]]; then
    logging warning "dump_motd: CLI is not installed."
    return
  fi

  if ! ${motd} 2>/dev/null; then
    logging error "dump_motd: Non-zero exit status."
  fi
}

# junegunn/fzf
#   TODO: Move installation to ansible or nix.
#   installed with: ./install --no-updaterc --no-bash --no-fish --no-nushell --xdg --all
setup_fzf() {
  local fzf_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf.zsh"
  if [ -f "${fzf_cfg}" ]; then
    source "${fzf_cfg}"
  fi

  # 1. Tmux Integration (Works perfectly in Wayland terminals like Foot, Alacritty, Kitty)
  export FZF_TMUX=1
  export FZF_TMUX_OPTS="-p 80%,60%"

  # 2. Global Polish
  export FZF_DEFAULT_OPTS="
    --extended
    --height=50%
    --layout=reverse
    --border=rounded
    --info=inline-right
    --bind='ctrl-/:toggle-preview'
  "

  # 3. File Search
  export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --preview-window right:60%:hidden
  "

  # 4. History Search
  export FZF_CTRL_R_OPTS="
    --border-label=' Command History '
    --border-label-pos=2
    --tiebreak=index
    --exact
    --preview='echo {}'
    --preview-window=down:3:hidden:wrap
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  "
}
# Load FZF before zsh-vi-mode initializes.
setup_fzf

# zsh-vi-mode:
#   - Default config entry-point, called automatically.
#   - Installed with antidote.
#   - Must be defined before loading antidote.
#   - Must come after setup_fzf.
zvm_config() {
  ZVM_KEYTIMEOUT=20
  ZVM_LINE_INIT_MODE=$ZVM_MODE_LAST
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
  ZVM_VI_SURROUND_BINDKEY="s-prefix"  # sa, sd, sr

  # --- Visual Mode Highlight ---
  ZVM_VI_HIGHLIGHT_BACKGROUND="#665c54" # Gruvbox bg3
  ZVM_VI_HIGHLIGHT_FOREGROUND="white"
  ZVM_VI_HIGHLIGHT_EXTRASTYLE="bold,underline"

  # --- Cursor Colors ---
  # 1. Retrieve the default cursor styles (shapes) from the plugin
  local ncur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)
  local icur=$(zvm_cursor_style $ZVM_INSERT_MODE_CURSOR)
  local vcur=$(zvm_cursor_style $ZVM_VISUAL_MODE_CURSOR)

  # 2. Append Gruvbox hex colors to the styles using terminal escape sequences
  ZVM_NORMAL_MODE_CURSOR=$ncur'\e\e]12;#fe8019\a'
  # ZVM_INSERT_MODE_CURSOR=$icur'\e\e]12;#d65d0e\a'
  ZVM_INSERT_MODE_CURSOR=$icur'\e\e]12;#fb4934\a'
}

# zsh-vi-mode: Useful for overriding settings like key bindings.
function zvm_after_init() {
  # Return some keybindins to FZF.
  zvm_bindkey viins '^R' fzf-history-widget
  zvm_bindkey vicmd '^R' fzf-history-widget
  zvm_bindkey viins '^T' fzf-file-widget
  zvm_bindkey vicmd '^T' fzf-file-widget
  zvm_bindkey viins '\ec' fzf-cd-widget
  zvm_bindkey vicmd '\ec' fzf-cd-widget
}

# Antidote setup.
# Reminders:
#   - Do not do this inside a function to avoid scoping traps.
#   - Must load antidote after zvm_config() is defined.
antidote_cfg="${HOME}/.antidote/antidote.zsh"
if [[ -f "${antidote_cfg}" ]]; then
  source "${antidote_cfg}"
  antidote load
fi

setup_editor
shell_includes
setup_prompt
setup_zoxide
dump_motd

