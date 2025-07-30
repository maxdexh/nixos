-- See :LazyExtras
return {
   {
      "neovim/nvim-lspconfig",
      ---@class (partial) PluginLspOpts
      opts = {
         inlay_hints = {
            enabled = false,
         },
         servers = {
            clangd = {
               filetypes = { "c", "cpp", "h" },
            },
         },
      },
      {
         "nvim-treesitter/nvim-treesitter",
         opts = {
            ensure_installed = {
               "c",
               "cpp",
            },
         },
      },
   },
}
