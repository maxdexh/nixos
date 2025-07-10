---@diagnostic disable: duplicate-require

local lazy_eval = require("util.lazy-eval")

local deps

local real_require = require
-- fake require function for typing
local function require(mod)
   return mod
end
deps = {
   lspc = require("lspconfig"), -- FIXME: Cant find

   lspcc = require("lspconfig.configs"),

   tele = require("telescope"),

   telef = require("telescope.builtin"),

   quarto_runner = require("quarto.runner"),

   tbl = require("util.tbl"),
   nls = require("null-ls"),

   mc = require("multicursor-nvim"),
   dap = require("dap"),

   cmenu = require("colorful-menu"),

   ls_fmt = require("luasnip.extras.fmt"),
   ls = require("luasnip"),

   lazy_eval = require("util.lazy-eval"),
   lazyvim = require("util.lazyvim"),
   lang = require("util.lang"),
   keymap = require("util.keymap"),
   list = require("util.list"),
   log = require("util.log"),
   iter = require("util.iter"),
   vararg = require("util.vararg"),
   func = require("util.func"),
   configured_keymaps = require("util.configured-keymaps"),
}

---@return any
local function modname(dep)
   ---@cast deps -?
   return deps[dep] or error("Invalid dep " .. dep)
end

return {
   r = lazy_eval.table(deps, function(key)
      return real_require(modname(key))
   end),
   f = lazy_eval.table(deps, function(key)
      return lazy_eval.lazy_require_funcs(modname(key))
   end),
}
