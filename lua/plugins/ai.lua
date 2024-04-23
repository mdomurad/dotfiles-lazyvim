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
          prompt = "Write commit title for the change with commitizen convention. Make sure the title has maximum 50 characters. Do not add any surrounding quotes.",
          description = "Stage all and commit with title only",
          mapping = ";q",
          close = true,
          selection = function(source)
            os.execute("git add -A")
            return require("CopilotChat.select").gitdiff(source, true)
          end,
          callback = function(response, source)
            local copilot = require("CopilotChat")
            os.execute('git commit -m "' .. response .. '"')

            copilot.close()
            -- Get the list of files in the last commit
            local committedFiles = io.popen("git log -1 --name-only"):read("*all")
            vim.api.nvim_echo({ { "Commit message: " .. response, "HighlightGroup" } }, true, {})
            vim.api.nvim_echo({ { "Files in the last commit:\n" .. committedFiles, "HighlightGroup" } }, true, {})
          end,
        },
        QuickCommitStaged = {
          prompt = "Write commit title for the change with commitizen convention. Make sure the title has maximum 50 characters. Do not add any surrounding quotes.",
          description = "Commit staged with title only",
          mapping = ";c",
          close = true,
          selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
          end,
          callback = function(response, source)
            local copilot = require("CopilotChat")
            os.execute('git commit -m "' .. response .. '"')

            copilot.close()
            -- Get the list of files in the last commit
            local committedFiles = io.popen("git log -1 --name-only"):read("*all")
            vim.api.nvim_echo({ { "Commit message: " .. response, "HighlightGroup" } }, true, {})
            vim.api.nvim_echo({ { "Files in the last commit:\n" .. committedFiles, "HighlightGroup" } }, true, {})
          end,
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
