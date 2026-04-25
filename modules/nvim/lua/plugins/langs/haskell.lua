return {
   --{
   --   "mrcjkb/haskell-tools.nvim",
   --   lazy = false,
   --   version = "^9",
   --},
   {
      "mason.nvim",
      opts = {
         ensure_installed = { "ormolu" },
      },
   },
}
