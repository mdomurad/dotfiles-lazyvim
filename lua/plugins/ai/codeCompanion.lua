-- ---------------------------------------------------------------------------
-- Git commit helpers
-- ---------------------------------------------------------------------------

--- Extract a plain string from a CodeCompanion AI response.
--- The response is either already a string or a table with a `content` field.
local function extract_commit_msg(response)
  local msg = response
  if type(msg) == "table" then
    msg = msg.content
    if type(msg) == "table" then
      msg = vim.inspect(msg)
    end
  end
  -- Strip surrounding whitespace / stray quotes
  msg = vim.trim(msg or "")
  return msg
end

--- Show a brief echo with commit message and list of files included in the
--- latest commit (mirrors the original CopilotChat echoCommitInfo helper).
local function echo_commit_info(msg)
  local handle = io.popen("git log -1 --name-only")
  local committed_files = handle and handle:read("*all") or ""
  if handle then
    handle:close()
  end
  vim.notify(
    "**Commit message:**\n```\n"
      .. msg
      .. "\n```"
      .. "\n\n**Files in last commit:**\n```\n"
      .. vim.trim(committed_files)
      .. "\n```",
    vim.log.levels.INFO,
    { title = "Git Commit" }
  )
end

--- Parse AI response into a `git commit` shell command and execute it.
--- The first line becomes the title (-m) and the remainder becomes the body (-m).
local function format_and_commit(msg)
  local lines = {}
  for s in msg:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  local commit_cmd = "git commit"
  if #lines > 0 then
    commit_cmd = commit_cmd .. ' -m "' .. lines[1] .. '"'
    table.remove(lines, 1)
  end
  if #lines > 0 then
    commit_cmd = commit_cmd .. ' -m "' .. table.concat(lines, " ") .. '"'
  end
  os.execute(commit_cmd)
end

--- Extract the last assistant message from a CodeCompanion chat instance.
local function last_ai_response(chat)
  for i = #chat.messages, 1, -1 do
    local m = chat.messages[i]
    if m.role ~= "user" and m.role ~= "system" then
      local content = m.content
      if type(content) == "table" then
        -- CodeCompanion may give structured content; flatten to string
        local parts = {}
        for _, part in ipairs(content) do
          if type(part) == "table" and part.text then
            table.insert(parts, part.text)
          elseif type(part) == "string" then
            table.insert(parts, part)
          end
        end
        content = table.concat(parts, "")
      end
      return content or ""
    end
  end
  return ""
end

--- Fire a hidden, auto-submitted CodeCompanion chat and call `on_done(msg)`
--- with the plain-text AI response once the request completes.
--- The chat is tagged so the history extension can filter it out.
local function ai_ask(prompt, on_done)
  require("codecompanion").chat({
    hidden = true,
    auto_submit = true,
    messages = {
      { role = "user", content = prompt },
    },
    callbacks = {
      on_created = function(chat)
        -- Mark this as an ephemeral commit-helper chat so the history
        -- extension's chat_filter can exclude it from being saved.
        chat._is_commit_helper = true
      end,
      on_completed = function(chat)
        vim.schedule(function()
          local raw = last_ai_response(chat)
          local msg = extract_commit_msg(raw)
          on_done(msg)
        end)
      end,
    },
  })
end

-- Conventional Commit prompt shared prefix
local CC_SYSTEM = "You are an expert at following the Conventional Commit specification."
  .. " Do not add any surrounding quotes."

--- Bind all commit shortcuts. Called once during setup.
local function setup_commit_keymaps()
  -- ;C  Stage ALL changes then commit with full message (title + body)
  vim.keymap.set("n", ";C", function()
    local staged = vim.fn.system("git diff --staged")
    local unstaged = vim.fn.system("git diff")
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a commit message with commitizen convention."
      .. " Make sure the title has maximum 72 characters and the body is wrapped at 72 characters."
      .. "\n\n### Staged diff\n"
      .. staged
      .. "\n\n### Unstaged diff\n"
      .. unstaged
    ai_ask(prompt, function(msg)
      vim.fn.system({ "git", "add", "-A" })
      format_and_commit(msg)
      echo_commit_info(msg)
    end)
  end, { desc = "Stage all and commit" })

  -- ;c  Commit only already-staged changes with full message (title + body)
  vim.keymap.set("n", ";c", function()
    local staged = vim.fn.system("git diff --staged")
    if vim.trim(staged) == "" then
      vim.notify("Nothing staged to commit.", vim.log.levels.WARN)
      return
    end
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a commit message with commitizen convention."
      .. " Make sure the title has maximum 72 characters and the body is wrapped at 72 characters."
      .. "\n\n### Staged diff\n"
      .. staged
    ai_ask(prompt, function(msg)
      format_and_commit(msg)
      echo_commit_info(msg)
    end)
  end, { desc = "Commit staged" })

  -- ;Q  Stage ALL changes then commit with title-only short message
  vim.keymap.set("n", ";Q", function()
    local staged = vim.fn.system("git diff --staged")
    local unstaged = vim.fn.system("git diff")
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a short commit TITLE only (no body) with commitizen convention."
      .. " Provide information about scope. If only one file was updated provide its name."
      .. " Maximum 50 characters."
      .. "\n\n### Staged diff\n"
      .. staged
      .. "\n\n### Unstaged diff\n"
      .. unstaged
    ai_ask(prompt, function(msg)
      vim.fn.system({ "git", "add", "-A" })
      vim.fn.system({ "git", "commit", "-m", msg })
      echo_commit_info(msg)
    end)
  end, { desc = "Stage all and commit (title only)" })

  -- ;q  Commit staged changes with title-only short message
  vim.keymap.set("n", ";q", function()
    local staged = vim.fn.system("git diff --staged")
    if vim.trim(staged) == "" then
      vim.notify("Nothing staged to commit.", vim.log.levels.WARN)
      return
    end
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a short commit TITLE only (no body) with commitizen convention."
      .. " Provide information about scope. If only one file was updated provide its name."
      .. " Maximum 72 characters."
      .. "\n\n### Staged diff\n"
      .. staged
    ai_ask(prompt, function(msg)
      vim.fn.system({ "git", "commit", "-m", msg })
      echo_commit_info(msg)
    end)
  end, { desc = "Commit staged (title only)" })
