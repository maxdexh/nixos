local libs = require("util.libs")

local cmds = libs.r.func.cmds

local function notebook_dir()
   local path = vim.fn.stdpath("cache") .. "/jupynium-notebooks"
   return path
end

return {
   {
      "neovim/nvim-lspconfig",
      ---@class (partial) PluginLspOpts
      opts = {
         inlay_hints = {
            enabled = false,
         },
         -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
         servers = {

            basedpyright = {
               settings = {
                  basedpyright = {
                     disableOrganizeImports = true, -- Using Ruff
                     analysis = {
                        ignore = { "*" }, -- Using Ruff
                        typeCheckingMode = "off", -- using mypy
                     },
                  },
               },
            },
            ruff = {},
         },
      },
   },
   {
      "mason.nvim",
      opts = {
         ensure_installed = {
            "ruff",
            "basedpyright",
         },
      },
   },
   {
      "nvimtools/none-ls.nvim",
      opts = function(_, opts)
         opts.sources = {
            libs.r.nls.builtins.diagnostics.mypy,
         }
         opts.should_attach = function(bufnr)
            return vim.api.nvim_buf_get_name(bufnr):match(".py$")
         end
      end,
   },
}
