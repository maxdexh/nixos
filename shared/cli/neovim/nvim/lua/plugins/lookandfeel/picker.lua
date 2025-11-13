local libs = require("util.libs")

return {
   {
      "folke/snacks.nvim",
      keys = function(_, keys)
         local setter = libs.keymap.lazy_spec_setter(keys)
         libs.keymap.set_many({
            setter = setter,
            {
               "<leader>sx",
               function()
                  require("snacks").picker.resume()
               end,
               desc = "File tree",
            },
         })
      end,
   },
}
