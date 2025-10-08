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

   lazy = false,
   keys = autolib.keymap.to_lazyvim_key_extender(
      ---@return Util.keymap.KeyOpts[]
      function()
         return {
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
         }
      end
   ),
}
