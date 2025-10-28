-- TODO: https://github.com/nix-community/nixd

-- vim.lsp.config("nil_ls", {
--    cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
--    settings = {
--       ["nil"] = {
--          diagnostics = {
--             ignored = { "let_attrset" },
--          },
--          nix = {
--             flake = {
--                autoArchive = false,
--             },
--          },
--       },
--    },
-- })

local config_name = vim.fn.expand("$NVIM_NIX_HOST_NAME")
local hm_is_standalone = vim.fn.expand("$NVIM_NIX_HM_STANDALONE")
local is_nixos = vim.fn.expand("$NVIM_NIX_IS_NIXOS")

local nix_options = {
   ["home-manager"] = {
      expr = hm_is_standalone == "true"
            and ("(builtins.getFlake (builtins.toString ./.)).homeConfigurations." .. config_name .. ".options")
         or (
            "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations."
            .. config_name
            .. ".options.home-manager.users.type.getSubOptions []"
         ),
   },
}
if is_nixos == "true" then
   nix_options.nixos =
      { expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations." .. config_name .. ".options" }
end

vim.lsp.config("nixd", {
   cmd = { "nixd" },
   settings = {
      nixd = {
         formatting = { command = {} },
         options = nix_options,
      },
   },
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            -- FIXME: https://www.google.com/search?q=nvim%20set%20lsp%20capabilities
            -- nil_ls = {},
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
