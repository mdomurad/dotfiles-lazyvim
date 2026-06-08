-- ---------------------------------------------------------------------------
-- Adapter state and fallback for ianus
-- ---------------------------------------------------------------------------

local ai_config = require("config.ai")
local is_ianus = ai_config.is_ianus

-- Track preferred chat adapter for ianus (codex or deepseek_fast)
local _ianus_chat_adapter = "codex"

local function copilot_adapter(model)
  return { name = "copilot", model = model }
end

local function error_message(err)
  if type(err) == "table" then
    return vim.trim(vim.inspect(err))
  end
  return vim.trim(tostring(err or ""))
end

local function is_supported_model_error(err)
  local text = error_message(err)
  return text:find("unsupported_api_for_model", 1, true)
    or text:find("not accessible via the /chat/completions endpoint", 1, true)
    or text:find("Timeout waiting for models", 1, true)
end

--- Toggle between codex and deepseek for ianus
local function toggle_chat_adapter()
  if not is_ianus then
    vim.notify("Adapter toggle is only available for ianus user", vim.log.levels.WARN)
    return
  end

  if _ianus_chat_adapter == "codex" then
    _ianus_chat_adapter = "deepseek_fast"
    vim.notify("Switched to DeepSeek adapter", vim.log.levels.INFO, { title = "CodeCompanion" })
  else
    _ianus_chat_adapter = "codex"
    vim.notify("Switched to Codex adapter", vim.log.levels.INFO, { title = "CodeCompanion" })
  end
end

--- Show current adapter status for ianus
local function show_adapter_status()
  if not is_ianus then
    vim.notify("Adapter status is only relevant for ianus user", vim.log.levels.WARN)
    return
  end

  local status = _ianus_chat_adapter == "codex" and "Codex (ChatGPT)" or "DeepSeek"
  vim.notify(
    "Current chat adapter: " .. status .. "\nToggle with <leader>om",
    vim.log.levels.INFO,
    { title = "CodeCompanion" }
  )
end

--- Fallback to deepseek if codex fails for ianus
local function try_fallback_adapter()
  if not is_ianus or _ianus_chat_adapter ~= "codex" then
    return false
  end

  vim.notify(
    "Codex rate limit hit, falling back to DeepSeek",
    vim.log.levels.WARN,
    { title = "CodeCompanion" }
  )
  return "deepseek_fast"
end

--- Open CodeCompanion chat with dynamic adapter for ianus
local function open_chat()
  if not is_ianus then
    -- Non-ianus users: use standard command
    vim.cmd("CodeCompanionChat Toggle")
    return
  end

  -- Ianus: use dynamic adapter with fallback on error
  require("codecompanion").chat({
    adapter = _ianus_chat_adapter,
    callbacks = {
      on_error = function(err)
        local fallback = try_fallback_adapter()
        if fallback then
          -- Retry with fallback
          _ianus_chat_adapter = fallback
          vim.schedule(function()
            require("codecompanion").chat({ adapter = fallback })
          end)
        else
          vim.schedule(function()
            vim.notify(
              "Chat failed: " .. error_message(err),
              vim.log.levels.ERROR,
              { title = "CodeCompanion" }
            )
          end)
        end
      end,
    },
  })
end

-- ---------------------------------------------------------------------------
-- Git commit helpers
-- ---------------------------------------------------------------------------

--- Extract a plain string from a CodeCompanion AI response.
local function extract_commit_msg(response)
  local msg = response
  if type(msg) == "table" then
    msg = msg.content
    if type(msg) == "table" then
      msg = vim.inspect(msg)
    end
  end
  msg = vim.trim(msg or "")
  return msg
end

local function echo_commit_info(msg)
  local handle = io.popen("git log -1 --name-only")
  local committed_files = handle and handle:read("*all") or ""
  if handle then handle:close() end
  vim.notify(
    "**Commit message:**\n```\n" .. msg .. "\n```"
      .. "\n\n**Files in last commit:**\n```\n"
      .. vim.trim(committed_files) .. "\n```",
    vim.log.levels.INFO,
    { title = "Git Commit" }
  )
