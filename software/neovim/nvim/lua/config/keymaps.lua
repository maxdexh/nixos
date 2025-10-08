-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local autolib = require("util.autolib")

autolib.lang.dbg_err(autolib.configured_keymaps.set_global_keybinds)
