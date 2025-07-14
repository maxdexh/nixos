vim.lsp.config("nil_ls", {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/nil" },
})

vim.lsp.enable("nil_ls")

return {
	{
		"mason.nvim",
		opts = {
			ensure_installed = { "nil", "nixfmt" },
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}
