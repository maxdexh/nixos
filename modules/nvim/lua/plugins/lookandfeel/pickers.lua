local libs = require("util.libs")

-- Useful picker binds from lazyvim
-- <leader>sp (plugin specs)
-- <leader>ss (lsp symbols)
-- <leader>sS (lsp workspace symbols)
-- <leader>sb (buffer lines)
-- <leader>sC (commands)
-- <leader>su (undotree)
-- <leader>sT (todos)
-- <leader>sM (man pages)
-- <leader>sH (highlights)
-- <leader>si (emojis)
-- <leader>sj (jumps)
-- <ledaer>sh (help pages)
-- <leader>sn (noice messages)
-- <leader>sq (quickfix list)
-- <leader>s/ ('/' search history)
-- <leader>gl (git log, capital for cwd)
-- <leader>gs (git status, +diff in previews)
-- <leader>gS (git stash)
--
-- TODO: <leader>sp but global plugin file search
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
                  Snacks.picker.resume()
               end,
               desc = "Resume Picker",
            },
            { "<leader>fP", LazyVim.pick("pickers"), desc = "Find Pickers" },
            -- Swapped root and non-root from lazyvim
            { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
            { "<leader>fF", LazyVim.pick("files", { root = true }), desc = "Find Files (Root Dir)" },
            { "<leader>sw", LazyVim.pick("grep_visual", { root = false }), mode = "x", desc = "Selection (cwd)" },
            { "<leader>sW", LazyVim.pick("grep_visual", { root = true }), mode = "x", desc = "Selection (Root Dir)" },
            { "<leader>sg", LazyVim.pick("grep", { root = false }), desc = "Grep (cwd)" },
            { "<leader>sG", LazyVim.pick("grep", { root = true }), desc = "Selection (Root Dir)" },
         })
      end,
   },
}
