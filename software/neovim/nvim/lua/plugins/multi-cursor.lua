local autolib = require("util.autolib")

return {
   "jake-stewart/multicursor.nvim",
   branch = "1.0",
   opts = {},
   lazy = true,

   -- TODO: Try to register layer without config
   config = function(_, opts)
      autolib.multicursor.setup(opts)
      autolib.lang.dbg_err(function()
         autolib.configured_keymaps.set_multicursor_layer()
      end)
   end,

   keys = autolib.lang.dbg_err(
      ---@return unknown
      function()
         return autolib.keymap.to_lazyvim_key_extender(autolib.configured_keymaps.get_multicursor_globals)
      end
   ),
}
