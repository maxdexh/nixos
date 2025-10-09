local M = {}

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
   message = table.concat(str_args, "\n")
   if level == "hard-error" then
      error(message)
   else
      vim.notify(
         message,
         ---@diagnostic disable-next-line: param-type-not-match
         level
      )
   end

   return ...
end

---@generic T
---@param value T
---@param level? Util.log.Level
---@return T
function M.dbg(value, level)
   return log.dbgv(level or "info", value)
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

return M
