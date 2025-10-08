local autolib = require("util.autolib")

return {
   {
      "nvim-telescope/telescope.nvim",
      dependencies = {
         "nvim-telescope/telescope-frecency.nvim",
         "nvim-telescope/telescope-file-browser.nvim",
         "nvim-telescope/telescope-live-grep-args.nvim",
      },
      opts = {},
      extensions = {
         file_browser = {
            quiet = true,
         },
         live_grep_args = {},
         frecency = {},
      },
      keys = autolib.lang.dbg_err(
         ---@return unknown
         function()
            return autolib.keymap.to_lazyvim_key_extender(autolib.configured_keymaps.get_telescope_bindings)
         end
      ),
   },
   {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
   },
}
