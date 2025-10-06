-- See :LazyExtras, vim.g.lazyvim_rust_diagnostics in options.lua
return {
   {
      "mrcjkb/rustaceanvim",
      lazy = true, -- Lazy by design my ass, takes 20ms
      ft = { "rust", "toml" },
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
}
