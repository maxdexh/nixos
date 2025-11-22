vim.api.nvim_create_autocmd("FileType", {
   pattern = "java",
   callback = function()
      vim.o.shiftwidth = 4
      vim.o.tabstop = 4
   end,
})

vim.lsp.config("jdtls", {
   root_markers = { "pom.xml" },
   -- https://www.reddit.com/r/neovim/comments/1jbzqp5/comment/mi4ox6v/
   handlers = {
      ["$/progress"] = function(err, result, ctx)
         local msg = result.value.message
         if msg and msg:sub(1, 18) == "Validate documents" then
            return
         end
         if msg and msg:sub(1, 19) == "Publish Diagnostics" then
            return
         end
         -- pass through to normal handler
         vim.lsp.handlers["$/progress"](err, result, ctx)
      end,
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
