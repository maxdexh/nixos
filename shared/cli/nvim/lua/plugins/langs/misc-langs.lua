vim.api.nvim_create_autocmd("FileType", {
   pattern = "xml",
   callback = function()
      vim.o.shiftwidth = 4
      vim.o.tabstop = 4
   end,
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         -- NOTE: requires npm
         servers = {
            bashls = {},
            jsonls = {},
            yamlls = {},
         },
         -- FIXME: This doesn't belong here
         inlay_hints = {
            enabled = false,
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "xmlformatter" },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            xml = { "xmlformatter" },
         },
      },
   },
}
