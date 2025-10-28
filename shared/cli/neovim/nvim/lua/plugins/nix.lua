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
            nil_ls = {},
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "nil", "alejandra" }, -- NOTE: This might require installing a rust toolchain first
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
