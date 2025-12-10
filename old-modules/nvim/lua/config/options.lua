-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable spellchecking
vim.opt.spelllang = {}

vim.opt.timeoutlen = 750

vim.cmd("set shell=fish")

--vim.g.tex_conceal = ""
--vim.o.conceallevel = 0
vim.o.termguicolors = true
vim.g.lazyvim_picker = "snacks"
vim.g.snacks_animate = false
vim.g.c_syntax_for_h = true
vim.o.clipboard = "" --[[@as any]]
vim.opt.cursorline = false
-- vim.g.lazyvim_rust_diagnostics = "bacon-ls"
