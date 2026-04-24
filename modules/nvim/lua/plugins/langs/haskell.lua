return {
   {
      "mrcjkb/haskell-tools.nvim",
      version = "^9",
   },
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            hls = {
               mason = false,
            },
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "ormolu" },
      },
   },
}
