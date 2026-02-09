return {
  {
    "yorickpeterse/nvim-window",
    keys = {
      { ",,", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
    },
    config = true,
  },
  {
    enabled = false,
    "folke/flash.nvim",
    ---@type Flash.Config
    opts = {
      search = {
        forward = true,
        multi_window = false,
        wrap = false,
        incremental = true,
      },
    },
  },
  -- Add semicolon or colon on the end of line
  { "lfilho/cosco.vim" },
  -- Multiple cursors plugin
  { "mg979/vim-visual-multi" },

  -- color highlighting and picker
  {
    "uga-rosa/ccc.nvim",
    cmd = "CccPick",
    config = function()
      local ccc = require("ccc")
      ccc.setup({
        inputs = {
          ccc.input.hsl,
          ccc.input.rgb,
          ccc.input.cmyk,
        },
      })
    end,
  },
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
    keys = {
      "ga", -- Default invocation prefix
      { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
    },
    cmd = {
      -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
      "Subs",
      "TextCaseOpenTelescope",
      "TextCaseOpenTelescopeQuickChange",
      "TextCaseOpenTelescopeLSPChange",
      "TextCaseStartReplacingCommand",
    },
    -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
    -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
    -- available after the first executing of it or after a keymap of text-case.nvim has been used.
    lazy = false,
  },
  {
    "gbprod/substitute.nvim",
    opts = {},
  },
}
