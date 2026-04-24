-- See :LazyExtras
return {
   {
      "neovim/nvim-lspconfig",
      ---@class (partial) PluginLspOpts2
      opts = {
         inlay_hints = {
            enabled = false,
         },
         servers = {
            clangd = {
               cmd = { "clangd", "--query-driver=/nix/store/*/bin/*" },
               filetypes = { "c", "cpp", "h" },
            },
         },
      },
   },
}