end

local function format_and_commit(msg)
  local lines = {}
  for s in msg:gmatch("[^\r\n]+") do table.insert(lines, s) end
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

local function last_ai_response(chat)
  for i = #chat.messages, 1, -1 do
    local m = chat.messages[i]
    if m.role ~= "user" and m.role ~= "system" then
      local content = m.content
      if type(content) == "table" then
        local parts = {}
        for _, part in ipairs(content) do
          if type(part) == "table" and part.text then table.insert(parts, part.text)
          elseif type(part) == "string" then table.insert(parts, part) end
        end
        content = table.concat(parts, "")
      end
      return content or ""
    end
  end
  return ""
end

--- Fire a hidden auto-submitted chat for commit helpers.
--- ianus: uses deepseek_fast HTTP adapter (fast, no ACP startup overhead).
--- Others: uses a lightweight Copilot model first, then a supported fallback
--- if that model is rejected.
local function ai_ask(prompt, on_done)
  local attempt_count = 0

  local function try_request(adapter_override)
    attempt_count = attempt_count + 1

    local adapter = adapter_override or (is_ianus and "deepseek_fast" or copilot_adapter(ai_config.codecompanion.quick_commit))
    require("codecompanion").chat({
      hidden = true,
      auto_submit = true,
      adapter = adapter,
      messages = { { role = "user", content = prompt } },
      callbacks = {
        on_created = function(chat)
          chat._is_commit_helper = true
        end,
        on_completed = function(chat)
          vim.schedule(function()
            local raw = last_ai_response(chat)
            local msg = extract_commit_msg(raw)
            on_done(msg)
          end)
        end,
        on_error = function(err)
          local err_text = error_message(err)

          -- Retry once with a more general supported Copilot model if the
          -- lightweight model is rejected by the endpoint.
          if not is_ianus
            and attempt_count == 1
            and type(adapter) == "table"
            and adapter.name == "copilot"
            and adapter.model == ai_config.codecompanion.quick_commit
            and is_supported_model_error(err_text)
          then
            vim.schedule(function()
              vim.notify(
                "Copilot rejected " .. adapter.model .. " for quick commit; retrying with "
                  .. ai_config.codecompanion.quick_commit_fallback .. ".",
                vim.log.levels.WARN,
                { title = "CodeCompanion" }
              )
              try_request(copilot_adapter(ai_config.codecompanion.quick_commit_fallback))
            end)
            return
          end

          vim.schedule(function()
            vim.notify(
              "Commit message generation failed: " .. err_text .. "\nQuick commit needs a supported model.",
              vim.log.levels.ERROR,
              { title = "CodeCompanion" }
            )
          end)
        end,
      },
    })
  end

  try_request()
end

local CC_SYSTEM = "You are an expert at following the Conventional Commit specification."
  .. " Do not add any surrounding quotes."

