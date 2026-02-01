vim.lsp.enable("tinymist")

vim.api.nvim_create_autocmd("FileType", {
   pattern = "typst",
   callback = function()
      vim.o.wrap = false
   end,
})

return {
   {
      "chomosuke/typst-preview.nvim",
      lazy = true,
      ft = "typst",
      opts = {},
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "tinymist", "typstyle" },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            typst = { "typstyle" },
         },
      },
   },
}
