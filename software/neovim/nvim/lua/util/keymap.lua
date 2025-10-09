local autolib = require("util.autolib")

local keymap = {}

---@alias Util.keymap.Action string|fun()
---@alias Util.keymap.Binding string
---@alias Util.keymap.Mode string[]|string
---@alias Util.keymap.Setter fun(mode: Util.keymap.Mode, binding: Util.keymap.Binding, action: Util.keymap.Action, opts: vim.keymap.set.Opts)
---
---@class Util.keymap.SharedOpts: vim.keymap.set.Opts
---@field mode? Util.keymap.Mode
---@field setter? Util.keymap.Setter
---
---@class (exact) Util.keymap.KeyOpts: Util.keymap.SharedOpts
---@field desc string
---@field [1] Util.keymap.Binding
---@field [2] Util.keymap.Action

---@param opts Util.keymap.KeyOpts
local function keymap_set(opts)
   local action = autolib.tbl.pop_key(opts, 2)
   local binding = autolib.tbl.pop_key(opts, 1)
   local mode = autolib.tbl.pop_key(opts, "mode") or "n"
   local setter = autolib.tbl.pop_key(opts, "setter") or vim.keymap.set

   autolib.misc.dbg_err(function()
      setter(mode, binding, action, opts)
   end)
end

---@class Util.keymap.KeyMapsAndSharedOpts: { [integer]: Util.keymap.KeyOpts }, Util.keymap.SharedOpts

---@param keymaps Util.keymap.KeyOpts[]|Util.keymap.KeyMapsAndSharedOpts
---@return Util.keymap.KeyOpts[]
local function keymap_normalize_shared(keymaps)
   local shared_opts = {}
   for k, v in pairs(keymaps) do
      -- copy over all named fields
      if type(k) == "string" then
         keymaps[k] = nil
         shared_opts[k] = v
      end
   end

   local ret = {}
   for _, opts in ipairs(keymaps) do
      autolib.misc.dbg_err(function()
         local acc_opts = {}

         -- copy shared
         if shared_opts ~= nil then
            for k, v in pairs(shared_opts) do
               acc_opts[k] = v
            end
         end

         -- copy and override opts
         for k, v in
            pairs(opts --[[@as { [unknown]: unknown }]])
         do
            acc_opts[k] = v
         end

         table.insert(ret, acc_opts)
      end)
   end
   return ret
end

---@param keymaps Util.keymap.KeyOpts[]|Util.keymap.KeyMapsAndSharedOpts
function keymap.set_many(keymaps)
   for _, opts in ipairs(keymap_normalize_shared(keymaps)) do
      keymap_set(opts)
   end
end

---@param cmd string
---@return fun()
function keymap.cmdfunc(cmd)
   return function()
      vim.cmd(cmd)
   end
end

---@param keys (string | LazyKeysSpec)[]
---@return Util.keymap.Setter
function keymap.lazy_keys_spec_setter(keys)
   ---@param opts vim.keymap.set.Opts
   return function(mode, binding, action, opts)
      local spec = opts --[[@as LazyKeysSpec]]
      spec[1] = binding
      spec[2] = action
      spec.mode = mode
      table.insert(keys, spec)
   end
end

return keymap