local function setup_commit_keymaps()
  vim.keymap.set("n", ";C", function()
    local staged = vim.fn.system("git diff --staged")
    local unstaged = vim.fn.system("git diff")
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a commit message with commitizen convention."
      .. " Make sure the title has maximum 72 characters and the body is wrapped at 72 characters."
      .. "\n\n### Staged diff\n" .. staged
      .. "\n\n### Unstaged diff\n" .. unstaged
    ai_ask(prompt, function(msg)
      vim.fn.system({ "git", "add", "-A" })
      format_and_commit(msg)
      echo_commit_info(msg)
    end)
  end, { desc = "Stage all and commit" })

  vim.keymap.set("n", ";c", function()
    local staged = vim.fn.system("git diff --staged")
    if vim.trim(staged) == "" then
      vim.notify("Nothing staged to commit.", vim.log.levels.WARN)
      return
    end
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a commit message with commitizen convention."
      .. " Make sure the title has maximum 72 characters and the body is wrapped at 72 characters."
      .. "\n\n### Staged diff\n" .. staged
    ai_ask(prompt, function(msg)
      format_and_commit(msg)
      echo_commit_info(msg)
    end)
  end, { desc = "Commit staged" })

  vim.keymap.set("n", ";Q", function()
    local staged = vim.fn.system("git diff --staged")
    local unstaged = vim.fn.system("git diff")
    local prompt = CC_SYSTEM
      .. "\n\nGiven the git diff below, write a short commit TITLE only (no body) with commitizen convention."
      .. " Provide information about scope. If only one file was updated provide its name."
      .. " Maximum 50 characters."
      .. "\n\n### Staged diff\n" .. staged
      .. "\n\n### Unstaged diff\n" .. unstaged
    ai_ask(prompt, function(msg)
      vim.fn.system({ "git", "add", "-A" })
      vim.fn.system({ "git", "commit", "-m", msg })
      echo_commit_info(msg)
    end)
  end, { desc = "Stage all and commit (title only)" })

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
      .. "\n\n### Staged diff\n" .. staged
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
      -- -----------------------------------------------------------------------
      -- Adapter and interaction config — split by user
      -- -----------------------------------------------------------------------

      -- Custom adapters for ianus only
      local adapters = is_ianus and {
        -- DeepSeek V4 Flash with thinking disabled: fast, cheap HTTP fallback
        -- used for inline edits, background tasks, cmd, and commit helpers.
        deepseek_fast = function()
          return require("codecompanion.adapters").extend("deepseek", {
            schema = {
              model = { default = "deepseek-v4-flash" },
              ["thinking.type"] = { default = "disabled" },
            },
          })
        end,
        -- Codex ACP adapter authenticated via ChatGPT subscription (no API billing).
        -- Model selection is handled by codex-acp based on your ChatGPT subscription.
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chatgpt",
            },
          })
        end,
      } or {}

      -- Interaction adapters
      -- For ianus: chat adapter can be dynamically switched via toggle_chat_adapter()
      -- Default is codex, can fallback to deepseek_fast on rate limits.
      -- For non-ianus: use the code-focused Copilot model for chat/review tasks,
      -- but keep titles and summaries on the lightweight model.
      local chat_adapter = is_ianus
        and { name = "codex" }  -- codex-acp auto-selects model based on subscription
        or  { name = "copilot", model = ai_config.codecompanion.chat }

      local bg_adapter = is_ianus
        and { name = "deepseek_fast", model = "deepseek-v4-flash" }
        or  { name = "copilot",       model = ai_config.codecompanion.background }

      local inline_adapter = is_ianus and "deepseek_fast" or { name = "copilot", model = ai_config.codecompanion.chat }
      local title_model    = is_ianus and "deepseek-v4-flash" or ai_config.codecompanion.title
      local title_adapter  = is_ianus and "deepseek_fast" or nil

      -- CLI agent (ianus gets a codex terminal agent, others get nothing extra)
      local cli_opts = is_ianus and {
        agent = "codex",
        agents = {
          codex = {
            cmd = "codex",
            args = {},
            description = "OpenAI Codex CLI (ChatGPT subscription)",
            provider = "terminal",
          },
        },
      } or {}

      -- -----------------------------------------------------------------------
      -- Setup
      -- -----------------------------------------------------------------------
      require("codecompanion").setup({
        adapters = adapters,
        interactions = {
          chat       = { adapter = chat_adapter },
          background = { adapter = bg_adapter },
          inline     = { adapter = inline_adapter },
          cmd        = { adapter = inline_adapter },
          cli        = cli_opts,
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_tools = true,
              show_server_tools_in_chat = true,
              add_mcp_prefix_to_tool_names = false,
              show_result_in_chat = true,
              format_tool = nil,
              make_vars = false,
              make_slash_commands = true,
            },
          },
          history = {
            enabled = true,
            opts = {
              keymap = "gh",
              save_chat_keymap = "sc",
              auto_save = true,
              expiration_days = 0,
              picker = "snacks",
              chat_filter = function(chat_data)
                return not (chat_data and chat_data._is_commit_helper)
              end,
              picker_keymaps = {
                rename    = { n = "r",    i = "<M-r>" },
                delete    = { n = "d",    i = "<M-d>" },
                duplicate = { n = "<C-y>", i = "<C-y>" },
              },
              auto_generate_title = false,
              title_generation_opts = {
                adapter          = title_adapter,
                model            = title_model,
                refresh_every_n_prompts = 0,
                max_refreshes    = 3,
                format_title = function(t) return t end,
              },
              continue_last_chat       = false,
              delete_on_clearing_chat  = false,
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
              enable_logging = false,
              summary = {
                create_summary_keymap  = "gcs",
                browse_summaries_keymap = "gbs",
                generation_opts = {
                  adapter           = title_adapter,
                  model             = title_model,
                  context_size      = 90000,
                  include_references = true,
                  include_tool_outputs = true,
                  system_prompt     = nil,
                  format_summary    = nil,
                },
              },
            },
          },
        },
      })

      require("mcphub").setup({ port = 37373 })

      -- Patch the copilot adapter to disable top_p for gpt-5.x / o4 models
      -- which reject it. Only needed for users still on copilot (not ianus).
      if not is_ianus then
        local ok, copilot_adapter = pcall(require, "codecompanion.adapters.http.copilot")
        if ok and copilot_adapter.schema and copilot_adapter.schema.top_p then
          copilot_adapter.schema.top_p.enabled = function(self)
            local model = self.schema.model.default
            if type(model) == "function" then model = model() end
            model = model or ""
            return not (
              vim.startswith(model, "o1")
              or vim.startswith(model, "o4")
              or vim.startswith(model, "gpt-5")
            )
          end
        end
      end

      setup_commit_keymaps()

      -- Keymaps
      local which_key = require("which-key")
      which_key.add({
        mode = { "n", "v" },
        { "<leader>oc", open_chat, desc = "Toggle CodeCompanion Chat" },
        { "<leader>oa", "<cmd>CodeCompanionActions<cr>",       desc = "CodeCompanion Actions" },
        { "<leader>oh", "<cmd>CodeCompanionHistory<cr>",       desc = "CodeCompanion History" },
        { "<leader>od", ":'<,'>CodeCompanion Add documentation for the selected code<cr>",          desc = "Add docs" },
        { "<leader>or", ":'<,'>CodeCompanion Review the selected code<cr>",                         desc = "Review selection" },
        { "<leader>og", ":'<,'>CodeCompanion Rewrite text to improve clarity and style. Fix all grammar and spelling mistakes. Use language of the original text<cr>", desc = "Fix grammar and spelling" },
        { "<leader>ot", ":'<,'>CodeCompanion Add tests for the selected code<cr>",                  desc = "Add tests" },
        { "<leader>of", ":'<,'>CodeCompanion There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.<cr>", desc = "Fix bugs" },
        { "<leader>oo", ":'<,'>CodeCompanion Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.<cr>",             desc = "Optimize code" },
        { "<leader>ox", ":'<,'>CodeCompanion Write an explanation for the selected code as paragraphs of text<cr>", desc = "Explain selection" },
      })
      which_key.add({
        mode = "v",
        { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Chat Add" },
      })
      
      -- Adapter toggle for ianus (under <leader>o with other CodeCompanion keys)
      if is_ianus then
        which_key.add({
          { "<leader>om", toggle_chat_adapter, desc = "Toggle Codex/DeepSeek" },
          { "<leader>oi", show_adapter_status, desc = "Show Adapter Status" },
        })
      end

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
    dependencies = { "nvim-lua/plenary.nvim" },
    build = "npm install -g mcp-hub@latest --native-tls",
    config = function()
      require("mcphub").setup()
    end,
  },
}
