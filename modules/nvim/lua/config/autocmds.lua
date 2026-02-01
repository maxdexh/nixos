-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local libs = require("util.libs")

libs.misc.dbg_err(function()
   -- Thank you LazyVim for just deciding to enable softwrap with an autocommand
   vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
end)
