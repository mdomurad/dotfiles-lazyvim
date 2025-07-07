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

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

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

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)

--- Fixes the next diagnostic in the buffer using CopilotChat.
-- This function retrieves the next diagnostic and sends it to CopilotChat
-- for an AI-generated fix suggestion.
function CopilotFixNextDiagnostic()
  local diagnostic = vim.diagnostic.get_next()
  if diagnostic then
    local prompt = "/COPILOT_FIX Fix diagnostic: "
      .. (diagnostic.code or "")
      .. " : "
      .. (diagnostic.message or "")
      .. "\n\nDiagnostic line location start: "
      .. diagnostic.lnum

    if diagnostic.end_lnum then
      prompt = prompt .. " End: " .. diagnostic.end_lnum
    end

    require("CopilotChat").ask(prompt, { selection = require("CopilotChat.select").buffer })
  end
end

----------------------------------------------------------------------------------------------------
--- WhichKey mappings
-- Normal mode mappings
which_key.add({
  { ";x", "<cmd>only<CR>", desc = "Hide Other Buffers" },
  { "<leader>bo", "<cmd>bufdo e | %bd | e#<CR>", desc = "Delete Other Buffers" },
  { "<leader>gP", "<cmd>G push<CR>", desc = "Git Push" },
  { "<leader>ga", "<cmd>Gwrite<CR>", desc = "Stage Current file" },
  { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git Diff" },
  { "<leader>gp", "<cmd>G pull<CR>", desc = "Git pull --rebase" },
  { "<leader>gr", "<cmd>G commit --amend .<CR>", desc = "Reword Latest Commit" },

  -- Roslyn
  { "<leader>r", group = "Roslyn" },
  { "<leader>rr", "<cmd>Roslyn restart<CR>", desc = "Roslyn restart" },
  { "<leader>rs", "<cmd>Roslyn stop<CR>", desc = "Roslyn stop" },
  { "<leader>rt", "<cmd>Roslyn target<CR>", desc = "Roslyn target" },

  -- Color-picker
  { "<leader>cp", "<cmd>PickColor<cr>", desc = "Pick Color" },
  { "<leader>cP", "<cmd>PickColorInsert<cr>", desc = "Pick Color and Insert" },

  -- Flogit
  { "gl", "<cmd>Flogsplit<CR>", desc = "Flogsplit" },

  -- Oil
  { ";o", "<cmd>Oil<CR>", desc = "Oil" },
  { ";O", "<cmd>Oil --float<CR>", desc = "Oil Floated" },
  -- Defualt overrides
  { ";n", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
})

-- [AI]

-- [JackMort/ChatGPT]
if user == "ianus" then
  which_key.add({
    mode = { "v", "n" },
    {
      { "<leader>o", group = "ChatGPT" },
      { "<leader>oe", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
      { "<leader>oc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
      { "<leader>og", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
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
    { "<leader>os", ":'<,'>ChatGPTRun summarize<CR>", desc = "Summarize" },
    { "<leader>ot", ":'<,'>ChatGPTRun translate<CR>", desc = "Translate" },
    { "<leader>ox", ":'<,'>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
  })
end

-- [Copilot chat]
if user ~= "ianus" then
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
    {
      "<leader>oi",
      function()
        CopilotFixNextDiagnostic()
      end,
      desc = "Fix Next Diagnostic",
    },
    { "<leader>ol", "<cmd>CopilotChatLoad chat<CR>", desc = "Load" },
    { "<leader>ogc", "<cmd>CopilotChatCommit<CR>", desc = "Commit Message" },
    { "<leader>os", "<cmd>CopilotChatSave chat<CR>", desc = "Save" },
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
  })
end

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)
