return {
   {
      "Julian/lean.nvim",
      lazy = true,
      event = { "BufReadPre *.lean", "BufNewFile *.lean" },

      ---@type lean.Config
      opts = { -- see below for full configuration options
         mappings = true,
      },
   },
}
