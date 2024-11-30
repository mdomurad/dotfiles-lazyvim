return {
  {
    "brianhuster/live-preview.nvim",
    dependencies = {
      "brianhuster/autosave.nvim", -- Not required, but recomended for autosaving and sync scrolling
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      port = 5501,
    },
  },
}
