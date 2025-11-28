local libs = require("util.libs")

return {
   {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
   },
   {
      "folke/snacks.nvim",
      keys = function(_, keys)
         local setter = libs.keymap.lazy_spec_setter(keys)
         libs.keymap.set_many({
            setter = setter,
            {
               "<leader>ft",
               function()
                  Snacks.picker.explorer()
               end,
               desc = "File tree",
            },
         })
      end,
   },
   {
      "stevearc/oil.nvim",
      ---@type oil.SetupOpts
      opts = {
         default_file_explorer = true,
         buf_options = {
            buflisted = false,
         },
         -- NOTE: If they change the defaults again, this was a known good point:
         -- https://github.com/stevearc/oil.nvim/tree/abbfbd0dbcaa78c3dcdada191ea23e50a41e5806
         float = {
            border = "rounded",
         },
         delete_to_trash = true,
         skip_confirm_for_simple_edits = true,

         prompt_save_on_select_new_entry = true, -- default
      },

      -- needed for default_file_explorer to work
      lazy = false,

      keys = function(_, keys)
         local setter = libs.keymap.lazy_spec_setter(keys)
         libs.keymap.set_many({
            setter = setter,
            {
               "<leader>fE",
               libs.keymap.cmd("Oil"),
               desc = "Oil (Buffer)",
            },
            {
               "<leader>fe",
               libs.keymap.cmd("Oil --float"),
               desc = "Oil (Float)",
            },
         })
         return keys
      end,
   },
}
