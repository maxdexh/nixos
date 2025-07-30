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

   ["@lsp.type.interface"] = "@interface",

   ["@namespace"] = "@module",

   ["@lsp.type.macro"] = "Macro",

   ["@lsp.type.method"] = "@lsp.type.function",
   ["@lsp.typemod.method.declaration"] = "@lsp.typemod.function.declaration",

   ["@lsp.type.parameter"] = "parameter",
   ["rustMacroVariable"] = "parameter",
   ["@keyword"] = "keyword",

   ["@lsp.type.lifetime"] = "@lsp.type.typeParameter",
   ["@keyword.import.rust"] = "keyword",
   ["rustModPath"] = "@module",
   ["rustAttribute"] = "operator",
}
---@type string[]
local deleted_hls = {
   "@function.macro.rust", -- treesitter randomly matches stuff in macros, including all parameters
   "@variable.rust", -- treesitter likes to randomly view keywords as variables in macro_rules
   "@operator.rust", -- treesitter turns macro exclamation marks into operators
   "@variable.builtin.rust", -- causes self to be colored as a parameter
   "@module.rust", -- causes super to be colored as a module
   "@lsp.type.string.rust", -- affects contents of stringify! inside concat!
   "rustAssert", -- works only sometimes in macros
   "DiagnosticUnnecessary", -- Intrusive

   "@punctuation.bracket", -- Breaks rainbow-brackets because treesitter takes precedence
   "rustFoldBraces", -- See above
   "@lsp.type.operator.lua", -- For some reason this is applied to brackets and braces, breaking rainbow-brackets
}

-- From tomasiser/vim-code-dark
--
---@type table<string, vim.api.keyset.highlight>
local others = {
   ["DiagnosticUnderlineWarn"] = {
      underline = true,
      sp = "NvimLightYellow",
   },
   ["DiagnosticUnderlineError"] = {
      underline = true,
      sp = "NvimLightRed",
   },
}

---@type table<string, vim.api.keyset.highlight>
local overrides = libs.r.tbl.merge(
   "error",
   libs.r.tbl.map_vals(
      hl_remaps,
      ---@param color string
      ---@return vim.api.keyset.highlight
      function(color)
         return { link = color }
      end
   ),
   libs.r.tbl.map_vals(
      fg_color_overrides,
      ---@param color string
      ---@return vim.api.keyset.highlight
      function(color)
         return { fg = color }
      end
   ),
   libs.r.list.associate(
      deleted_hls,
      ---@return vim.api.keyset.highlight
      function()
         return {}
      end,
      "error"
   ),
   others
)

return {
   {
      -- TODO: Split into corresponding files
      "nvim-treesitter/nvim-treesitter",
      opts = {
         highlight = {
            enable = true,
            -- TODO: Move files
            additional_vim_regex_highlighting = { "rust" },
         },
         indent = { enable = true, disable = { "python", "css", "rust" } },
      },
   },
   {
      "HiPhish/rainbow-delimiters.nvim",
      submodules = false,
      priority = 1999,
      init = function()
         vim.g.rainbow_delimiters = {
            highlight = {
               "RainbowDelimiterYellow",
               "RainbowDelimiterRed",
               "RainbowDelimiterBlue",
            },
            query = {
               [""] = "rainbow-delimiters",
               lua = "rainbow-blocks",
            },
         }
      end,
   },
   {
      "Mofiqul/vscode.nvim",
      lazy = false,
      priority = 2000,
      opts = {
         codedark_modern = true,
      },
      init = function()
         vim.opt.cursorline = false
         libs.r.lang.add_auto_hl_overrides(overrides)
         vim.cmd([[colorscheme vscode]])
      end,
   },
   { "LazyVim/LazyVim", opts = { colorscheme = "vscode" } },

   { "tokyonight.nvim", enabled = false },
}
