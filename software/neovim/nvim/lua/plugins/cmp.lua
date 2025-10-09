return {
   {
      "saghen/blink.cmp",
      dependencies = {
         "moyiz/blink-emoji.nvim",
         "Kaiser-Yang/blink-cmp-dictionary",
      },
      opts = {
         completion = {
            menu = {
               border = "single",
            },
            documentation = {
               auto_show = true,
               window = {
                  border = "single",
               },
            },
            list = {
               selection = {
                  auto_insert = false,
               },
            },
         },

         fuzzy = {
            implementation = "prefer_rust_with_warning",
            sorts = {
               "exact",
               "score",
               "sort_text",
            },
         },

         signature = { enabled = true },

         keymap = {
            preset = "default",
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },

            ["<S-k>"] = { "scroll_documentation_up", "fallback" },
            ["<S-j>"] = { "scroll_documentation_down", "fallback" },

            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
         },
      },
   },
}
