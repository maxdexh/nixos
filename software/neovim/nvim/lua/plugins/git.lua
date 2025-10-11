local libs = require("util.libs")

return {
   {
      "tpope/vim-fugitive",
   },
   {
      -- for log/graph
      "NeogitOrg/neogit",
      opts = {
         graph_style = "kitty",
      },
   },
   {
      "lewis6991/gitsigns.nvim",
      init = function()
         libs.keymap.set_many({
            {
               "<leader>gd",
               function()
                  require("gitsigns").toggle_deleted()
               end,
               desc = "Toggle deleted (gitsigns)",
            },
         })
      end,
   },
}
