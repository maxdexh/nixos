local libs = require("util.libs")

local get_dap = libs.misc.store_lazily(function()
   return require("dap")
end)

-- TODO: https://www.johntobin.ie/blog/debugging_in_neovim_with_nvim-dap/
return {
   {
      "mfussenegger/nvim-dap",
      dependencies = {
         {
            "mason.nvim",
            opts = { ensure_installed = { "codelldb" } },
         },
      },
      lazy = true,
      config = function()
         local dap = get_dap()
         dap.adapters.codelldb = {
            type = "server",
            host = "127.0.0.1",
            port = 13000,
            executable = {
               command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
               args = { "--port", "13000" },
            },
         }

         require("nvim-dap-virtual-text") -- make sure it gets loaded
      end,
      keys = {
         {
            "<leader>db",
            function()
               get_dap().toggle_breakpoint()
            end,
            mode = "n",
         },
         {
            "<leader>dc",
            function()
               get_dap().run_to_cursor()
            end,
            mode = "n",
         },
      },
   },
   {
      "theHamsta/nvim-dap-virtual-text",
      lazy = true,
      config = true,
   },
   {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      lazy = true,
      config = true,
      keys = {
         {
            "<leader>du",
            function()
               require("dapui").toggle({})
            end,
            desc = "Dap UI",
         },
      },
   },
}
