local username = os.getenv("USERNAME")

local workspaces = {
  {
    name = "work",
    path = "~/vaults/public/work",
  },
  {
    name = "dev",
    path = "~/vaults/public/dev",
  },
}

if username == "ianus" then
  local additional_workspaces = {
    {
      name = "ianus",
      path = "~/vaults/priv/ianus",
    },
    {
      name = "tbb",
      path = "~/vaults/priv/tbb",
    },
  }

  for _, workspace in ipairs(additional_workspaces) do
    table.insert(workspaces, workspace)
  end
end

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = workspaces,
    ui = {
      enable = false,
    },
  },
}
