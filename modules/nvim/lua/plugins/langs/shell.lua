vim.api.nvim_create_autocmd("FileType", {
   pattern = "fish",
   callback = function()
      vim.o.shiftwidth = 4
      vim.o.tabstop = 4
   end,
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            bashls = {
               filetypes = { "sh", "zsh", "bash" },
            },
            fish_lsp = {},
         },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            zsh = { "shfmt" },
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "fish-lsp" },
      },
   },
}
