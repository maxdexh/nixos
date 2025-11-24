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
