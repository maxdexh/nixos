local nvim = {}

function nvim.set_ft_tabwidth(ft, width)
   vim.api.nvim_create_autocmd("FileType", {
      pattern = ft,
      command = "setlocal shiftwidth=" .. width .. " tabstop=" .. width,
   })
end

return nvim
