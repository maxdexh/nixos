-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local libs = require("util.libs")

libs.r.lang.dbg_err(libs.r.configured_keymaps.set_global_keybinds)
