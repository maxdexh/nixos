-- See .luarc.json
vim.fn.setenv("LAZY_LIBRARY_PATH_PREFIX", vim.fn.stdpath("data") .. "/lazy/")

local nvim_config_dir = vim.fn.stdpath("config") --[[@as string]]

-- vim.api.nvim_list_runtime_paths()
local config_locations = {
   vim.fn.stdpath("data") --[[@as string]],
   nvim_config_dir,
   vim.fn.expand("$NIXOS_CONFIG"),
}

---@param path string
---@return boolean
local function is_nvim_config(path)
   for _, cfg_loc in ipairs(config_locations) do
      if vim.startswith(path, cfg_loc) then
         return true
      end
   end
   return false
end

-- https://github.com/EmmyLuaLs/emmylua-analyzer-rust/tree/main/docs
vim.lsp.config("emmylua_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/emmylua_ls" },
   filetypes = { "lua" },
   ---@param bufnr integer
   ---@param on_dir fun(root_dir?:string)
   root_dir = function(bufnr, on_dir)
      if is_nvim_config(vim.fn.getcwd()) or is_nvim_config(vim.api.nvim_buf_get_name(bufnr)) then
         on_dir(nvim_config_dir)
      else
         on_dir()
      end
   end --[[@as any]],
})

vim.lsp.enable("emmylua_ls")

return {
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "emmylua_ls" },
      },
   },
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = { lua_ls = { enabled = false } },
      },
   },
   { "ii14/neorepl.nvim" },
}
