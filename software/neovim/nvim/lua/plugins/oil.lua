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

   -- Laziness not recommended due to trickiness
   -- TODO: Try anyway
   lazy = false,
}
