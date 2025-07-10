local libs = require("util.libs")

local lang = {}

---@generic R
---@param try fun(): (R...)
---@param catch fun(err: unknown): (R...)
---@return (R...)
function lang.try_catch(try, catch)
   local status, ret = pcall(try)
   if status then
      return ret
   else
      return catch(ret)
   end
end

---@generic R
---@param try fun(): (R...)
---@param level? Util.log.Level
---@return (R...)
---@overload fun(try: fun(), level?: Util.log.Level)
function lang.dbg_err(try, level)
   return lang.try_catch(
      try,
      ---@return unknown
      function(err)
         libs.r.log.dbg(err, level or "error")
         return nil
      end
   )
end

---@param overrides table<string, vim.api.keyset.highlight>
function lang.add_auto_hl_overrides(overrides)
   local function apply()
      for key, value in pairs(overrides) do
         lang.dbg_err(function()
            vim.api.nvim_set_hl(0, key, value)
         end)
      end
   end

   apply()
   vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_colors", {}),
      callback = apply,
   })
end

--FIXME: Why does the LSP sometimes not attach itself?

---@param name string
---@param buf? integer
function lang.attach_client(name, buf)
   buf = buf or 0
   for _, client in ipairs(vim.lsp.get_clients()) do
      if client.name == name then
         vim.lsp.buf_attach_client(buf, client.id)
         return
      end
   end
   libs.r.log.dbg("Not found", "warn")
end

return lang
