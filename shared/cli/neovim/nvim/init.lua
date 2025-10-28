vim.hl = vim.highlight -- https://github.com/neovim/neovim/issues/31675#issuecomment-2558405042

-- WHYYYYYY = {}
-- local function add(tb)
--    for i, v in ipairs(vim.split(tb, "\n")) do
--       if i ~= 1 then
--          if not v:find("/etc/nixos/shared/cli/neovim/nvim/init.lua") then
--             table.insert(WHYYYYYY, v)
--             return
--          end
--       end
--    end
--    table.insert(WHYYYYYY, "IDK")
-- end
--
-- local lspconfig = vim.lsp.config
-- vim.lsp.config = setmetatable({}, {
--    __call = function(_, ...)
--       if select(1, ...) == "nil_ls" then
--          add(debug.traceback())
--       end
--       return lspconfig(...)
--    end,
--    __index = function(_, k)
--       if k == "nil_ls" then
--          add(debug.traceback())
--       end
--       return lspconfig[k]
--    end,
--    __newindex = function(_, k, v)
--       if k == "nil_ls" then
--          add(debug.traceback())
--       end
--       lspconfig[k] = v
--    end,
-- })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
