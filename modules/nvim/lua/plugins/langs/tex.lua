return {
   {
      "lervag/vimtex",
      init = function()
         vim.g.vimtex_syntax_enabled = 0 -- Use treesitter instead

         vim.g.tex_flavor = "latex"

         -- vim.g.vimtex_view_method = "zathura"
         vim.g.vimtex_view_method = "general"
         vim.g.vimtex_view_general_viewer = "kitty"
         vim.g.vimtex_view_general_options = "tdf --reload-delay 1000 @pdf"
      end,
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            tex = { "latexindent" },
         },
      },
   },
}
