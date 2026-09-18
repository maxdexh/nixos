vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim, {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                rustc = {
                    source = "discover",
                },
                checkOnSave = false,
            },
        },
    },
})
