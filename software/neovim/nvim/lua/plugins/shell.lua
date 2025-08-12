libs = require("util.libs")

libs.r.nvim.set_ft_tabwidth("fish", 4)

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
   {
      "nvim-treesitter/nvim-treesitter",
      opts = {
         ensure_installed = {
            "bash",
            "fish",
         },
      },
   },
}
