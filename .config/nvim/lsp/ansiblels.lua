-- Override for the ansible-language-server. Base cmd/root come from
-- nvim-lspconfig's shipped lsp/ansiblels.lua; merged with this on enable.
return {
  filetypes = { 'yaml' },
  root_markers = { 'ansible.cfg' },
}
