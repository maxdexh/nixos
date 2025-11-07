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
      "mason-org/mason-lspconfig.nvim",
      opts = {
         -- by default, mason-lspconfig automatically enables servers installed via mason,
         -- which is non-declared state, leading to lsps getting enabled for seemingly no reason
         -- FIXME: This doesn't prevent that from happening...
         automatic_enable = false,
      },
   },
}
