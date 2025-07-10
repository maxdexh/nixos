local libs = require("util.libs")

vim.fn.setenv("LAZY_LIBRARY_PATH_PREFIX", vim.fn.stdpath("data") .. "/lazy/")
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
         servers = {
            lua_ls = {
               enabled = false,
            },
         },
      },
   },
}
