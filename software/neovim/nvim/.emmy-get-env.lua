#!/usr/bin/env -S nvim -l

local envs = {
   LAZY_LIBRARY_PATH_PREFIX = vim.fn.stdpath("data") .. "/lazy/",
   VIMRUNTIME = vim.fn.expand("$VIMRUNTIME"),
}
local env_strs = {}
for k, v in pairs(envs) do
   table.insert(env_strs, k .. "=" .. v)
end
io.stdout:write(table.concat(env_strs, "\n"))
