local ai_config = require("config.ai")

return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      actions_paths = {
        vim.fn.expand("<sfile>:p:h") .. "/chatGPTactions.json",
      },
      openai_params = {
        model = ai_config.chatgpt.chat,
      },
      openai_edit_params = {
        model = ai_config.chatgpt.edit,
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

