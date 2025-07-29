log = {}

---@generic T
---@param level Util.log.Level
---@param ... T...
---@return T...
function log.dbgv(level, ...)
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
function log.dbg(value, level)
   return log.dbgv(level or "info", value)
end

return log
