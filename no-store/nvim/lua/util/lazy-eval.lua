-- WARN: This module is imported by util.libs

local lazy_eval = {}

---Returns a readonly proxy for the entries for the table returned by the given function.
---Only __index is deferred. The function is only once, when the first entry is requested/set.
---
---@generic T: table
---@param construct fun(): T
---@return T
function lazy_eval.by(construct)
   return setmetatable({}, {
      ---@return unknown
      __index = function(self, key)
         debug.setmetatable(self, {
            index = construct(),
         })
         return self[key]
      end,
   })
end

---@param mod string
function lazy_eval.lazy_require(mod)
   return lazy_eval.by(function()
      return require(mod)
   end)
end

local function lazy_function(func_get)
   local function flatten(self)
      local func = func_get()
      setmetatable(self, {
         __index = func,
         __call = function(_, ...)
            func(...)
         end,
      })
   end
   return setmetatable({}, {
      __index = function(self, key)
         ---@return unknown
         return lazy_function(function()
            flatten(self)
            return self[key]
         end)
      end,
      ---@return unknown
      __call = function(self, ...)
         flatten(self)
         return self(...)
      end,
   })
end

---@param mod string
function lazy_eval.lazy_require_funcs(mod)
   return lazy_function(function()
      return require(mod)
   end)
end

---@generic T: table
---@param _fake_table T
---@param getter fun(key: string): any
---@return T
function lazy_eval.table(_fake_table, getter)
   return setmetatable({}, {
      ---@return unknown
      __index = function(self, key)
         rawset(self, key, getter(key))
         return self[key]
      end,
   })
end

return lazy_eval
