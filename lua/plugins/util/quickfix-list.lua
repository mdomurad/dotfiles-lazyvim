return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  dependencies = {
    "junegunn/fzf",
    "junegunn/fzf.vim",
  },
  config = function()
    if vim.fn.has("win32") == 0 then
      return
    end

    local shell = vim.o.shell:lower()
    if not shell:find("nu", 1, true) then
      return
    end

    if vim.fn.exists("*fzf#exec") ~= 1 then
      return
    end

    local previous = {
      shell = vim.o.shell,
      shellcmdflag = vim.o.shellcmdflag,
      shellquote = vim.o.shellquote,
      shellxquote = vim.o.shellxquote,
      shellslash = vim.o.shellslash,
    }

    vim.o.shell = "cmd.exe"
    vim.o.shellcmdflag = "/s /c"
    vim.o.shellquote = ""
    vim.o.shellxquote = '"'
    vim.o.shellslash = false

    pcall(function()
      vim.fn["fzf#exec"]()
    end)

    vim.o.shell = previous.shell
    vim.o.shellcmdflag = previous.shellcmdflag
    vim.o.shellquote = previous.shellquote
    vim.o.shellxquote = previous.shellxquote
    vim.o.shellslash = previous.shellslash
  end,
}
