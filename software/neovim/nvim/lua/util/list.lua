local autolib = require("util.autolib")

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

---@generic T, U
---@param f fun(item: T): U[]
---@param lst T[]
---@return U[]
function list.flat_map(f, lst)
   local ret = {}
   for _, t in ipairs(lst) do
      for _, u in ipairs(f(t)) do
         table.insert(ret, u)
      end
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
      autolib.tbl.set(ret, x, e, strict)
   end
   return ret
end

return list
