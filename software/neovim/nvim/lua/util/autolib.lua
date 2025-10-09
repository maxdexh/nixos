local deps

local real_require = require
-- fake require function for typing
local function require(mod)
   return mod
end
deps = {
   tscope = require("telescope"),

   tscope_funcs = require("telescope.builtin"),

   nls = require("null-ls"),

   multicursor = require("multicursor-nvim"),
   dap = require("dap"),

   colorful_menu = require("colorful-menu"),

   tbl = require("util.tbl"),
   misc = require("util.misc"),
   keymap = require("util.keymap"),
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
