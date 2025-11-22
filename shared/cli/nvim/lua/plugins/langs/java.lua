vim.api.nvim_create_autocmd("FileType", {
   pattern = "java",
   callback = function()
      vim.o.shiftwidth = 4
      vim.o.tabstop = 4
   end,
})

vim.lsp.config("jdtls", {
   settings = {
      java = {
         format = {},
      },
   },
})

return {
   {
      "nvim-java/nvim-java",
      lazy = true,
      event = "BufRead java",
      opts = {},
   },
   {
      "folke/neoconf.nvim",
      lazy = false,
      opts = {},
   },
}
