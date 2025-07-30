vim.lsp.config("nil_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
})

return {
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "nil", "nixfmt" },
      },
   },
   {
      "stevearc/conform.nvim",
      opts = {
         formatters_by_ft = {
            nix = { "nixfmt" },
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
