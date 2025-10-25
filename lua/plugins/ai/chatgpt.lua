return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      actions_paths = {
        vim.fn.expand("<sfile>:p:h") .. "/chatGPTactions.json",
      },
      openai_params = {
        model = "gpt-4o-mini",
      },
      openai_edit_params = {
        model = "gpt-4o-mini",
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}