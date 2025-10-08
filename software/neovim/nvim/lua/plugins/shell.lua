autolib = require("util.autolib")

-- TODO: Is there a better way to do this?
vim.api.nvim_create_autocmd("FileType", {
   pattern = "fish",
   command = "setlocal shiftwidth=4 tabstop=4",
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            bashls = {
               filetypes = { "sh", "zsh", "bash" },
            },
            fish_lsp = {},
         },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            zsh = { "shfmt" },
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "fish-lsp" },
      },
   },
}
