local function extract_commit_msg(response)
  local msg = response
  if type(msg) == "table" then
    msg = msg.content
    if type(msg) == "table" then
      msg = vim.inspect(msg)
    end
  end
  return msg
end

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

local copilotVim = {
  "github/copilot.vim",
}

local copilotChat = {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
  },
  opts = {
    debug = true, -- Enable debugging
    window = {
      layout = "vertical",
      relative = "editor",
      width = 0.8,
      height = 0.6,
    },
    headers = {
      user = "👤 You",
      assistant = "🤖 Copilot",
      tool = "🔧 Tool",
    },

    separator = "━━",
    auto_fold = true, -- Automatically folds non-assistant messages
    mappings = {
      complete = {
        insert = "<C-z>",
      },
    },
    prompts = {
      FixGrammar = {
        prompt = "/COPILOT_GENERATE Rewrite text to improve clarity and style. Fix all grammar and spelling mistakes. Use language of the original text. Remove line numbers.",
        description = "Fix spelling and grammar",
        mapping = "<leader>og",
        close = true,
        selection = function(source)
          local select = require("CopilotChat.select")
          return select.visual(source) or select.line(source)
        end,
      },
      FullCommit = {
        prompt = "You are an expert at following the Conventional Commit specification. Given the git diff listed below, write commit message for the change:\n#gitdiff:staged\n#gitdiff:unstaged\n with commitizen convention. Make sure the title has maximum 72 characters and message is wrapped at 72 characters. Do not add any surrounding quotes.",
        description = "Stage all and commit",
        mapping = ";C",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")
          vim.schedule(function()
            vim.fn.system({ "git", "add", "-A" })
            local msg = extract_commit_msg(response)
            formatGitResponse(msg)
            copilot.close()
            echoCommitInfo(msg)
          end)
        end,
      },
      FullCommitStaged = {
        prompt = "You are an expert at following the Conventional Commit specification. Given the git diff listed below, write commit message for the change:\n#gitdiff:staged\nwith commitizen convention. Make sure the title has maximum 72 characters and message is wrapped at 72 characters . Do not add any surrounding quotes.",
        description = "Commit staged",
        mapping = ";c",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")

          vim.schedule(function()
            local msg = extract_commit_msg(response)
            formatGitResponse(msg)
            copilot.close()
            echoCommitInfo(msg)
          end)
        end,
      },
      QuickCommit = {
        prompt = "You are an expert at following the Conventional Commit specification. Given the git diff listed below, write commit title for the change:\n#gitdiff:staged\n#gitdiff:unstaged\nwith commitizen convention. Provide information about scope of the change. If only one file was updated provide its name. Make sure the title has maximum 50 characters. Do not add any surrounding quotes.",
        description = "Stage all and commit with title only",
        mapping = ";Q",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")

          vim.schedule(function()
            vim.fn.system({ "git", "add", "-A" })
            local msg = extract_commit_msg(response)
            vim.fn.system({ "git", "commit", "-m", msg })
            copilot.close()
            echoCommitInfo(msg)
          end)
        end,
      },
      QuickCommitStaged = {
        prompt = "You are an expert at following the Conventional Commit specification. Given the git diff listed below, write commit title for the change with commitizen convention for changes:\n#gitdiff:staged\nProvide information about scope of the change. If only one file was updated provide its name. Make sure the title has maximum 72 characters. Do not add any surrounding quotes.",
        description = "Commit staged with title only",
        mapping = ";q",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")
          vim.schedule(function()
            local msg = extract_commit_msg(response)
            vim.inspect(msg)
            vim.fn.system({ "git", "commit", "-m", msg })

            copilot.close()
            echoCommitInfo(msg)
          end)
        end,
      },
    },
  },
}

return { copilotVim, copilotChat }

