-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  command = ":ColorizerAttachToBuffer",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.xaml", "*.config" },
  command = ":setfiletype xml",
})

-- Set current path to opened file root dir
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    -- Skip .cs files, let the dedicated autocmd handle them
    if vim.fn.expand("%:e") == "cs" then
      return
    end
    local dir = vim.fn.expand("%:p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
      vim.cmd("cd " .. dir)
    end
  end,
})

--- This autocmd is triggered when a buffer matching the pattern 'copilot-*' is entered.
--- It sets the local option 'relativenumber' to true for the buffer.
--- It also maps the key combination 'Ctrl-p' to print the last response from CopilotChat.
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    vim.opt_local.relativenumber = true

    -- C-p to print last response
    vim.keymap.set("n", "<C-p>", function()
      print(require("CopilotChat").response())
    end, { buffer = true, remap = true })
  end,
})

vim.api.nvim_create_autocmd("Filetype", {
  pattern = "norg",
  callback = function()
    vim.keymap.set("n", "gx", "<Plug>(neorg.esupports.hop.hop-link)", { buffer = true })
  end,
})

-- Persistent folding
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local view_group = augroup("auto_view", { clear = true })
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
  desc = "Save view with mkview for real files",
  group = view_group,
  callback = function(args)
    if vim.b[args.buf].view_activated then
      vim.cmd.mkview({ mods = { emsg_silent = true } })
    end
  end,
})
autocmd("BufWinEnter", {
  desc = "Try to load file view if available and enable view saving for real files",
  group = view_group,
  callback = function(args)
    if not vim.b[args.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
      local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
      if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[args.buf].view_activated = true
        vim.cmd.loadview({ mods = { emsg_silent = true } })
      end
    end
  end,
})

-- Disable diagnostics for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.enable(false)
  end,
})

local function set_csharp_root_dir()
  local path = vim.fn.expand("%:p:h")
  local dir = path
  local closest = nil
  local max_depth = 10
  local depth = 0

  -- Step 1: Find closest .csproj or .sln upwards
  while dir ~= "" and dir ~= "/" and depth < max_depth do
    local csproj = vim.fn.globpath(dir, "*.csproj")
    local sln = vim.fn.globpath(dir, "*.sln")
    if sln ~= "" then
      closest = { type = "sln", path = sln, dir = dir }
      break
    elseif csproj ~= "" then
      closest = { type = "csproj", path = csproj, dir = dir }
      break
    end
    dir = vim.fn.fnamemodify(dir, ":h")
    depth = depth + 1
  end

  if not closest then
    return
  end

  -- Step 2: If closest is .sln, set dir
  if closest.type == "sln" then
    vim.cmd("lcd " .. vim.fn.fnameescape(closest.dir))
    return
  end

  -- Step 3: If closest is .csproj, look upwards for .sln
  local csproj_path = closest.path
  local csproj_dir = closest.dir
  local csproj_filename = vim.fn.fnamemodify(csproj_path, ":t")
  dir = csproj_dir
  depth = 0
  while dir ~= "" and dir ~= "/" and depth < max_depth do
    local sln = vim.fn.globpath(dir, "*.sln")
    if sln ~= "" then
      local sln_content = vim.fn.readfile(sln)
      for _, line in ipairs(sln_content) do
        if line:find(csproj_filename, 1, true) then
          vim.cmd("lcd " .. vim.fn.fnameescape(dir))
          return
        end
      end
      break -- found .sln but not containing csproj, stop searching
    end
    dir = vim.fn.fnamemodify(dir, ":h")
    depth = depth + 1
  end

  -- Step 4: Fallback to csproj dir
  vim.cmd("lcd " .. vim.fn.fnameescape(csproj_dir))
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.cs",
  callback = set_csharp_root_dir,
})
