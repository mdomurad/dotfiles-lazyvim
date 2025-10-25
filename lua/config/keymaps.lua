local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local which_key = require("which-key")
local user = os.getenv("USERNAME")

----------------------------------------------------------------------------------------------------

--- This function initiates a quick chat.
-- It prompts the user for input and if the input is not an empty string,
-- it calls the 'ask' function from the 'CopilotChat' module with the user's input
-- and the current buffer as the selection.
-- @param None
-- @return None
function quickChat()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end

----------------------------------------------------------------------------------------------------

--- This function enables key mappings for ChatGPT.
local function enableChatGpt()
  which_key.add({
    mode = { "v", "n" },
    {
      { "<leader>o", group = "ChatGPT" },
      { "<leader>oe", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
      { "<leader>oc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
    },
  })

  which_key.add({
    mode = { "v" },
    { "<leader>o", group = "ChatGPT" },
    { "<leader>or", ":'<,'>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
    { "<leader>od", ":'<,'>ChatGPTRun docstring<CR>", desc = "Docstring" },
    { "<leader>of", ":'<,'>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
    { "<leader>ok", ":'<,'>ChatGPTRun keywords<CR>", desc = "Keywords" },
    { "<leader>ol", ":'<,'>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
    { "<leader>oo", ":'<,'>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
    { "<leader>oq", ":'<,'>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
    { "<leader>og", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
    { "<leader>os", ":'<,'>ChatGPTRun summarize<CR>", desc = "Summarize" },
    { "<leader>ot", ":'<,'>ChatGPTRun translate<CR>", desc = "Translate" },
    { "<leader>ox", ":'<,'>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
  })
end

----------------------------------------------------------------------------------------------------
--- Key mappings

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

keymap.set("n", "s", require("substitute").operator, { noremap = true })
keymap.set("n", "ss", require("substitute").line, { noremap = true })
keymap.set("n", "S", require("substitute").eol, { noremap = true })
keymap.set("x", "s", require("substitute").visual, { noremap = true })

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)

--- Helper to build a CopilotChat prompt for the next diagnostic.
-- @return prompt string or nil if no diagnostic found
local function build_next_diagnostic_prompt()
  local diagnostic = vim.diagnostic.get_next()
  if not diagnostic then
    return nil
  end
  local prompt = "/COPILOT_GENERATE Fix diagnostic: "
    .. (diagnostic.code or "")
    .. " : "
    .. (diagnostic.message or "")
    .. "\n\nDiagnostic line location start: "
    .. diagnostic.lnum + 1

  if diagnostic.end_lnum then
    prompt = prompt .. " End: " .. diagnostic.end_lnum + 1
  end
  return prompt
end

--- Fixes the next diagnostic using the buffer as context.
function CopilotFixNextDiagnosticProvideBuffer()
  local prompt = build_next_diagnostic_prompt()
  if prompt then
    require("CopilotChat").ask(prompt, { selection = require("CopilotChat.select").buffer })
  end
end

--- Fixes the next diagnostic using the current selection as context.
function CopilotFixNextDiagnosticProvideSelection()
  local prompt = build_next_diagnostic_prompt()
  if prompt then
    require("CopilotChat").ask(prompt, { selection = require("CopilotChat.select").visual })
  end
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

-- Build .NET project for Revit using Telescope to select build type and version
function DotnetBuildRevitTelescope()
  local build_types = { "debug", "release" }
  local versions = { "2020", "2021", "2022", "2023", "2024", "2025" }

  pickers
    .new({}, {
      prompt_title = "Select Build Type",
      finder = finders.new_table({ results = build_types }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          local build_type = selection[1]
          actions._close(prompt_bufnr)
          pickers
            .new({}, {
              prompt_title = "Select Revit Version",
              finder = finders.new_table({ results = versions }),
              sorter = conf.generic_sorter({}),
              attach_mappings = function(prompt_bufnr2, map2)
                actions.select_default:replace(function()
                  local selection2 = action_state.get_selected_entry()
                  local versionYear = selection2[1]
                  local version = versionYear:gsub("^20", "")
                  actions._close(prompt_bufnr2)
                  DotnetBuildRevit(build_type, version)
                end)
                return true
              end,
            })
            :find()
        end)
        return true
      end,
    })
    :find()
end

-- Helper function to run dotnet build command for Revit
function DotnetBuildRevit(build_type, version)
  local config = (build_type == "release" and "Release" or "Debug") .. " R" .. version
  local cmd = 'dotnet build -c "' .. config .. '"'
  vim.cmd("vsplit")
  vim.cmd("enew")
  vim.fn.termopen(cmd)
end

----------------------------------------------------------------------------------------------------
--- WhichKey mappings
-- Normal mode mappings
which_key.add({
  { ";x", "<cmd>only<CR>", desc = "Hide Other Buffers" },
  { "<leader>bo", "<cmd>bufdo e | %bd | e#<CR>", desc = "Delete Other Buffers" },
  { "<leader>gP", "<cmd>G push<CR>", desc = "Git Push" },
  { "<leader>ga", "<cmd>Gwrite<CR>", desc = "Stage current file" },
  { "<leader>gA", "<cmd>G add --all<CR>", desc = "Stage all files" },
  { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git Diff" },
  { "<leader>gp", "<cmd>G pull<CR>", desc = "Git pull --rebase" },
  { "<leader>gr", "<cmd>G commit --amend<CR>", desc = "Reword latest commit" },
  { "<leader>gR", "<cmd>G reset --soft HEAD~1<CR>", desc = "Reset latest commit" },

  -- NET
  { "<leader>r", group = "net" },
  {
    "<leader>rb",
    function()
      DotnetBuildRevitTelescope()
    end,
    desc = "Revit dotnet build",
  },

  -- easy-dotnet
  -- coordinate with testrunner mappings located in easy-dotnet setup
  { "<leader>rtt", "<cmd>Dotnet test<CR>", desc = "Run Tests" },
  { "<leader>rtr", "<cmd>Dotnet testrunner<CR>", desc = "Toggle Test Runner" },

  -- Color-picker
  { "<leader>cp", "<cmd>PickColor<cr>", desc = "Pick Color" },
  { "<leader>cP", "<cmd>PickColorInsert<cr>", desc = "Pick Color and Insert" },

  -- Flogit
  { "gl", "<cmd>Flogsplit<CR>", desc = "Flogsplit" },

  -- Flote
  { ";n", "<cmd>Flote<CR>", desc = "Flote" },
  { ";N", "<cmd>Flote global<CR>", desc = "Flote" },

  -- Oil
  { ";o", "<cmd>Oil<CR>", desc = "Oil" },

  -- Diagnostic
  { ";l", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
  { ";j", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Previous Diagnostic" },
})

-- [AI]

-- [CodeCompanion]
vim.keymap.set({ "n", "v" }, ";A", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, ";a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, ";h", "<cmd>CodeCompanionHistory<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- [Copilot chat]
-- if user ~= "ianus" then
which_key.add({
  mode = { "n" },
  { "<leader>o", group = "CopilotChat" },
  { "<leader>oc", "<cmd>CopilotChat<CR>", desc = "CopilotChat" },
  {
    "<leader>oa",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
    desc = "Prompt Actions",
  },
  { "<leader>ogs", "<cmd>CopilotChatCommitStaged<CR>", desc = "Commit Message Staged" },
  {
    "<leader>oh",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').help_actions())<CR>",
    desc = "Help Actions",
  },
  { "<leader>ol", "<cmd>CopilotChatLoad chat<CR>", desc = "Load" },
  { "<leader>ogc", "<cmd>CopilotChatCommit<CR>", desc = "Commit Message" },
  { "<leader>os", "<cmd>CopilotChatSave chat<CR>", desc = "Save" },
  {
    "<leader>oi",
    function()
      CopilotFixNextDiagnosticProvideBuffer()
    end,
    desc = "Fix Next Diagnostic",
  },
})

which_key.add({
  mode = { "v" },
  { "<leader>o", group = "CopilotChat" },
  {
    "<leader>oa",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
    desc = "Prompt actions",
  },
  { "<leader>oc", ":'<,'>CopilotChat<CR>", desc = "CopilotChat" },
  {
    "<leader>o1",
    function()
      quickChat()
    end,
    desc = "CopilotChat - Quick chat",
  },
  { "<leader>od", ":'<,'>CopilotChatDocs<CR>", desc = "Docstring" },
  { "<leader>of", ":'<,'>CopilotChatFix<CR>", desc = "Fix Bugs" },
  { "<leader>oo", ":'<,'>CopilotChatOptimize<CR>", desc = "Optimize Code" },
  { "<leader>ot", ":'<,'>CopilotChatTests<CR>", desc = "Add Tests" },
  { "<leader>or", ":'<,'>CopilotChatReview<CR>", desc = "Review Code" },
  { "<leader>ox", ":'<,'>CopilotChatExplain<CR>", desc = "Explain Code" },
  {
    "<leader>oi",
    function()
      CopilotFixNextDiagnosticProvideSelection()
    end,
    desc = "Fix Next Diagnostic",
  },
})
which_key.add({
  mode = { "v", "n" },
})
-- end

-- Keymap to exit terminal mode
keymap.set("t", "<C-q>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)
