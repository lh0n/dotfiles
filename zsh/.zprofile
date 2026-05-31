# ~/.zprofile
# Master PATH Configuration (Sourced during GDM / niri-session login)

# Prevent duplicate entries in the path array automatically
typeset -U path

add_to_path() {
    local -r dirpath="${1:?'Required path is missing.'}"
    if [[ -d "${dirpath}" ]]; then
        path+=("${dirpath}")
    fi
}

set_path() {
    add_to_path "${HOME}/bin"
    add_to_path "${HOME}/.cargo/bin"
    add_to_path "${HOME}/.local/bin"
    add_to_path "${HOME}/go/bin"
    add_to_path "/usr/local/go/bin"

    # Force /usr/bin to the absolute top of the hierarchy.
    # Resolves tool conflicts between NodeJS LSPs/Linters and hashbang-borg-sre.
    # Ref: go/node-cli#installation
    path=(/usr/bin $path)
    export PATH
}

# Execute the path compilation
set_path

# Housekeeping: Clean up the functions so they don't pollute your interactive shells
unfunction add_to_path set_path

# Broadcast the final compiled PATH to the systemd user manager
# This uses Zsh's internal commands array to safely verify systemctl exists
if (( $+commands[systemctl] )); then
    systemctl --user import-environment PATH
fi
