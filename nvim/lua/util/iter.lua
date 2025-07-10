local libs = require("util.libs")

---Iterator utility module.
---
---An iterator is any function that takes no args and returns any number of values
---An iterator triple is any multi-value expression that consists of up to three subexpressions, which
---adheres to the type signature necessary to be used in a for loop:
--- ```lua
--- for var_1, ···, var_n in iter_triple do
---   block
--- end
--- ```
--- is syntactic sugar for
--- ```lua
--- do
---   local nxt, state, cond = iter_triple
---   while true do
---     local var_1, ···, var_n = nxt(state, cond)
---     cond = var_1
---     if cond == nil then break end
---     block
---   end
--- end
--- ```
---
--- # Convention
--- The first return value of an iterator function is called its condition, as it controls whether or not
--- the iteration continues.
--- The remaining return values are called its actual values.
---
--- When expecting only a single value per iteration that is allowed to be nil, then this value is
--- expected in the first actual value of the iterator, i.e. its *second* return value.
--- The condition value will be some kind of key if applicable, or alternatively an integer that
--- counts the current iteration.
local iter = {}

---Simplifies an iterator triple by turning it into a regular iterator
---
---@generic State, Cond, T
---@param f fun(state: State, cond: Cond): (Cond|nil, T...)
---@param state? State
---@param cond? Cond
---@return fun(): (Cond|nil, T...)
function iter.simplify(f, state, cond)
   return function()
      ---@type [Cond, T...]
      local vars = { f(state, cond) }
      cond = vars[1]
      return vars
   end
end

---Returns a pairs iterator
---
---@generic K, V
---@param t table<K, V>
---@return fun(): (K|nil, V)
function iter.pairs(t)
   return iter.simplify(pairs(t))
end

---Returns an ipairs iterator
---
---@generic T
---@param t T[]
---@return fun(): (integer|nil, T)
function iter.ipairs(t)
   return iter.simplify(ipairs(t))
end

---Returns a range iterator
---
---@param start_or_end integer
---@param opt_end? integer
---@param step? integer
---@return fun(): (integer|nil)
function iter.range(start_or_end, opt_end, step)
   ---@type integer, integer
   local i, end_
   if opt_end == nil then
      i = 0
      end_ = start_or_end
   else
      i = start_or_end - 1
      end_ = opt_end
   end
   if step == nil then
      step = 1
   end
   return function()
      i = i + 1
      return i <= end_ and i or nil
   end
end

---Iterator over the arguments, including all (even trailing) nils.
---Note that this is different from working with ipairs on `{...}`, as
---ipairs stops at the first nil.
---
---@generic T
---@param ... T...
---@return fun(): (integer|nil, T)
function iter.iargs(...)
   local args = { ... }
   local end_ = select("#", ...)
   local i = 0
   return function()
      i = i + 1
      return i <= end_ and i or nil, args[i]
   end
end

---Enumerates an iterator.
---
---@generic T
---@param it fun(): (T...)
---@return fun(): (integer, T...)
function iter.enumerate(it)
   local i = 0

   local function vararg_helper(...)
      if (...) == nil then
         return nil
      end
      i = i + 1
      return i, ...
   end

   return function()
      return vararg_helper(it())
   end
end

---Maps an iterator. The resulting iterator will stop if the condition of `it`
---or the first return value of `map` is nil.
---As such, the first argument passed to `map` is never nil.
---
---@generic T, U
---@param it fun(): (T...)
---@param map fun(...: T...): (U...)
---@return fun(): (U...)
function iter.direct_map(it, map)
   return iter.force_map(
      it,
      ---@param ... (T...)
      ---@return (U...)
      function(...)
         if (...) == nil then
            return nil
         end
         return map(...)
      end
   )
end

---Maps an iterator. The resulting iterator will only stop when the first
---return value of the map is nil. Note that this means that the original
---iterator might keep being iterated after its condition is nil.
---
---@generic T, U
---@param it fun(): (T...)
---@param map fun(...: T...): (U...)
---@return fun(): (U...)
function iter.force_map(it, map)
   return function()
      return map(it())
   end
end

---Filters a simplified iterator. Items will be skipped if the filter function returns
---a falsy value.
---
---@generic T
---@param it fun(): (T...)
---@param f fun(...: T...): any?
---@return fun(): (T...)
function iter.filter(it, f)
   return function()
      while true do
         local args, len = libs.r.vararg.capture(it())
         if args[1] == nil then
            return nil
            -- TODO: Can this be done with only 1 unpack?
         elseif f(unpack(args, 1, len)) then
            return unpack(args, 1, len)
         end
      end
   end
end

---Calls the function on every value yielded by the iterator.
---This is useful for iterating over varargs.
---
---Trailing `nil`s are preserved.
---
---@generic T
---@param it fun(): (T...)
---@param f fun(...: T...)
function iter.foreach(it, f)
   local function defer(...)
      if (...) ~= nil then
         f(...)
         return true
      else
         return false
      end
   end

   while defer(it()) do
   end
end

---Collects an iterator into a list. Only the second return value is taken from each iteration.
---Note that the returned list has no well-defined length if it includes a non-trailing nil.
---Also returns the number of items that were put into the list (including nils)
---
---@generic T
---@param it fun(): (any?, T)
---@return T[]
---@return integer
function iter.to_val_list(it)
   local l = {}
   local size = 0
   for _, item in it do
      size = size + 1
      l[size] = item
   end
   return l, size
end

---Collects an iterator into a list. Only the condition is taken from each iteration.
---
---@generic T
---@param it fun(): T?
---@return T[]
function iter.to_cond_list(it)
   return (iter.to_val_list(function()
      local item = it()
      return item, item
   end))
end

---Joins stuff like [`table.concat`]. Uses condition.
---
---@generic T
---@param it fun(): string?
---@param sep? string
---@return string
function iter.join(it, sep)
   return table.concat(iter.to_cond_list(it), sep)
end

---Builds a key-value table from the first two return values of each iteration.
---
---@generic K, V
---@param it fun(): (K?, V)
---@return table<K, V>
function iter.to_table(it)
   local t = {}
   for k, v in it do
      t[k] = v
   end
   return t
end

---Turns an iterator into a multi-value expression, similar to [`unpack`].
---Only the first actual value is taken on each iteration. This means that `nil` can be passed.
---
---@generic T
---@param it fun(): any?, T
---@return (T...)
function iter.unpack_vals(it)
   local arr, len = iter.to_val_list(it)
   return unpack(arr, 1, len)
end

---Turns an iterator into a multi-value expression, similar to [`unpack`].
---Only the condition is taken on each iteration. This means that `nil` cannot be passed.
---
---@generic T
---@param it fun(): T?
---@return (T...)
function iter.unpack_conds(it)
   return unpack(iter.to_cond_list(it))
end

return iter
