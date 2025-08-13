-- See :LazyExtras, vim.g.lazyvim_rust_diagnostics in options.lua
return {
   {
      "mrcjkb/rustaceanvim",
      lazy = true, -- Lazy by design my ass, takes 20ms
      event = "VeryLazy",
      init = function()
         vim.g.rustaceanvim = {
            server = {
               default_settings = {
                  ["rust-analyzer"] = {
                     assist = {
                        preferSelf = true,
                     },
                     completion = {
                        autoIter = { enable = false },
                        autoself = { enable = false },
                     },
                  },
               },
            },
         }
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
