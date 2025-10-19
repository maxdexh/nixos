local M = {}

---@alias Util.log.Level "error" | "warn" | "info" | "debug" | "trace" | "off"
---@class (partial) PluginLspOpts2: PluginLspOpts

---@generic T
---@param level Util.log.Level
---@param ... T...
---@return T...
function M.dbgv(level, ...)
   local str_args = {}
   for i = 1, select("#", ...) do
      local x = select(i, ...)
      if type(x) == "string" then
         str_args[i] = x
      else
         str_args[i] = vim.inspect(x)
      end
   end
   local message = table.concat(str_args, "\n")
   vim.notify(message, level --[[@as any]])

   return ...
end

---@generic T
---@param value T
---@param level? Util.log.Level
---@return T
function M.dbg(value, level)
   return M.dbgv(level or "info", value)
end

---@generic R
---@param try fun(): R...
---@param level? Util.log.Level
---@return R...
---@overload fun(try: fun(), level?: Util.log.Level)
function M.dbg_err(try, level)
   local status, ret = pcall(try)
   if status then
      return ret
   else
      M.dbg(ret, level or "error")
   end
end

---@param overrides table<string, vim.api.keyset.highlight>
function M.add_auto_hl_overrides(overrides)
   local function apply()
      for key, value in pairs(overrides) do
         M.dbg_err(function()
            vim.api.nvim_set_hl(0, key, value)
         end)
      end
   end

   apply()
   vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = apply,
   })
end

---@generic K, T
---@param t T
---@param key std.ConstTpl<K>
---@return std.RawGet<T, K>
function M.pop_key(t, key)
   local val = t[key]
   t[key] = nil
   return val
end

---@generic T
---@param f fun(): T
---@return fun(): T
function M.store_lazily(f)
   local value ---@type any

   return function()
      if f ~= nil then
         value = f()
         f = nil --[[@as any]]
      end
      return value
   end
end

return M
