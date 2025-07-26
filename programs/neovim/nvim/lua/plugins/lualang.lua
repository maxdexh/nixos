vim.fn.setenv("LAZY_LIBRARY_PATH_PREFIX", vim.fn.stdpath("data") .. "/lazy/")
-- FIXME: emmylua_ls randomly creates a folder named "" containing the standard library ??
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
         servers = {
            lua_ls = {
               enabled = false,
            },
         },
      },
   },
}
