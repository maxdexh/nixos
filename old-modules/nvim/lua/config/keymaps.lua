-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local libs = require("util.libs")

-- TODO: Single key/combo that maps to "+, e.g. <C-=>

libs.misc.dbg_err(function()
   libs.keymap.set_many({
      { "<C-c>", '"+y', desc = "Copy Selection", mode = "v" },
      { "<ESC><ESC>", "<C-\\><C-n>", desc = "Exit Terminal mode", mode = "t" },
      -- Unlike lazyvim's keybind, this escapes before saving, because the other order interrupts the formatter
      -- in case of automatic clearing of whitespace only line when switching to normal mode
      { "<C-s>", "<ESC><Cmd>wa<CR>", desc = "Save File", mode = "i" },
      { "<C-s>", "<Cmd>wa<CR>", desc = "Save File", mode = "n" },
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

   libs.keymap.set_many({
      { "]d", jump(1), desc = "Next Diagnostic" },
      { "[d", jump(-1), desc = "Prev Diagnostic" },
      { "]e", jump(1, "ERROR"), desc = "Next Error" },
      { "[e", jump(-1, "ERROR"), desc = "Prev Error" },
      { "]w", jump(1, "WARN"), desc = "Next Warning" },
      { "[w", jump(-1, "WARN"), desc = "Prev Warning" },
   })
end)
libs.misc.dbg_err(function()
   ---@param tab boolean
   ---@param path string
   local function spawn_term(tab, path)
      if path:len() == 0 then
         path = LazyVim.root()
      end
      path = vim.fn.resolve(vim.fs.abspath(vim.fn.expand(path)))
      if vim.fn.isdirectory(path) == 0 then
         path = vim.fs.dirname(path)
      end
      local socket = vim.env["KITTY_LISTEN_ON"]
      if not socket then
         error("KITTY_LISTEN_ON was unset")
      end
      vim.system({
         "kitten",
         "@",
         "--to",
         socket,
         "launch",
         "--cwd",
         path,
         "--type",
         tab and "tab" or "os-window",
      })
   end

   vim.api.nvim_create_user_command("Term", function(args)
      spawn_term(false, args.args)
   end, { nargs = "*" })
   vim.api.nvim_create_user_command("Termtab", function(args)
      spawn_term(true, args.args)
   end, { nargs = "*" })
end)

-- TODO: Add keybind like <leader>ft that uses the basename of the current buffer

-- TODO: Optionally open definitions, implementations, references, diagnostics as a persistent split (using vim.lsp or trouble)
-- NOTE: <C-w>j (or h,k,l) to switch between splits
-- FIXME: Move to pickers.lua
local function set_lsp_keybinds(buf)
   -- TODO: Snacks picker as a buffer?
   libs.keymap.set_many({
      buffer = buf,
      {
         "gd",
         function()
            -- TODO: optionally vim.lsp.buf.definition() / Trouble lsp_definitions
            Snacks.picker.lsp_definitions()
         end,
         desc = "Goto Definition",
      },
      {
         "gi",
         function()
            -- TODO: vim.lsp.buf.implementation() / Trouble
            Snacks.picker.lsp_implementations()
         end,
         desc = "View Implementations",
      },
      {
         "gr",
         function()
            -- TODO: vim.lsp.buf.references() / Trouble
            Snacks.picker.lsp_references()
         end,
         desc = "View References",
      },

      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" },
      { "<leader>cws", vim.lsp.buf.workspace_symbol, desc = "List workspace Symbols (Filter Query)" },

      { "K", vim.lsp.buf.hover, desc = "Hover Information" },
      { "<C-h>", vim.lsp.buf.signature_help, desc = "Signature Help", mode = "i" },

      { "<leader>xc", vim.diagnostic.open_float, desc = "Show diagnostic" },
      {
         "<leader>xx",
         function()
            Snacks.picker.diagnostics()
         end,
         desc = "Diagnostics",
      },
      {
         "<leader>xX",
         function()
            Snacks.picker.diagnostics_buffer()
         end,
         desc = "Diagnostics (Current buffer)",
      },
   })
end

-- set LSP keybinds
vim.api.nvim_create_autocmd("LspAttach", {
   group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),

   ---@param args vim.api.keyset.create_autocmd.callback_args
   callback = function(args)
      libs.misc.dbg_err(function()
         set_lsp_keybinds(args.buf)
      end)
   end,
})
