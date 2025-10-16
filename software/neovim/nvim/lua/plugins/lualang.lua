-- See .luarc.json
vim.fn.setenv("LAZY_LIBRARY_PATH_PREFIX", vim.fn.stdpath("data") .. "/lazy/")

-- https://github.com/EmmyLuaLs/emmylua-analyzer-rust/tree/main/docs
vim.lsp.config("emmylua_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/emmylua_ls" },
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