end

-- ---------------------------------------------------------------------------
-- Plugin spec
-- ---------------------------------------------------------------------------

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    config = function()
      require("codecompanion").setup({
        interactions = {
          chat = {
            adapter = {
              name = "copilot",
              model = "gpt-5.4-mini",
            },
          },
          background = {
            adapter = {
              name = "copilot",
              model = "gpt-5.4-mini",
            },
          },
          inline = {
            adapter = "copilot",
          },
          cmd = { adapter = "copilot" },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              -- MCP Tools
              make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true, -- Show tool results directly in chat buffer
              format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              make_vars = false, -- Convert MCP resources to #variables for prompts
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
          history = {

            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = "gh",
              -- Keymap to save the current chat manually (when auto_save is disabled)
              save_chat_keymap = "sc",
              -- Save all chats by default (disable to save only manually using 'sc')
              auto_save = true,
              -- Number of days after which chats are automatically deleted (0 to disable)
              expiration_days = 0,
              -- Picker interface (auto resolved to a valid picker)
              picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
              ---Optional filter function to control which chats are shown when browsing
              chat_filter = function(chat_data)
                -- Exclude the ephemeral hidden chats used by commit shortcuts
                return not (chat_data and chat_data._is_commit_helper)
              end,
              -- Customize picker keymaps (optional)
              picker_keymaps = {
                rename = { n = "r", i = "<M-r>" },
                delete = { n = "d", i = "<M-d>" },
                duplicate = { n = "<C-y>", i = "<C-y>" },
              },
              ---Automatically generate titles for new chats
              auto_generate_title = false,
              title_generation_opts = {
                ---Adapter for generating titles (defaults to current chat adapter)
                adapter = nil, -- "copilot"
                ---Model for generating titles (defaults to current chat model)
                model = "gpt-5.4-mini", -- "gpt-4o"
                ---Number of user prompts after which to refresh the title (0 to disable)
                refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                ---Maximum number of times to refresh the title (default: 3)
                max_refreshes = 3,
                format_title = function(original_title)
                  -- this can be a custom function that applies some custom
                  -- formatting to the title.
                  return original_title
                end,
              },
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = false,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              ---Directory path to save the chats
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
              ---Enable detailed logging for history extension
              enable_logging = false,

              -- Summary system
              summary = {
                -- Keymap to generate summary for current chat (default: "gcs")
                create_summary_keymap = "gcs",
                -- Keymap to browse summaries (default: "gbs")
                browse_summaries_keymap = "gbs",

                generation_opts = {
                  adapter = nil, -- defaults to current chat adapter
                  model = nil, -- defaults to current chat model
                  context_size = 90000, -- max tokens that the model supports
                  include_references = true, -- include slash command content
                  include_tool_outputs = true, -- include tool execution results
                  system_prompt = nil, -- custom system prompt (string or function)
                  format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
                },
              },
            },
          },
        },
      })
      require("mcphub").setup({ port = 37373 })

      -- Patch the copilot adapter module (cached in package.loaded) to
      -- disable top_p for gpt-5.x and o4 reasoning models, which reject it.
      -- The built-in guard only covers o1; this widens it.
      local ok, copilot_adapter = pcall(require, "codecompanion.adapters.http.copilot")
      if ok and copilot_adapter.schema and copilot_adapter.schema.top_p then
        copilot_adapter.schema.top_p.enabled = function(self)
          local model = self.schema.model.default
          if type(model) == "function" then
            model = model()
          end
          model = model or ""
          return not (vim.startswith(model, "o1") or vim.startswith(model, "o4") or vim.startswith(model, "gpt-5"))
        end
      end

      -- Setup git commit shortcuts (ported from CopilotChat)
      setup_commit_keymaps()

      -- keymaps
      local which_key = require("which-key")

      which_key.add({
        mode = { "n", "v" },
        { "<leader>oc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
        { "<leader>oa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
        { "<leader>oh", "<cmd>CodeCompanionHistory<cr>", desc = "CodeCompanion History" },
        { "<leader>od", ":'<,'>CodeCompanion Add documentation for the selected code<cr>", desc = "Add docs" },
        { "<leader>or", ":'<,'>CodeCompanion Review the selected code<cr>", desc = "Review selection" },
        {
          "<leader>og",
          ":'<,'>CodeCompanion Rewrite text to improve clarity and style. Fix all grammar and spelling mistakes. Use language of the original text<cr>",
          desc = "Fix grammar and spelling",
        },
        { "<leader>ot", ":'<,'>CodeCompanion Add tests for the selected code<cr>", desc = "Add tests" },
        {
          "<leader>of",
          ":'<,'>CodeCompanion There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.<cr>",
          desc = "Fix bugs",
        },
        {
          "<leader>oo",
          ":'<,'>CodeCompanion Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.<cr>",
          desc = "Optimize code",
        },
        {
          "<leader>ox",
          ":'<,'>CodeCompanion Write an explanation for the selected code as paragraphs of text<cr>",
          desc = "Explain selection",
        },
      })
      which_key.add({
        mode = "v",
        { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Chat Add" },
      })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest --native-tls", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
}
