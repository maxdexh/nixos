local libs = require("util.libs")

local keymap = {}

---@alias Util.keymap.Action string|fun()
---@alias Util.keymap.Mode string[]|string
---@alias Util.keymap.Binding string
---
---@class Util.keymap.SharedOpts: vim.keymap.set.Opts
---@field mode? Util.keymap.Mode
---@field setter? fun(mode: Util.keymap.Mode, binding: Util.keymap.Binding, action: Util.keymap.Action, opts: vim.keymap.set.Opts)
---
---@class Util.keymap.KeyOpts: Util.keymap.SharedOpts
---@field desc string
---@field [1] Util.keymap.Binding
---@field [2] Util.keymap.Action

---@param opts Util.keymap.KeyOpts
function keymap.set(opts)
   local action = table.remove(opts, 2) --[[@as Util.keymap.Action]]
   local binding = table.remove(opts, 1) --[[@as Util.keymap.Binding]]
   libs.r.lang.dbg_err(function()
      local mode = opts.mode or "n"
      opts.mode = nil

      local setter = opts.setter or vim.keymap.set
      opts.setter = nil

      setter(mode, binding, action, opts)
   end)
end

-- FIXME: setter should really only be allowed specifically in set_many

---@class Util.keymap.KeyMapsAndSharedOpts: { [integer]: Util.keymap.KeyOpts }, Util.keymap.SharedOpts

---@param keymaps Util.keymap.KeyOpts[]|Util.keymap.KeyMapsAndSharedOpts
---@return Util.keymap.KeyOpts[]
function keymap.normalize_shared(keymaps)
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
      libs.r.lang.dbg_err(function()
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
   for _, opts in ipairs(keymap.normalize_shared(keymaps)) do
      keymap.set(opts)
   end
end

---@param keymaps Util.keymap.KeyMapsAndSharedOpts
---@return LazyKeysSpec[]
function keymap.to_lazyvim_keys(keymaps)
   -- Formats happen to be compatible
   return keymap.normalize_shared(keymaps) --[[@as any]]
end

---@param keymaps fun(): Util.keymap.KeyMapsAndSharedOpts
---@return fun(self: LazyPlugin, keys: string[]): (string | LazyKeysSpec)[]
function keymap.to_lazyvim_key_extender(keymaps)
   ---@param _ LazyPlugin
   ---@param keys string[]
   ---@return (string | LazyKeysSpec)[]
   local function it(_, keys)
      return libs.r.lang.try_catch(
         ---@return unknown
         function()
            return vim.list_extend(keys, keymap.to_lazyvim_keys(keymaps()))
         end,
         ---@return unknown
         function(err)
            libs.r.log.dbgv("error", err, keys)
            return {}
         end
      )
   end
   -- HACK: Type checker is stupid
   return it --[[@as any]]
end

return keymap
