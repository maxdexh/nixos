-- TODO: https://github.com/nix-community/nixd

vim.lsp.config("nil_ls", {
   cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
   filetypes = { "nix" },
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
   on_init = function(client)
      -- disable all capabilities except the ones not provided by nixd
      do
         local cap = client.capabilities or {}
         local td = cap.textDocument or {}
         -- FIXME: nixd's hover info is bad, try replacing that part with nil_ls?
         client.capabilities = {
            -- nixd doesn't have semantic highlighting
            workspace = {
               semanticTokens = cap.workspace.semanticTokens,
            },
            textDocument = {
               documentHighlight = td.documentHighlight,
               semanticTokens = td.semanticTokens,
            },
         }
      end
      do
         local cap = client.server_capabilities or {}
         client.server_capabilities = {
            semanticTokensProvider = cap.semanticTokensProvider,
            documentHighlightProvider = cap.documentHighlightProvider,
            textDocumentSync = cap.textDocumentSync,
         }
      end
   end,
})

-- TODO: Make nix config declare the name of the current nixos
-- config and hm config directly. If unset, we are not using nixos
local config_name = vim.fn.expand("$NVIM_NIX_HOST_NAME")
local is_nixos = vim.fn.expand("$NVIM_NIX_IS_NIXOS")
local username = vim.fn.expand("$USER")
local flake_expr = "(builtins.getFlake (builtins.toString ./.))"

local nix_options = {
   ["home-manager"] = {
      expr = string.format( --
         '%s.homeConfigurations."%s@%s".options',
         flake_expr,
         username,
         config_name
      ),
   },
}
if is_nixos == "1" then
   nix_options.nixos = {
      expr = string.format( --
         '%s.nixosConfigurations."%s".options',
         flake_expr,
         config_name
      ),
   }
end

-- Do not let nixd load the config while editing e.g. a random shell.nix file somewhere else.
if not vim.startswith(vim.fn.getcwd(), vim.fn.expand("$NIXOS_FLAKE")) then
   nix_options = {}
end

-- NOTE: Installed via nix
vim.lsp.config("nixd", {
   cmd = { "nixd" },
   filetypes = { "nix" },
   settings = {
      nixd = {
         formatting = { command = { "alejandra" } },
         options = nix_options,
      },
   },
})

return {
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            nil_ls = {},
            nixd = {},
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "nil" },
      },
   },
   {
      "calops/hmts.nvim",
      version = "*",
   },
}
