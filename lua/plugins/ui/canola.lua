return {
  {
    "https://forge.barrettruth.com/barrettruth/canola.nvim",
    config = function()
      require("oil").setup({
        keymaps = {
          ["<BS>"] = "actions.parent",
        },
      })
    end,
  },
}
