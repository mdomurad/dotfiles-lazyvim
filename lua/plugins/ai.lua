return {
  {

    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        model = "gpt-3.5-turbo",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      window = {
        layout = "float",
        relative = "editor",
        width = 0.8,
        height = 0.6,
      },
      prompts = {
        QuickCommit = {
          prompt = "Write commit title message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          description = "Generate a quick commit message",
          mapping = ";c",
          close = true,
          selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
          end,
          callback = function(response, source)
            print("Source: ", source)
            print("Resonse: ", response)
          end,
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
