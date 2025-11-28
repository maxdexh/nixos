local libs = require("util.libs")

return {
   {
      "tpope/vim-fugitive",
   },
   {
      -- for log/graph
      -- TODO: Binds
      "NeogitOrg/neogit",
      opts = {
         graph_style = "kitty",
      },
   },
   {
      "lewis6991/gitsigns.nvim",
      init = function()
         -- TODO: Bind hunk staging, etc.
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
