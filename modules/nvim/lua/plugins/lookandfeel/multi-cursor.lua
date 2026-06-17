local libs = require("util.libs")

local get_mc = libs.misc.store_lazily(function()
   return require("multicursor-nvim")
end)

return {
   "jake-stewart/multicursor.nvim",
   branch = "1.0",
   opts = {},
   lazy = true,

   -- TODO: Try to register layer without config
   config = function(_, opts)
      local mc = get_mc()
      mc.setup(opts)

      mc.addKeymapLayer(function(set)
         libs.keymap.set_many({
            setter = set,
            {
               "<esc>",
               function()
                  if not mc.cursorsEnabled() then
                     mc.enableCursors()
                  else
                     mc.clearCursors()
                  end
               end,
               desc = "Enable and Clear cursors",
            },
         })
      end)
   end,

   keys = function(_, keys)
      local setter = libs.keymap.lazy_spec_setter(keys)

      libs.keymap.set_many({
         setter = setter,
         {
            "<c-leftmouse>",
            function()
               get_mc().handleMouse()
            end,
            desc = "Add cursor",
         },
         {
            "<c-leftdrag>",
            function()
               get_mc().handleMouseDrag()
            end,
            desc = "Add cursor",
         },
         {
            "<c-leftrelease>",
            function()
               get_mc().handleMouseRelease()
            end,
            desc = "Add cursor",
         },
      })
      libs.keymap.set_many({
         setter = setter,
         mode = { "n", "x" },
         {
            "<M-j>",
            function()
               get_mc().lineAddCursor(1)
            end,
            desc = "Add cursor below",
         },
         {
            "<M-k>",
            function()
               get_mc().lineAddCursor(-1)
            end,
            desc = "Add cursor above",
         },
         {
            "<M-J>",
            function()
               get_mc().lineSkipCursor(1)
            end,
            desc = "Skip cursor below",
         },
         {
            "<M-K>",
            function()
               get_mc().lineSkipCursor(-1)
            end,
            desc = "Skip cursor above",
         },
      })
      libs.keymap.set_many({
         setter = setter,
         mode = { "n", "x" },
         {
            "<M-n>",
            function()
               get_mc().matchAddCursor(1)
            end,
            desc = "Add cursor on next occurrence",
         },
         {
            "<M-p>",
            function()
               get_mc().matchAddCursor(-1)
            end,
            desc = "Add cursor on prev occurrence",
         },
         {
            "<M-N>",
            function()
               get_mc().matchSkipCursor(1)
            end,
            desc = "Skip cursor on next occurrence",
         },
         {
            "<M-P>",
            function()
               get_mc().matchSkipCursor(-1)
            end,
            desc = "Skip cursor on prev occurrence",
         },
      })
      return keys
   end,
}
