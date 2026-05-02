return {
  {
    "barrettruth/canola.nvim",
    config = function()
      require("oil").setup({
        keymaps = {
          ["<BS>"] = "actions.parent",
        },
      })
    end,
  },
}
