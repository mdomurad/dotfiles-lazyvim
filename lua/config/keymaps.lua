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

----------------------------------------------------------------------------------------------------
--- Leader mappings

keymap.set("n", "<leader>r", function()
  require("md.utils").replaceHexWithHSL()
end)

----------------------------------------------------------------------------------------------------
--- WhichKey mappings
-- Normal mode mappings
which_key.add({
  { "<leader>o", "<cmd>only<CR>", desc = "Hide Other Buffers" },
  { "<leader>bo", "<cmd>bufdo e | %bd | e#<CR>", desc = "Delete Other Buffers" },
  { "<leader>gP", "<cmd>G push<CR>", desc = "Git Push" },
  { "<leader>ga", "<cmd>Gwrite<CR>", desc = "Stage Current file" },
  { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git Diff" },
  { "<leader>gp", "<cmd>G pull<CR>", desc = "Git pull --rebase" },
  { "<leader>gr", "<cmd>G commit --amend .<CR>", desc = "Reword Latest Commit" },

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

-- if user == "remove" then
--   which_key.add({
--     -- JackMort/ChatGPT
--     { "<leader>t", group = "ChatGPT" },
--     { "<leader>tt", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
--   })
-- else
which_key.add({
  mode = { "n" },
  { "<leader>t", group = "CopilotChat" },
  {
    "<leader>ta",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
    desc = "Prompt Actions",
  },
  { "<leader>tt", "<cmd>CopilotChat<CR>", desc = "CopilotChat" },
  { "<leader>tc", "<cmd>CopilotChatCommitStaged<CR>", desc = "Commit Message Staged" },
  {
    "<leader>th",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').help_actions())<CR>",
    desc = "Help Actions",
  },
  { "<leader>ti", "<cmd>CopilotChatFixDiagnostic<CR>", desc = "Fix Diagnostics" },
  { "<leader>tl", "<cmd>CopilotChatLoad chat<CR>", desc = "Load" },
  { "<leader>tq", "<cmd>CopilotChatCommit<CR>", desc = "Commit Message" },
  { "<leader>ts", "<cmd>CopilotChatSave chat<CR>", desc = "Save" },
  { "<leader>tx", "<cmd>lua get_git_remote_url()<CR>", desc = "Get Fit Remote Url" },
})

-- Visual mode mappings
-- if user == "remove" then
--   which_key.add(
--     -- JackMort/ChatGPT
--     {
--       mode = { "v" },
--       { "<leader>t", group = "ChatGPT" },
--       { "<leader>tc", ":'<,'>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
--       { "<leader>td", ":'<,'>ChatGPTRun docstring<CR>", desc = "Docstring" },
--       { "<leader>te", ":'<,'>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
--       { "<leader>tf", ":'<,'>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
--       { "<leader>tg", ":'<,'>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
--       { "<leader>tk", ":'<,'>ChatGPTRun keywords<CR>", desc = "Keywords" },
--       { "<leader>tl", ":'<,'>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
--       { "<leader>to", ":'<,'>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
--       { "<leader>tq", ":'<,'>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
--       { "<leader>ts", ":'<,'>ChatGPTRun summarize<CR>", desc = "Summarize" },
--       { "<leader>tt", ":'<,'>ChatGPTRun translate<CR>", desc = "Translate" },
--       { "<leader>tx", ":'<,'>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
--     }
--   )
-- else

which_key.add({
  mode = { "v" },
  { "<leader>t", group = "CopilotChat" },
  {
    "<leader>ta",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
    desc = "Prompt actions",
  },
  { "<leader>tc", "<cmd> lua quickChat() <CR>", desc = "CopilotChat - Quick chat" },
  { "<leader>td", ":'<,'>CopilotChatDocs<CR>", desc = "Docstring" },
  { "<leader>tf", ":'<,'>CopilotChatFix<CR>", desc = "Fix Bugs" },
  { "<leader>to", ":'<,'>CopilotChatOptimize<CR>", desc = "Optimize Code" },
  { "<leader>tq", ":'<,'>CopilotChatTests<CR>", desc = "Add Tests" },
  { "<leader>tr", ":'<,'>CopilotChatReview<CR>", desc = "Review Code" },
  { "<leader>tt", ":'<,'>CopilotChat<CR>", desc = "CopilotChat" },
  { "<leader>tx", ":'<,'>CopilotChatExplain<CR>", desc = "Explain Code" },
})

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)
