local autolib = require("util.autolib")

local configured_keymaps = {}

-- TODO: Bind more telescope pickers https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers

---@param f fun()
local function repeat_count(f)
   for _ = 1, vim.v.count1, 1 do
      f()
   end
end

---@param f fun()
---@return fun()
local function repeating_count(f)
   return function()
      return repeat_count(f)
   end
end

---@generic T
---@param try fun()
---@param fallback fun()
---@return fun()
local function with_fallback(try, fallback)
   return function()
      return autolib.lang.try_catch(try, function(err)
         autolib.log.dbg(err, "error")
         fallback()
      end)
   end
end

-- TODO: Use "Telescope ..." commands instead of telescope.builtin for telescope
-- FIXME: Consider switching from telescope to something that can be optionally opened as a persistent buffer/split
-- TODO: Optionally open definitions, implementations, references, diagnostics as a persistent split (using vim.lsp or trouble)
-- NOTE: <C-w>j (or h,k,l) to switch between splits
function configured_keymaps.set_lsp_keybinds(buf)
   autolib.keymap.set_many({
      buffer = buf,
      {
         "gd",
         function()
            -- TODO: optionally vim.lsp.buf.definition() / Trouble lsp_definitions
            autolib.tscope_funcs.lsp_definitions()
         end,
         desc = "Goto Definition",
      },
      {
         "gi",
         function()
            -- TODO: vim.lsp.buf.implementation() / Trouble
            autolib.tscope_funcs.lsp_implementations()
         end,
         desc = "View Implementations",
      },
      {
         "gr",
         function()
            -- TODO: vim.lsp.buf.references() / Trouble
            autolib.tscope_funcs.lsp_references()
         end,
         desc = "View References",
      },

      { "<leader>cd", vim.diagnostic.open_float, desc = "Show diagnostic" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" },
      { "<leader>cws", vim.lsp.buf.workspace_symbol, desc = "List workspace Symbols (Filter Query)" },

      { "K", vim.lsp.buf.hover, desc = "Hover Information" },
      { "<C-h>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i" },

      {
         "<leader>xx",
         function()
            -- vim.cmd("Trouble diagnostics toggle")
            autolib.tscope_funcs.diagnostics({ severity_limit = "warn" })
         end,
         desc = "Diagnostics",
      },
      {
         "<leader>xX",
         function()
            -- vim.cmd("Trouble diagnostics toggle filter.buf=0")
            autolib.tscope_funcs.diagnostics({ bufnr = 0, severity_limit = "warn" })
         end,
         desc = "Diagnostics (Current buffer)",
      },
   })
end

function configured_keymaps.set_global_keybinds()
   autolib.keymap.set_many({
      -- TODO: Set <C-v> individually in fish and here so that we can paste in multicursor mode
      { "<C-c>", '"+y', desc = "Copy Selection", mode = "v" },
      { "<ESC><ESC>", "<C-\\><C-n>", desc = "Exit Terminal mode", mode = "t" },
      -- Unlike lazyvim's keybind, this escapes before saving, because the other order interrupts the formatter
      -- in case of automatic clearing of whitespace only line when switching to normal mode
      { "<C-s>", "<ESC><Cmd>wa<CR>", desc = "Save File", mode = "i" },
      { "<C-s>", "<Cmd>wa<CR>", desc = "Save File", mode = "n" },
   })

   -- emmy doesnt like -1 literal (which is not even the correct argument type lol)
   ---@cast autolib.mc.lineAddCursor fun(d?: integer)

   autolib.keymap.set_many({
      mode = { "n", "x" },
      {
         "<M-j>",
         function()
            autolib.multicursor.lineAddCursor(vim.v.count1)
         end,
         desc = "Add cursor below",
      },
      {
         "<M-k>",
         function()
            autolib.multicursor.lineAddCursor(-vim.v.count1)
         end,
         desc = "Add cursor above",
      },
      -- TODO: Select next/all occurence(s)
   })

   vim.diagnostic.config({
      jump = {
         float = true,
      },
   })
   ---@param cnt integer
   ---@param severity string?
   ---@return fun()
   local function jump(cnt, severity)
      return function()
         vim.diagnostic.jump({
            count = cnt,
            severity = severity and vim.diagnostic.severity[severity],
         })
      end
   end
   -- NOTE: lazyvim uses deprecated functions to implement this and these do not respect vim.diagnostic.config
   autolib.keymap.set_many({
      { "]d", jump(1), desc = "Next Diagnostic" },
      { "[d", jump(-1), desc = "Prev Diagnostic" },
      { "]e", jump(1, "ERROR"), desc = "Next Error" },
      { "[e", jump(-1, "ERROR"), desc = "Prev Error" },
      { "]w", jump(1, "WARN"), desc = "Next Warning" },
      { "[w", jump(-1, "WARN"), desc = "Prev Warning" },
      mode = "n",
   })
end

---@return Util.keymap.KeyOpts[]
function configured_keymaps.get_multicursor_globals()
   return autolib.keymap.normalize_shared({
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
end

function configured_keymaps.set_multicursor_layer()
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
end

return configured_keymaps
