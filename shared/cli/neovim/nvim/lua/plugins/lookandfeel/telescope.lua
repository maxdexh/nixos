local libs = require("util.libs")

return {
   {
      "nvim-telescope/telescope.nvim",
      dependencies = {
         "nvim-telescope/telescope-frecency.nvim",
         "nvim-telescope/telescope-live-grep-args.nvim",
      },
      opts = {},
      extensions = {
         live_grep_args = {},
         frecency = {},
      },
      keys = function(_, keys)
         libs.keymap.set_many({
            setter = libs.keymap.lazy_spec_setter(keys),
            {
               "<leader>sG",
               function()
                  require("telescope").extensions.live_grep_args.live_grep_args()
               end,
               desc = "Live Grep (Args)",
            },
            {
               "<leader>sx",
               libs.keymap.cmd("Telescope resume"),
               desc = "Resume telescope",
            },
            {
               "<leader>ff",
               libs.keymap.cmd("Telescope find_files"), -- LazyVim.pick("files", { root = false })
               desc = "Find Files (cwd)",
            },
            {
               "<leader>fF",
               LazyVim.pick("files"), -- TODO: How does lazyvim find root dir?
               desc = "Find Files (Root Dir)",
            },
         })
         return keys
      end,
   },
}
