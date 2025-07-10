-- https://www.lazyvim.org/plugins/formatting
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
}
