-- Neovim's built-in experimental message + cmdline UI ("ui2").
--
-- Replaces the noice.nvim + nui.nvim + nvim-notify stack with the native
-- `ext_messages` presentation layer shipped in Neovim 0.12 under the
-- `vim._core.ui2` namespace.
--
-- NOTE: `vim._core` is a private, experimental namespace. The pcall guard keeps
-- startup from breaking if the module is renamed/removed in a future release
-- (it has already moved once: `vim._extui` -> `vim._core.ui2`). Revisit when
-- this graduates to a stable `vim.ui`-level API.
local ok, ui2 = pcall(require, 'vim._core.ui2')
if not ok then
  vim.notify('vim._core.ui2 not available; falling back to the legacy message UI', vim.log.levels.WARN)
  return
end

ui2.enable({
  enable = true,
  msg = {
    -- Route messages through the cmdline by default; spill into an ephemeral
    -- window when they exceed 'cmdheight'.
    targets = 'cmd',
    msg = {
      timeout = 4000, -- how long an ephemeral message stays visible (ms)
    },
  },
})
