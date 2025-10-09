local autolib = require("util.autolib")

return {
   "jake-stewart/multicursor.nvim",
   branch = "1.0",
   opts = {},
   lazy = true,

   -- TODO: Try to register layer without config
   config = function(_, opts)
      autolib.multicursor.setup(opts)

      autolib.misc.dbg_err(function()
         autolib.multicursor.addKeymapLayer(function(set)
            autolib.keymap.set_many({
               setter = set,
               {
                  "<esc>",
                  function()
                     if not autolib.multicursor.cursorsEnabled() then
                        autolib.multicursor.enableCursors()
                     else
                        autolib.multicursor.clearCursors()
                     end
                  end,
                  desc = "Enable and Clear cursors",
               },
            })
         end)
      end)
   end,

   keys = function(_, keys)
      local setter = autolib.keymap.lazy_keys_spec_setter(keys)
      autolib.keymap.set_many({
         setter = setter,
         {
            "<c-leftmouse>",
            function()
               autolib.multicursor.handleMouse()
            end,
            desc = "Add cursor",
         },
         {
            "<c-leftdrag>",
            function()
               autolib.multicursor.handleMouseDrag()
            end,
            desc = "Add cursor",
         },
         {
            "<c-leftrelease>",
            function()
               autolib.multicursor.handleMouseRelease()
            end,
            desc = "Add cursor",
         },
      })
      autolib.keymap.set_many({
         setter = setter,
         mode = { "n", "x" },
         {
            "<M-j>",
            function()
               autolib.multicursor.lineAddCursor(1)
            end,
            desc = "Add cursor below",
         },
         {
            "<M-k>",
            function()
               autolib.multicursor.lineAddCursor(-1)
            end,
            desc = "Add cursor above",
         },
         -- TODO: Select next/all occurence(s)
      })
      return keys
   end,
}
