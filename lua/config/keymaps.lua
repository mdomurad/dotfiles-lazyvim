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

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)

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

local mappings = {
  -- JackMort/ChatGPT
  T = {
    name = "ChatGPT",
    T = { "<cmd>ChatGPT<CR>", "ChatGPT" },
  },
  -- CopilotChat
  t = {
    name = "CopilotChat",
    t = { "<cmd>CopilotChat<CR>", "CopilotChat" },
    q = { "<cmd>CopilotChatCommit<CR>", "Commit Message", opts },
    c = { "<cmd>CopilotChatCommitStaged<CR>", "Commit Message Staged", opts },
    a = {
      "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
      "Prompt actions",
    },
    h = {
      "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').help_actions())<CR>",
      "Help actions",
    },
    s = { "<cmd>CopilotChatSave chat<CR>", "Save", opts },
    l = { "<cmd>CopilotChatLoad chat<CR>", "Load", opts },
    x = { "<cmd>lua get_git_remote_url()<CR>", "Get git remote url", opts },
  },
  g = {
    p = { "<cmd>G pull<CR>", "Git pull", opts },
    P = { "<cmd>G push<CR>", "Git push", opts },
    d = { "<cmd>Gvdiffsplit<CR>", "Git diff", opts },
    r = { "<cmd>G commit --amend .<CR>", "Reword latest commit", opts },
  },
  -- Disable continuations
  o = { "o<Esc>^Da", "Empty line below" },
  O = { "O<Esc>^Da", "Empty line above" },
}

local visualMappings = {
  -- JackMort/ChatGPT
  T = {
    name = "ChatGPT",
    e = { ":'<,'>ChatGPTEditWithInstruction<CR>", "Edit with instruction", opts },
    g = { ":'<,'>ChatGPTRun grammar_correction<CR>", "Grammar Correction", opts },
    t = { ":'<,'>ChatGPTRun translate<CR>", "Translate", opts },
    k = { ":'<,'>ChatGPTRun keywords<CR>", "Keywords", opts },
    d = { ":'<,'>ChatGPTRun docstring<CR>", "Docstring", opts },
    q = { ":'<,'>ChatGPTRun add_tests<CR>", "Add Tests", opts },
    o = { ":'<,'>ChatGPTRun optimize_code<CR>", "Optimize Code", opts },
    s = { ":'<,'>ChatGPTRun summarize<CR>", "Summarize", opts },
    f = { ":'<,'>ChatGPTRun fix_bugs<CR>", "Fix Bugs", opts },
    x = { ":'<,'>ChatGPTRun explain_code<CR>", "Explain Code", opts },
    c = { ":'<,'>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", opts },
    l = { ":'<,'>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", opts },
  },
  -- CopilotChat
  t = {
    name = "CopilotChat",
    t = { ":'<,'>CopilotChat<CR>", "CopilotChat", opts },
    c = {
      "<cmd> lua quickChat() <CR>",
      "CopilotChat - Quick chat",
    },
    a = {
      "<cmd>lua require('CopilotChat.actions'); require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions())<CR>",
      "Prompt actions",
    },
    i = { ":'<,'>CopilotChatFixDiagnostics<CR>", "Fix Diagnostics", opts },
    d = { ":'<,'>CopilotChatDocs<CR>", "Docstring", opts },
    q = { ":'<,'>CopilotChatTests<CR>", "Add Tests", opts },
    o = { ":'<,'>CopilotChatOptimize<CR>", "Optimize Code", opts },
    r = { ":'<,'>CopilotChatReview<CR>", "Review Code", opts },
    f = { ":'<,'>CopilotChatFix<CR>", "Fix Bugs", opts },
    x = { ":'<,'>CopilotChatExplain<CR>", "Explain Code", opts },
  },
}

----------------------------------------------------------------------------------------------------
-- Set up WhichKey
which_key.register(mappings, { prefix = "<leader>" })
which_key.register(visualMappings, { prefix = "<leader>", mode = "v" })
