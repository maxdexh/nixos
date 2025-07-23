return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            bashls = {
               filetypes = { "sh", "zsh", "bash" },
            },
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
}
