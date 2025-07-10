-- See :LazyExtras, vim.g.lazyvim_rust_diagnostics in options.lua
return {
   {
      "mrcjkb/rustaceanvim",
      lazy = false,
      init = function()
         vim.g.rustaceanvim = {}
      end,
   },
}
