-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local libs = require("util.libs")

-- set LSP keybinds
vim.api.nvim_create_autocmd("LspAttach", {
   group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
   callback = function(event)
      libs.r.lang.dbg_err(function()
         libs.r.configured_keymaps.set_lsp_keybinds(event.buf)
      end)
   end,
})
