local libs = require("util.libs")

local tbl = {}

---@generic T: table
---@param strict Util.DuplicateKeyBehavior
---@param ... T
---@return T
---@see vim.tbl_extend DOES NOT HAVE THE SAME SEMANTICS
---@overload fun(strict: Util.DuplicateKeyBehavior): {}
function tbl.merge(strict, ...)
   local ret = {}
   for i = 1, select("#", ...) do
      tbl.set_all(ret, select(i, ...), strict)
   end
   return ret
end

---@generic K, V
---@param obj { [K]: V }
---@param k K
---@param v V
---@param strict? Util.DuplicateKeyBehavior
function tbl.set(obj, k, v, strict)
   if obj[k] ~= nil and obj[k] ~= v then
      if strict == "keep" then
         return
      elseif strict ~= nil and strict ~= "default" then
         ---@cast strict Util.log.Level
         libs.r.log.dbg("Duplicate Key: \n" .. vim.inspect({ [k] = v }), strict)
      end
   end
   obj[k] = v
end

---@generic T: table
---@param dst T
---@param src T
---@param strict? Util.DuplicateKeyBehavior
---@return T
function tbl.set_all(dst, src, strict)
   for k, v in pairs(src) do
      tbl.set(dst, k, v, strict)
   end
   return dst
end

---@generic K, V, R
---@param t table<K, V>
---@param f fun(val: V, key: K): R?
---@return table<K, R>
function tbl.map_vals(t, f)
   local dst = {}
   for k, v in pairs(t) do
      dst[k] = f(v, k)
   end
   return dst
end

---@generic K, V
---@param t { [K]: V }
---@param f fun(val: V, key: K): any
---@return table<K, V>
function tbl.filter(t, f)
   local dst = {}
   for k, v in pairs(t) do
      if f(k, v) then
         dst[k] = v
      end
   end
   return dst
end

---@generic K, V
---@param t table<K, V>
---@param key K
---@return V
function tbl.pop_key(t, key)
   local val = t[key]
   t[key] = nil
   return val
end

return tbl
