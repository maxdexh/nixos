-- See :LazyExtras; NOTE: Compatibility with friendly-snippets is handled by the extra
local libs = require("util.libs")

---@param placeholder_values string[]
---@return string
local function copy_placeholder(placeholder_values)
   return placeholder_values[1] or ""
end

local function rust_snippets()
   local ls = libs.r.ls
   local fmta = libs.r.ls_fmt.fmta

   local default_pat = "$($t:tt)*"
   local opts = { indent_string = "   " }
   return {
      ls.snippet(
         "macrule",
         fmta(
            [[
               macro_rules! <> {
                  [ <> ] =>> {
                     <>
                  };
               }
            ]],
            {
               ls.insert_node(1, "name"),
               ls.insert_node(2, default_pat),
               ls.insert_node(3),
            },
            opts
         )
      ),
      ls.snippet(
         "macexport",
         fmta(
            [[
               #[macro_export]
               macro_rules! <> {
                  [ <> ] =>> {
                     <>
                  };
               }
            ]],
            {
               ls.insert_node(1, "name"),
               ls.insert_node(2, default_pat),
               ls.insert_node(3),
            },
            opts
         )
      ),
      ls.snippet(
         "maccrate",
         fmta(
            [[
               macro_rules! <> {
                  [ <> ] =>> {
                     <>
                  };
               }
               pub(crate) use <>;
            ]],
            {
               ls.insert_node(1, "name"),
               ls.insert_node(2, default_pat),
               ls.insert_node(3),
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
                  [ <> ] =>> {
                     <>
                  };
               }
               pub use __<> as <>;
            ]],
            {
               ls.function_node(copy_placeholder, 1),
               ls.insert_node(2, default_pat),
               ls.insert_node(3),
               ls.function_node(copy_placeholder, 1),
               ls.insert_node(1, "name"),
            },
            opts
         )
      ),
   }
end

function snippets(func)
   return libs.r.lang.dbg_err(func) or {}
end

return {
   {
      "L3MON4D3/LuaSnip",
      opts = function(_, opts)
         local ls = require("luasnip")
         local fmta = require("luasnip.extras.fmt").fmta

         -- TODO: Use VSCode loader for snippets, split by lang
         ls.add_snippets("rust", snippets(rust_snippets))

         return opts
      end,
   },
}
