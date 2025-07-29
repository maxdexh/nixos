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
   },
}
