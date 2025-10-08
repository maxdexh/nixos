-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autolib = require("util.autolib")

-- set LSP keybinds
vim.api.nvim_create_autocmd("LspAttach", {
   group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
   callback = function(event)
      autolib.lang.dbg_err(function()
         autolib.configured_keymaps.set_lsp_keybinds(event.buf)
      end)
   end,
})
