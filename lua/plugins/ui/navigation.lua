return {
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "F", ":HopWord<CR>", { noremap = true, silent = true })
    end,
  },
}
