local which_key = require("which-key")

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

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

keymap.set("n", "<leader>r", function()
  require("md.utils").replaceHexWithHSL()
end)

-- cosco.vim
keymap.set("n", ";;", "<Plug>(cosco-commaOrSemiColon)", opts)

-- Window-picker
local picker = require("window-picker")

-- Color-picker
vim.keymap.set("n", "<C-x>", "<cmd>PickColor<cr>", opts)
vim.keymap.set("i", "<C-x>", "<cmd>PickColorInsert<cr>", opts)

vim.keymap.set("n", ",w", function()
  local picked_window_id = picker.pick_window({
    include_current_win = true,
  }) or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(picked_window_id)
end, { desc = "Pick a window" })

local mappings = {
  -- JackMort/ChatGPT
  r = {
    name = "ChatGPT",
    r = { ":ChatGPT<CR>", "ChatGPT", opts },
    e = { ":'<,'>ChatGPTEditWithInstruction<CR>", "Edit with instruction", opts },
    g = { ":'<,'>ChatGPTRun grammar_correction<CR>", "Grammar Correction", opts },
    t = { ":'<,'>ChatGPTRun translate<CR>", "Translate", opts },
    k = { ":'<,'>ChatGPTRun keywords<CR>", "Keywords", opts },
    d = { ":'<,'>ChatGPTRun docstring<CR>", "Docstring", opts },
    a = { ":'<,'>ChatGPTRun add_tests<CR>", "Add Tests", opts },
    o = { ":'<,'>ChatGPTRun optimize_code<CR>", "Optimize Code", opts },
    s = { ":'<,'>ChatGPTRun summarize<CR>", "Summarize", opts },
    f = { ":'<,'>ChatGPTRun fix_bugs<CR>", "Fix Bugs", opts },
    x = { ":'<,'>ChatGPTRun explain_code<CR>", "Explain Code", opts },
    c = { ":'<,'>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", opts },
    l = { ":'<,'>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", opts },
  },
  -- Disable continuations
  o = { "o<Esc>^Da", "Empty line below", opts },
  O = { "O<Esc>^Da", "Empty line above", opts },
}

-- Set up WhichKey
which_key.register(mappings, { prefix = "<leader>" })
