start_keychain() {
  local -r kc="$(which keychain)"
  if [[ ! -x ${kc} ]]; then
    logging "keychain requested, but binary not available in PATH"
  else
    logging "starting keychain"
    ${kc}
    source "${HOME}/.keychain/${HOST}-sh"
    logging "keychain started"
  fi
}

start_keychain
