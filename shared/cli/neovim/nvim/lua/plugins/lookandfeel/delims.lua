return {
   {
      "nvim-mini/mini.pairs", -- installed in lazyvim by default
      enabled = false,
   },
   {
      "HiPhish/rainbow-delimiters.nvim",
      -- enabled = false,
      submodules = false,
      priority = 1999,
      init = function()
         vim.g.rainbow_delimiters = {
            highlight = {
               "RainbowDelimiterYellow",
               "RainbowDelimiterRed",
               "RainbowDelimiterBlue",
            },
            query = {
               [""] = "rainbow-delimiters",
               lua = "rainbow-blocks",
            },
         }
      end,
   },
   {
      "windwp/nvim-autopairs",
      -- enabled = false,
      lazy = true,
      event = "InsertEnter",
      opts = {},
   },
   {
      "saghen/blink.pairs",
      enabled = false,
      version = "*",
      dependencies = "saghen/blink.download",
      --- @type blink.pairs.Config
      opts = {
         mappings = {
            enabled = true,
            cmdline = false,
            disabled_filetypes = {},
            -- see the defaults:
            -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
            pairs = {},
         },
         highlights = {
            enabled = true,
            -- requires require('vim._extui').enable({}), otherwise has no effect
            cmdline = true,
            groups = {
               "RainbowDelimiterYellow",
               "RainbowDelimiterRed",
               "RainbowDelimiterBlue",
            },
            unmatched_group = "BlinkPairsUnmatched",

            -- highlights matching pairs under the cursor
            matchparen = {
               enabled = true,
               -- known issue where typing won't update matchparen highlight, disabled by default
               cmdline = false,
               -- also include pairs not on top of the cursor, but surrounding the cursor
               include_surrounding = true,
               group = "BlinkPairsMatchParen",
               priority = 250,
            },
         },
         debug = false,
      },
   },
}
