local autolib = require("util.autolib")

return {
   "stevearc/oil.nvim",
   ---@module 'oil'
   ---@type oil.SetupOpts
   opts = {
      default_file_explorer = true,
      buf_options = {
         buflisted = false,
      },
      delete_to_trash = true,
      -- skip_confirm_for_simple_edits = true,

      prompt_save_on_select_new_entry = true, -- default
   },

   -- needed for default_file_explorer to work
   lazy = false,

   keys = function(_, keys)
      local setter = autolib.keymap.lazy_keys_spec_setter(keys)
      autolib.keymap.set_many({
         setter = setter,
         {
            "<leader>fE",
            autolib.keymap.cmdfunc("Oil"),
            desc = "File Browser (nonfloat)",
         },
         {
            "<leader>fe",
            autolib.keymap.cmdfunc("Oil --float"),
            desc = "File Browser (current buffer dir)",
         },
      })
      return keys
   end,
}
