return {
  "dkarter/bullets.vim",
  -- Lazy-load the plugin only on relevant filetypes
  ft = { "markdown", "text", "gitcommit" },

  -- Use LazyVim's native `keys` table to define your mappings
  keys = {
    {
      ";x",
      "<Plug>(bullets-toggle-checkbox)",
      ft = "markdown",
      desc = "Toggle Checkbox",
      mode = { "n", "v" }, -- Works in Normal and Visual mode
    },
    {
      "<leader>mN",
      "<Plug>(bullets-renumber)",
      ft = "markdown",
      desc = "Renumber Bullets",
      mode = { "n", "v" }, -- Works in Normal and Visual mode
    },
    {
      "<leader>mx",
      "<Plug>(bullets-toggle-checkbox)",
      ft = "markdown",
      desc = "Toggle Checkbox (Leader)",
      mode = { "n", "v" },
    },
    {
      "<leader>mo",
      "<Plug>(bullets-newline)",
      ft = "markdown",
      desc = "New Bullet Below",
      mode = { "n" },
    },
    {
      "<leader>mO",
      "<Plug>(bullets-newline)",
      ft = "markdown",
      desc = "New Bullet Below (Insert Mode)",
      mode = { "i" },
    },
    {
      "<CR>",
      "<Plug>(bullets-newline)",
      ft = "markdown",
      desc = "New Bullet Below (Insert Mode, Enter)",
      mode = { "i" },
    },
    {
      "<leader>m>",
      "<Plug>(bullets-demote)",
      ft = "markdown",
      desc = "Demote Bullet",
      mode = { "n", "v" },
    },
    {
      "<leader>m<",
      "<Plug>(bullets-promote)",
      ft = "markdown",
      desc = "Promote Bullet",
      mode = { "n", "v" },
    },
  },

  init = function()
    -- Remove trailing whitespace when toggling an empty checkbox
    vim.g.bullets_checkbox_markers = " x"
    vim.g.bullets_set_mappings = 0 -- Disable default mappings to avoid conflicts
  end,
}
