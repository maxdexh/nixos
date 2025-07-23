local libs = require("util.libs")

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
      keys = libs.r.lang.dbg_err(
         ---@return unknown
         function()
            return libs.r.keymap.to_lazyvim_key_extender(libs.r.configured_keymaps.get_telescope_bindings)
         end
      ),
   },
   {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
   },
}
