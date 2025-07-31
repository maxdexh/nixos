-- See :LazyExtras, vim.g.lazyvim_rust_diagnostics in options.lua
return {
   {
      "mrcjkb/rustaceanvim",
      lazy = true, -- Lazy by design my ass, takes 20ms
      event = "VeryLazy",
      init = function()
         vim.g.rustaceanvim = {}
      end,
   },
   {
      "nvim-treesitter/nvim-treesitter",
      opts = {
         ensure_installed = {
            "rust",
         },
      },
   },
}
