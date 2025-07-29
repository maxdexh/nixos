local libs = require("util.libs")

local list = {}

---@generic T, U
---@param lst T[]
---@param f fun(item: T): U
---@return U[]
function list.map(lst, f)
   local ret = {}
   for _, v in ipairs(lst) do
      table.insert(ret, f(v))
   end
   return ret
end

---@generic K, V
---@param lst K[]
---@param entry fun(item: K, idx: integer): V
---@param strict? Util.DuplicateKeyBehavior
---@return table<K, V>
function list.associate(lst, entry, strict)
   local ret = {}
   for i, x in ipairs(lst) do
      local e = entry(x, i)
      libs.r.tbl.set(ret, x, e, strict)
   end
   return ret
end

---@generic T
---@param ... T[]
---@return T[]
function list.concat(...)
   local ret = {}
   for i = 1, select("#", ...) do
      for _, item in ipairs(select(i, ...)) do
         table.insert(ret, item)
      end
   end
   return ret
end

return list
