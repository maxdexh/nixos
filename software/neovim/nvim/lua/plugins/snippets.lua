-- See :LazyExtras; NOTE: Compatibility with friendly-snippets is handled by the extra
local autolib = require("util.autolib")

---@param placeholder_values string[]
---@return string
local function copy_placeholder(placeholder_values)
   return placeholder_values[1] or ""
end

local function rust_snippets()
   local ls = require("luasnip") --[[@as any]]
   local fmta = require("luasnip.extras.fmt").fmta

   local opts = { indent_string = "   " }
   return {
      ls.snippet(
         "maccrate",
         fmta(
            [[
               macro_rules! <> {
                  ( <> ) =>> {
                     <>
                  };
               }
               pub(crate) use <>;
            ]],
            {
               ls.insert_node(1),
               ls.insert_node(2),
               ls.insert_node(0),
               ls.function_node(copy_placeholder, 1),
            },
            opts
         )
      ),
      ls.snippet(
         "macpub",
         fmta(
            [[
               #[macro_export]
               #[doc(hidden)]
               macro_rules! __<> {
                  ( <> ) =>> {
                     <>
                  };
               }
               pub use __<> as <>;
            ]],
            {
               ls.function_node(copy_placeholder, 1),
               ls.insert_node(2),
               ls.insert_node(0),
               ls.function_node(copy_placeholder, 1),
               ls.insert_node(1),
            },
            opts
         )
      ),
   }
end

return {
   {
      "L3MON4D3/LuaSnip",
      opts = function(_, opts)
         local ls = require("luasnip") --[[@as any]]

         -- TODO: Use VSCode loader for snippets, split by lang
         ls.add_snippets("rust", autolib.misc.dbg_err(rust_snippets) or {})

         return opts
      end,
   },
}
