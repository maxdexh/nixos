-- See :LazyExtras
return {
   {
      "lervag/vimtex",
      init = function()
         vim.g.vimtex_view_method = "zathura"
         vim.g.tex_flavor = "latex"
         vim.g.vimtex_syntax_enabled = 0
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
