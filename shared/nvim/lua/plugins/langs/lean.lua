return {
   {
      "Julian/lean.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      lazy = true,
      event = { "BufReadPre *.lean", "BufNewFile *.lean" },

      ---@type lean.Config
      opts = { -- see below for full configuration options
         mappings = true,
         lsp = {
            init_options = {
               editDelay = 1000,
            },
         },
         infoview = {
            autoopen = false, -- :LeanInfoviewToggle (or localleader binds)
         },
      },
   },
}
