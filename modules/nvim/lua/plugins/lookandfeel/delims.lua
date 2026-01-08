return {
   {
      "nvim-mini/mini.pairs", -- installed in lazyvim by default
      enabled = false,
   },
   {
      "HiPhish/rainbow-delimiters.nvim",
      submodules = false,
      lazy = false,
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
      lazy = false,
      --event = "InsertEnter",
      opts = {},
   },
}
