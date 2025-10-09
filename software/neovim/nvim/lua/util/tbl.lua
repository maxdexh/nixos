-- https://github.com/EmmyLuaLs/emmylua-analyzer-rust/tree/4c50b71fdc46fc68b41af87187f14494caf0635a/docs/emmylua_doc/annotations_EN

local autolib = require("util.autolib")

local tbl = {}

---@generic T: table
---@param strict Util.DuplicateKeyBehavior
---@param ... T
---@return T
---@see vim.tbl_extend
---@overload fun(strict: Util.DuplicateKeyBehavior): {}
function tbl.merge_args(strict, ...)
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
         autolib.misc.dbg("Duplicate Key: \n" .. vim.inspect({ [k] = v }), strict)
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

---@generic K, T
---@param t T
---@param key std.ConstTpl<K>
---@return std.RawGet<T, K>
function tbl.pop_key(t, key)
   local val = t[key]
   t[key] = nil
   return val
end

---@generic K, V
---@param lst K[]
---@param entry fun(item: K, idx: integer): V?
---@param strict? Util.DuplicateKeyBehavior
---@return table<K, V>
function tbl.associate_list(lst, entry, strict)
   local ret = {}
   for i, x in ipairs(lst) do
      local e = entry(x, i)
      autolib.tbl.set(ret, x, e, strict)
   end
   return ret
end

return tbl
