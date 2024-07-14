local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local which_key = require("which-key")

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

-- Omnisharp extended
-- replaces vim.lsp.buf.definition()
keymap.set("n", "gd", '<cmd>lua require("omnisharp_extended").lsp_definition()<cr>', {})

-- replaces vim.lsp.buf.type_definition()
keymap.set("n", "<leader>D", '<cmd>lua require("omnisharp_extended").lsp_type_definition()<cr>', {})

-- replaces vim.lsp.buf.references()
keymap.set("n", "gr", '<cmd>lua require("omnisharp_extended").lsp_references()<cr>', {})

-- replaces vim.lsp.buf.implementation()
keymap.set("n", "gi", '<cmd>lua require("omnisharp_extended").lsp_implementation()<cr>', {})

-- commands for telescope
keymap.set("n", "gr", "<cmd>lua require('omnisharp_extended').telescope_lsp_references()<cr>", { noremap = true })

-- options are supported as well
keymap.set(
  "n",
  "gd",
  '<cmd>lua require("omnisharp_extended").telescope_lsp_definition({ jump_type = "vsplit" })<cr>',
  {}
)
keymap.set("n", "<leader>D", '<cmd>lua require("omnisharp_extended").telescope_lsp_type_definition()<cr>', {})
keymap.set("n", "gi", '<cmd>lua require("omnisharp_extended").telescope_lsp_implementation()<cr>', {})

-- Window-picker
local picker = require("window-picker")

-- Color-picker
keymap.set("n", "<C-x>", "<cmd>PickColor<cr>", opts)
keymap.set("i", "<C-x>", "<cmd>PickColorInsert<cr>", opts)

keymap.set("n", ",w", function()
  local picked_window_id = picker.pick_window({
    include_current_win = true,
  }) or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(picked_window_id)
end, { desc = "Pick a window" })

----------------------------------------------------------------------------------------------------
--- Leader mappings

keymap.set("n", "<leader>r", function()
  require("md.utils").replaceHexWithHSL()
end)

----------------------------------------------------------------------------------------------------
--- WhichKey mappings
-- Normal mode mappings
which_key.add({
  -- JackMort/ChatGPT
  { "<leader>T", group = "ChatGPT" },
  { "<leader>TT", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
  { "<leader>bo", "<cmd>bufdo e | %bd | e#<CR>", desc = "Delete Other Buffers" },
  { "<leader>gP", "<cmd>G push<CR>", desc = "Git push" },
  { "<leader>ga", "<cmd>Gwrite<CR>", desc = "Stage current file" },
  { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git diff" },
  { "<leader>gp", "<cmd>G pull<CR>", desc = "Git pull --rebase" },
  { "<leader>gr", "<cmd>G commit --amend .<CR>", desc = "Reword latest commit" },
  { "<leader>t", group = "CopilotChat" },
  {
    "<leader>ta",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
    desc = "Prompt actions",
  },
  { "<leader>tc", "<cmd>CopilotChatCommitStaged<CR>", desc = "Commit Message Staged" },
  {
    "<leader>th",
    "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').help_actions())<CR>",
    desc = "Help actions",
  },
  { "<leader>ti", "<cmd>CopilotChatFixDiagnostics<CR>", desc = "Fix Diagnostics" },
  { "<leader>tl", "<cmd>CopilotChatLoad chat<CR>", desc = "Load" },
  { "<leader>tq", "<cmd>CopilotChatCommit<CR>", desc = "Commit Message" },
  { "<leader>ts", "<cmd>CopilotChatSave chat<CR>", desc = "Save" },
  { "<leader>tt", "<cmd>CopilotChat<CR>", desc = "CopilotChat" },
  { "<leader>tx", "<cmd>lua get_git_remote_url()<CR>", desc = "Get git remote url" },
  -- Oil
  { ";O", "<cmd>Oil --float<CR>", desc = "Oil floated" },
  { ";o", "<cmd>Oil<CR>", desc = "Oil" },
})

-- Visual mode mappings
which_key.add(
  -- JackMort/ChatGPT
  {
    mode = { "v" },
    { "<leader>T", group = "ChatGPT" },
    { "<leader>Tc", ":'<,'>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
    { "<leader>Td", ":'<,'>ChatGPTRun docstring<CR>", desc = "Docstring" },
    { "<leader>Te", ":'<,'>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
    { "<leader>Tf", ":'<,'>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" },
    { "<leader>Tg", ":'<,'>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" },
    { "<leader>Tk", ":'<,'>ChatGPTRun keywords<CR>", desc = "Keywords" },
    { "<leader>Tl", ":'<,'>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
    { "<leader>To", ":'<,'>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" },
    { "<leader>Tq", ":'<,'>ChatGPTRun add_tests<CR>", desc = "Add Tests" },
    { "<leader>Ts", ":'<,'>ChatGPTRun summarize<CR>", desc = "Summarize" },
    { "<leader>Tt", ":'<,'>ChatGPTRun translate<CR>", desc = "Translate" },
    { "<leader>Tx", ":'<,'>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
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
  }
)

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)
