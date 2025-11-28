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
         eclipse = { downloadSources = true },
         maven = { downloadSources = true },
      },
   },
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
      -- NOTE: this has stuff to make downloadSources work, it didn't with nvim-java
      "mfussenegger/nvim-jdtls",
      lazy = true,
      event = { "BufReadPre *.java", "BufNewFile *.java" },
   },
}
