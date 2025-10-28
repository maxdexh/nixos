-- TODO: https://github.com/nix-community/nixd

vim.lsp.config("nil_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
   settings = {
      ["nil"] = {
         diagnostics = {
            ignored = { "let_attrset" },
         },
         nix = {
            flake = {
               autoArchive = false,
            },
         },
      },
   },
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            nil_ls = {}, -- FIXME: deduplicate symbols
            nixd = {},
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         -- NOTE: Requires installing a rust toolchain first on initial system setup
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
