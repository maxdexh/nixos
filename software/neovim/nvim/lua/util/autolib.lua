---@diagnostic disable: duplicate-require

local deps

local real_require = require
-- fake require function for typing
local function require(mod)
   return mod
end
deps = {
   lspc = require("lspconfig"),

   lspcc = require("lspconfig.configs"),

   tscope = require("telescope"),

   tscope_funcs = require("telescope.builtin"),

   quarto_runner = require("quarto.runner"),

   tbl = require("util.tbl"),
   nls = require("null-ls"),

   multicursor = require("multicursor-nvim"),
   dap = require("dap"),

   cmenu = require("colorful-menu"),

   ls_fmt = require("luasnip.extras.fmt"),
   ls = require("luasnip"),

   nvim = require("util.nvim"),
   lang = require("util.lang"),
   keymap = require("util.keymap"),
   list = require("util.list"),
   log = require("util.log"),
   iter = require("util.iter"),
   vararg = require("util.vararg"),
   configured_keymaps = require("util.configured-keymaps"),
}

---@return any
local function modname(dep)
   ---@cast deps -?
   return deps[dep] or error("Invalid dep `" .. dep .. "`")
end

---@generic T: table
---@param _typing_fake_table T
---@param getter fun(key: string): any
---@return T
function lazy_table(_typing_fake_table, getter)
   return setmetatable({}, {
      ---@return unknown
      __index = function(self, key)
         rawset(self, key, getter(key))
         return self[key]
      end,
   })
end

return lazy_table(deps, function(key)
   return real_require(modname(key))
end)
