return {
  {
    "kungfusheep/mfd.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mfd").setup({
        bright_comments = true, -- increase comment visibility (default: false)
      })
      vim.cmd("colorscheme mfd-stealth")
    end,
  },
}
