local libs = require("util.libs")

return {
   "stevearc/oil.nvim",
   ---@type oil.SetupOpts
   opts = {
      default_file_explorer = true,
      buf_options = {
         buflisted = false,
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
            desc = "File Browser (nonfloat)",
         },
         {
            "<leader>fe",
            libs.keymap.cmd("Oil --float"),
            desc = "File Browser (current buffer dir)",
         },
      })
      return keys
   end,
}
