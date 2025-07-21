local libs = require("util.libs")

return {
   "jake-stewart/multicursor.nvim",
   branch = "1.0",
   opts = {},
   lazy = true,

   -- TODO: Try to register layer without config
   config = function(_, opts)
      libs.r.mc.setup(opts)
      libs.r.lang.dbg_err(function()
         libs.r.configured_keymaps.set_multicursor_layer()
      end)
   end,

   keys = libs.r.lang.dbg_err(
      ---@return unknown
      function()
         return libs.r.keymap.to_lazyvim_key_extender(libs.r.configured_keymaps.get_multicursor_globals)
      end
   ),
}
