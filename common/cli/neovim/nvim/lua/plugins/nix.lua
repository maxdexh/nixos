vim.lsp.config("nil_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
})

return {
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "nil", "alejandra" },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            nix = { "alejandra" },
         },
      },
   },
   {
      "calops/hmts.nvim",
      version = "*",
   },
}
