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
      "nvim-treesitter/nvim-treesitter",
      opts = {
         ensure_installed = {
            "nix",
         },
      },
   },
   {
      "calops/hmts.nvim",
      version = "*",
   },
}
