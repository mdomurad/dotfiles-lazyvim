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

-- Roslyn
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    local clients = vim.lsp.get_clients({ name = "roslyn" })
    if not clients or #clients == 0 then
      return
    end

    local buffers = vim.lsp.get_buffers_by_client_id(clients[1].id)
    for _, buf in ipairs(buffers) do
      vim.lsp.util._refresh("textDocument/diagnostic", { bufnr = buf })
    end
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
