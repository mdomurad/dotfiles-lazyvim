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
