-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable spellchecking
vim.opt.spelllang = {}

-- https://www.reddit.com/r/neovim/comments/12lf0ke/does_anyone_have_a_cmdheight0_setup_without/
-- 0 looks way better, but causes annoying hit-enter prompts when editing lua files
-- TODO: Is there a better way to handle this? See :h hit-enter for how to reduce prompt frequency
vim.opt.cmdheight = 1

vim.opt.timeoutlen = 750

vim.cmd([[
set shell=fish
]])

vim.g.tex_conceal = ""
vim.opt.conceallevel = 0
vim.opt.termguicolors = true
vim.g.lazyvim_picker = "telescope"
vim.g.snacks_animate = false
vim.g.c_syntax_for_h = true
-- vim.g.lazyvim_rust_diagnostics = "bacon-ls"

-- TODO: Find a good way to do this in nix
--
-- local venv = vim.fn.stdpath("config") .. "/.venv"
-- if vim.uv.fs_stat(venv) then ---@diagnostic disable-line:undefined-field
--    vim.g.python3_host_prog = venv .. "/bin/python3"
-- else
--    vim.notify("MISSING PYTHON VENV", vim.log.levels.ERROR)
-- end
