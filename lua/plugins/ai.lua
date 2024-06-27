local function echoCommitInfo(response)
  -- Get the list of files in the last commit
  local committedFiles = io.popen("git log -1 --name-only"):read("*all")
  vim.api.nvim_echo({ { "Commit message: " .. response, "HighlightGroup" } }, true, {})
  vim.api.nvim_echo({ { "Files in the last commit:\n" .. committedFiles, "HighlightGroup" } }, true, {})
end

local function formatGitResponse(response)
  -- Split the response into lines
  local lines = {}
  for s in response:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  -- Construct the git commit command with the first line as a separate -m argument and the rest as another -m argument
  local commitCmd = "git commit"
  if #lines > 0 then
    commitCmd = commitCmd .. ' -m "' .. lines[1] .. '"'
    table.remove(lines, 1)
  end
  if #lines > 0 then
    commitCmd = commitCmd .. ' -m "' .. table.concat(lines, " ") .. '"'
  end

  -- Execute the git commit command
  os.execute(commitCmd)
end

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
        FixGrammar = {
          prompt = "/COPILOT_GENERATE Rewrite text to improve clarity and style. Fix all grammar and spelling mistakes.",
          description = "Fix spelling and grammar",
          mapping = "<leader>tg",
          close = true,
          selection = function(source)
            local select = require("CopilotChat.select")
            return select.visual(source) or select.line(source)
          end,
        },
        FullCommit = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Do not add any surrounding quotes.",
          description = "Stage all and commit",
          mapping = ";d",
          close = true,
          selection = function(source)
            os.execute("git add -A")
            return require("CopilotChat.select").gitdiff(source, true)
          end,
          callback = function(response, source)
            local copilot = require("CopilotChat")

            formatGitResponse(response)

            copilot.close()
            echoCommitInfo(response)
          end,
        },
        FullCommitStaged = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Do not add any surrounding quotes.",
          description = "Commit staged",
          mapping = ";a",
          close = true,
          selection = selection,
          callback = function(response, source)
            local copilot = require("CopilotChat")

            formatGitResponse(response)

            copilot.close()
            echoCommitInfo(response)
          end,
        },
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
            echoCommitInfo(response)
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
            echoCommitInfo(response)
          end,
        },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
