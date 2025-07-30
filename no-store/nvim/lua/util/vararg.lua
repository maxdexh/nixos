local vararg = {}

---Captures a multi-value expression and its length.
---Useful for handling return values of functions losslessly.
---Use `unpack(list, 1, len)` to restore the original multi-value expression losslessly.
---
---@generic T
---@param ... (T...)
---@return [T...]
---@return integer
function vararg.capture(...)
   return { ... }, select("#", ...)
end

return vararg
