local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local which_key = require("which-key")
local user = os.getenv("USERNAME")

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

local build_types = { "debug", "release" }
local versions = { "2020", "2021", "2022", "2023", "2024", "2025" }

-- Use Snacks picker for Revit .NET project build selection
function DotnetBuildRevitSnacks()
  vim.ui.select(build_types, { prompt = "Select Build Type" }, function(build_type)
    if not build_type then
      return
    end
    vim.ui.select(versions, { prompt = "Select Revit Version" }, function(versionYear)
      if not versionYear then
        return
      end
      local version = versionYear:gsub("^20", "")
      DotnetBuildRevit(build_type, version)
    end)
  end)
end

-- Use Snacks picker for Revit .NET project clean selection
function DotnetCleanRevitSnacks()
  vim.ui.select(build_types, { prompt = "Select Build Type" }, function(build_type)
    if not build_type then
      return
    end
    vim.ui.select(versions, { prompt = "Select Revit Version" }, function(versionYear)
      if not versionYear then
        return
      end
      local version = versionYear:gsub("^20", "")
      DotnetCleanRevit(build_type, version)
    end)
  end)
end

-- Helper function to run dotnet clean command for Revit
function DotnetCleanRevit(build_type, version)
  local config = (build_type == "release" and "Release" or "Debug")
  local cmd = 'dotnet clean -c "' .. config .. '"'
  vim.cmd("vsplit")
  vim.cmd("enew")
  vim.fn.termopen(cmd)
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

  -- wtf.nvim
  { "<leader>ow", group = "+wtf" },

  -- Revit addins
  { ";r", group = "+Revit" },
  {
    ";rb",
    function()
      DotnetBuildRevitSnacks()
    end,
    desc = "Revit dotnet build",
  },
  {
    ";rc",
    function()
      DotnetCleanRevitSnacks()
    end,
    desc = "Revit dotnet clean",
  },

  -- easy-dotnet
  -- coordinate with testrunner mappings located in easy-dotnet setup

  { ";d", group = "+Net" },
  { ";dd", "<cmd>Dotnet<CR>", desc = "Dotnet picker" },
  { ";dt", "<cmd>Dotnet test<CR>", desc = "Run tests" },
  { ";dr", "<cmd>Dotnet testrunner<CR>", desc = "Toggle test runner" },

  -- Flogit
  { "gl", "<cmd>Flogsplit<CR>", desc = "Flogsplit" },

  -- Oil
  { ";o", "<cmd>Oil<CR>", desc = "Oil" },

  -- Diagnostic
  { ";l", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
  { ";j", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Previous Diagnostic" },

  -- Cosco comma or semicolon
  { ";;", "<Plug>(cosco-commaOrSemiColon)", desc = "Cosco Comma or Semicolon" },

  -- Exit terminal mode
  { "<C-q>", "<C-\\><C-n>", mode = "t", desc = "Exit Terminal Mode" },

  -- Sidekick NES
  { "<C-p>", LazyVim.cmp.map({ "ai_nes" }, "<tab>"), mode = { "n" }, expr = true },
})
