return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("minuet").setup({
      provider = "openai",

      virtualtext = {
        auto_trigger_ft = {}, -- All file types

        keymap = {
          accept = "<Tab>",
          accept_line = "<S-Tab>",
          accept_word = "<C-Right>",
          next = "<A-l>",
          prev = "<A-j>",
          dismiss = "<Esc>",
        },
      },
    })
  end,
}