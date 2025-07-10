local libs = require("util.libs")

return {
   {
      "xzbdmw/colorful-menu.nvim",
      opts = {
         ls = {
            ["rust-analyzer"] = {
               extra_info_hl = "@comment",
               align_type_to_right = true,
               preserve_type_when_truncate = true,
            },
         },
      },
   },
   {
      -- FIXME: HELP
      "saghen/blink.cmp",
      dependencies = {
         "moyiz/blink-emoji.nvim",
         "Kaiser-Yang/blink-cmp-dictionary",
      },
      opts = {
         cmdline = {
            enabled = true,
            sources = function()
               local type = vim.fn.getcmdtype()
               if type == "/" or type == "?" then
                  return { "buffer" }
               end
               if type == ":" or type == "@" then
                  return { "cmdline" }
               end
               return {}
            end,
            completion = {
               ghost_text = { enabled = true },
            },
         },

         completion = {
            menu = {
               border = "single",
               draw = {
                  columns = { { "kind_icon" }, { "label", gap = 1 } },
                  components = {
                     label = {
                        width = { fill = true, max = 60 },
                        text = function(ctx)
                           local highlights_info = libs.r.cmenu.blink_highlights(ctx)
                           if highlights_info ~= nil then
                              -- Or you want to add more item to label
                              return highlights_info.label
                           else
                              return ctx.label
                           end
                        end,
                        highlight = function(ctx)
                           local highlights = {}
                           local highlights_info = libs.r.cmenu.blink_highlights(ctx)
                           if highlights_info ~= nil then
                              highlights = highlights_info.highlights
                           end
                           for _, idx in ipairs(ctx.label_matched_indices) do
                              table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                           end
                           -- Do something else
                           return highlights
                        end,
                     },
                  },
               },
            },
            documentation = {
               auto_show = true,
               window = {
                  border = "single",
               },
            },
            list = {
               selection = {
                  auto_insert = false,
               },
            },
         },

         fuzzy = {
            implementation = "prefer_rust_with_warning",
            sorts = {
               "exact",
               "score",
               "sort_text",
            },
         },

         signature = { enabled = true },

         keymap = {
            preset = "default",
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },

            ["<S-k>"] = { "scroll_documentation_up", "fallback" },
            ["<S-j>"] = { "scroll_documentation_down", "fallback" },

            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
         },
      },
   },
}
