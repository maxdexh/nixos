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
      keys = function(_, keys)
         local setter = autolib.keymap.lazy_keys_spec_setter(keys)

         autolib.keymap.set_many({
            setter = setter,
            {
               "<leader>sG",
               function()
                  autolib.tscope.extensions.live_grep_args.live_grep_args()
               end,
               desc = "Live Grep (Args)",
            },
            {
               "<leader>sx",
               function()
                  autolib.tscope_funcs.resume()
               end,
               desc = "Resume telescope",
            },
            {
               "<leader>ff",
               autolib.keymap.cmdfunc("Telescope find_files"), -- LazyVim.pick("files", { root = false })
               desc = "Find Files (cwd)",
            },
            {
               -- TODO: How does lazyvim find root dir?
               "<leader>fF",
               LazyVim.pick("files"),
               desc = "Find Files (Root Dir)",
            },
         })
      end,
   },
   {
      "nvim-neo-tree/neo-tree.nvim",
      enabled = false,
   },
}
