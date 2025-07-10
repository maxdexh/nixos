local libs = require("util.libs")

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
      return libs.r.lang.try_catch(try, function(err)
         libs.r.log.dbg(err, "error")
         fallback()
      end)
   end
end

---@param cmd string
---@return fun()
local function cmdfunc(cmd)
   return function()
      vim.cmd(cmd)
   end
end

-- https://www.reddit.com/r/neovim/comments/137biza/keep_all_results_of_telescope_live_grep_in_a/
--
-- TODO: Just use commands for the telescope stuff
function configured_keymaps.set_lsp_keybinds(buf)
   libs.r.keymap.set_many({
      buffer = buf,
      {
         "gd",
         with_fallback(libs.f.telef.lsp_definitions, vim.lsp.buf.definition),
         desc = "Goto Definition",
      },
      {
         "gi",
         with_fallback(libs.f.telef.lsp_implementations, vim.lsp.buf.implementation),
         desc = "View Implementations",
      },
      {
         "gr",
         with_fallback(libs.f.telef.lsp_references, vim.lsp.buf.references),
         desc = "View References",
      },
      { "<leader>vd", vim.diagnostic.open_float, desc = "Diagnostics floating window" },
      { "<leader>vca", vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>vrn", vim.lsp.buf.rename, desc = "Rename Symbol" },
      { "K", vim.lsp.buf.hover, desc = "Hover Information" },
      { "<leader>vws", vim.lsp.buf.workspace_symbol, desc = "List workspace Symbols (Filter Query)" },
      { "<C-h>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i" },
      {
         "<leader>xx",
         with_fallback(
            libs.r.func.partial(libs.f.telef.diagnostics, { severity_limit = "warn" }),
            cmdfunc("Trouble diagnostics toggle")
         ),
         desc = "Diagnostics",
      },
      {
         "<leader>xX",
         with_fallback(
            libs.r.func.partial(libs.f.telef.diagnostics, { bufnr = 0, severity_limit = "warn" }),
            cmdfunc("Trouble diagnostics toggle filter.buf=0")
         ),
         desc = "Diagnostics (Current buffer)",
      },
   })
end

function configured_keymaps.set_global_keybinds()
   libs.r.keymap.set_many({
      -- TODO: Set <C-v> individually in fish and here so that we can paste in multicursor mode
      { "<C-c>", '"+y', desc = "Copy Selection", mode = "v" },
      { "<ESC><ESC>", "<C-\\><C-n>", desc = "Exit Terminal mode", mode = "t" },
      -- Unlike lazyvim's keybind, this escapes before saving, because the other order interrupts the formatter
      -- in case of automatic clearing of whitespace only line when switching to normal mode
      { "<C-s>", "<ESC><Cmd>wa<CR>", desc = "Save File", mode = "i" },
      { "<C-s>", "<Cmd>wa<CR>", desc = "Save File", mode = "n" },
   })

   -- emmy doesnt like -1 literal (which is not even the correct argument type lol)
   ---@cast libs.r.mc.lineAddCursor fun(d?: integer)

   libs.r.keymap.set_many({
      mode = { "n", "x" },
      {
         "<M-j>",
         function()
            libs.r.mc.lineAddCursor(vim.v.count1)
         end,
         desc = "Add cursor below",
      },
      {
         "<M-k>",
         function()
            libs.r.mc.lineAddCursor(-vim.v.count1)
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
   libs.r.keymap.set_many({
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
   return libs.r.keymap.normalize_shared({
      {
         "<c-leftmouse>",
         libs.r.func.from_callable(libs.f.mc.handleMouse),
         desc = "Add cursor",
      },
      {
         "<c-leftdrag>",
         libs.r.func.from_callable(libs.f.mc.handleMouseDrag),
         desc = "Add cursor",
      },
      {
         "<c-leftrelease>",
         libs.r.func.from_callable(libs.f.mc.handleMouseRelease),
         desc = "Add cursor",
      },
   })
end

function configured_keymaps.set_multicursor_layer()
   libs.r.mc.addKeymapLayer(function(set)
      libs.r.keymap.set_many({
         setter = set,
         {
            "<esc>",
            function()
               if not libs.r.mc.cursorsEnabled() then
                  libs.r.mc.enableCursors()
               else
                  libs.r.mc.clearCursors()
               end
            end,
            desc = "Enable and Clear cursors",
         },
      })
   end)
end

---@return Util.keymap.KeyOpts[]
function configured_keymaps.get_telescope_bindings()
   return {
      {
         "<leader>sG",
         libs.r.func.from_callable(libs.f.tele.extensions.live_grep_args.live_grep_args),
         desc = "Live Grep (Args)",
      },
      {
         "<leader>sx",
         libs.r.func.from_callable(libs.f.telef.resume),
         desc = "Resume telescope",
      },
      {
         "<leader>fE",
         libs.r.func.partial(libs.f.tele.extensions.file_browser.file_browser, { quiet = true }),
         desc = "File Browser (cwd)",
      },
      {
         "<leader>fe",
         function()
            libs.r.tele.extensions.file_browser.file_browser({
               quiet = true,
               select_buffer = true,
               path = vim.fn.expand("%:p:h"),
            })
         end,
         desc = "File Browser (current buffer dir)",
      },
      -- These are swapped from the regular bindings
      {
         "<leader>fF",
         LazyVim.pick("files"),
         desc = "Find Files (Root Dir)",
      },
      {
         "<leader>ff",
         LazyVim.pick("files", { root = false }),
         desc = "Find Files (cwd)",
      },
   }
end

return configured_keymaps
