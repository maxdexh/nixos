vim.api.nvim_create_autocmd("FileType", {
   pattern = "hyprlang",
   callback = function()
      vim.o.shiftwidth = 4
      vim.o.tabstop = 4
   end,
})

return {}
