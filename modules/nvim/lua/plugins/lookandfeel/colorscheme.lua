local libs = require("util.libs")

---@type table<string, string>
local fg_color_overrides = {
   ["RainbowDelimiterYellow"] = "#FFD700",
   ["RainbowDelimiterRed"] = "#DA70D6",
   ["RainbowDelimiterBlue"] = "#179FFF",
   ["@lsp.typemod.function.declaration"] = "#DCDCAA",
   ["@type"] = "#39C8B0",
   ["@interface"] = "#B8D7A3",
   ["@lsp.type.enumMember"] = "#D3D3D3",
   ["Macro"] = "#4EADE5",
   ["@lsp.type.function"] = "#FFC66D",
   ["@lsp.type.typeParameter"] = "#20999D",
   ["parameter"] = "#9CDCFE",
   ["keyword"] = "#499CD5",
   ["@module"] = "#DCDCAA",

   ["DiffAdd"] = "#00FF00",
   ["DiffDelete"] = "#FF0000",
   ["DiffChange"] = "#AAAA00",
}
---@type table<string, string>
local hl_remaps = {
   ["@lsp.type.typeAlias"] = "@type",
   ["@lsp.type.union"] = "@type",
   ["@lsp.type.enum"] = "@type",
   ["@lsp.type.struct"] = "@type",
   ["@lsp.type.class"] = "@type",
   ["@lsp.type.builtinType"] = "@type",
   ["variable"] = "@variable",
   ["@lsp.type.const"] = "@variable",
   ["@lsp.type.builtinAttribute.rust"] = "@attribute",

   ["@lsp.type.interface"] = "@interface",

   ["@namespace"] = "@module",

   ["@lsp.type.macro"] = "Macro",
   ["@function.macro.rust"] = "Macro",

   ["@lsp.type.method"] = "@lsp.type.function",
   ["@lsp.typemod.method.declaration"] = "@lsp.typemod.function.declaration",

   ["@lsp.type.parameter"] = "parameter",
   ["@lsp.type.selfKeyword.rust"] = "keyword",
   ["rustMacroVariable"] = "parameter",
   ["@keyword"] = "keyword",
   ["@constant"] = "@variable",

   ["@lsp.type.lifetime"] = "@lsp.type.typeParameter",
   ["@keyword.import.rust"] = "keyword",
   ["rustModPath"] = "@module",
   ["rustAttribute"] = "operator",
}
---@type string[]
local deleted_hls = {
   "@variable.rust", -- treesitter likes to randomly view keywords as variables in macro_rules
   "@operator.rust", -- treesitter turns macro exclamation marks into operators
   "@variable.builtin.rust", -- causes self to be colored as a parameter
   -- "@module.rust", -- normally causes super to be colored as a module instead of a keyword, but for some reason it is no longer considered the latter? uncomment once fixed
   "@lsp.type.string.rust", -- affects contents of stringify! inside concat!
   "rustAssert", -- works only sometimes in macros
   "DiagnosticUnnecessary", -- Intrusive

   "@punctuation.bracket", -- Breaks rainbow-brackets because treesitter takes precedence
   "rustFoldBraces", -- See above
   "@lsp.type.operator.lua", -- For some reason this is applied to brackets and braces, breaking rainbow-brackets

   "@markup.link.markdown_inline", -- disable underlining of links (for comment highlighting)
   "@lsp.type.comment.rust", -- would override injections due to high priority
}

---@type table<string, vim.api.keyset.highlight>
local overrides = {
   -- Diagnostic hls from tomasiser/vim-code-dark
   ["DiagnosticUnderlineWarn"] = {
      underline = true,
      sp = "NvimLightYellow",
   },
   ["DiagnosticUnderlineError"] = {
      underline = true,
      sp = "NvimLightRed",
   },
}
libs.misc.dbg_err(function()
   local function put(name, hl)
      if overrides[name] ~= nil then
         libs.misc.dbg("Duplicate override: " .. name, "error")
      end
      overrides[name] = hl
   end
   for name, color in pairs(fg_color_overrides) do
      put(name, { fg = color })
   end
   for name, link in pairs(hl_remaps) do
      put(name, { link = link })
   end
   for _, name in ipairs(deleted_hls) do
      put(name, {})
   end
end)

return {
   {
      "nvim-treesitter/nvim-treesitter",
      opts = {
         auto_install = true,
         highlight = {
            enable = true,
            -- additional_vim_regex_highlighting = { "rust" },
         },
         indent = { enable = true, disable = { "python", "css", "rust" } },
      },
   },
   { "LazyVim/LazyVim", opts = { colorscheme = "vscode" } },
   {
      "Mofiqul/vscode.nvim",
      lazy = false,
      priority = 2000,
      opts = {
         codedark_modern = true,
         transparent = true,
         terminal_colors = true,
      },
      init = function()
         libs.misc.add_auto_hl_overrides(overrides)

         -- Transparency fixes (Find using colorpicker and searching in :hi)
         vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
               vim.cmd("hi StatusLine guibg=NONE ctermbg=NONE")
               vim.cmd("hi MoreMsg guibg=NONE")
               vim.cmd("hi ModeMsg guibg=NONE")
               vim.cmd("hi TabLineFill guibg=NONE")
               vim.cmd("hi NormalFloat guibg=NONE")
            end,
         })
      end,
   },
   { "tokyonight.nvim", enabled = false },
   {
      "nvim-treesitter/nvim-treesitter",
      opts = {
         ensure_installed = {
            "all",
         },
      },
   },
}
