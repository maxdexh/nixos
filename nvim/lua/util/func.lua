local func = {}

---Composes functions in reverse
---
---@generic T, U, V
---@param f fun(...: T...): (U...)
---@param g fun(...: U...): (V...)
---@return fun(...: T...): (V...)
function func.rcompose(f, g)
   return func.compose(g, f)
end

---@generic A, B, R
---@param f fun(...: (A...), ...: (B...)): (R...)
---@param ... (A...)
---@return fun(...: (B...)): (R...)
function func.partial(f, ...)
   ---@type [A...]
   local outer = { ... }
   local len = select("#", ...)

   return function(...)
      return f(unpack(outer, 1, len), ...)
   end
end

---@generic F: function
---@param f F
---@return F
function func.from_callable(f)
   return function(...)
      return f(...)
   end
end

---Composes functions
---
---@generic T, U, V
---@param f fun(...: U...): (V...)
---@param g fun(...: T...): (U...)
---@return fun(...: T...): (V...)
function func.compose(f, g)
   return function()
      return f(g())
   end
end

---Spy on method
---
---@generic K
---@param obj table<K, function>
---@param k K
---@param f? function
function func.spy(obj, k, f)
   f = f or vim.print
   local cb = obj[k]
   obj[k] = function(...)
      f(...)
      cb(...)
   end
end

func.cmds = setmetatable({}, {
   __index = function(_, name)
      return function()
         vim.cmd(name)
      end
   end,
})

return func
