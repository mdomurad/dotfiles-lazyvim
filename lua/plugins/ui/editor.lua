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

    -- Snacks picker keymaps moved to keymaps.lua
  {
    "ziontee113/color-picker.nvim",
    config = function()
      require("color-picker")
    end,
  },
  -- color highlighting
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "css", "scss", "html", "javascript", "typescript" }, {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
    end,
  },
  {
    "jlcrochet/vim-razor",
  },
  -- { "vim-pandoc/vim-pandoc" },
  -- { "vim-pandoc/vim-pandoc-syntax" },
  {
    "johmsalas/text-case.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    config = function()
      require("textcase").setup({})
    end,
    keys = {
      "ga", -- Default invocation prefix
      { "ga.", "<cmd>TextCaseOpenFzfLua<CR>", mode = { "n", "x" }, desc = "FZF" },
    },
    cmd = {
      -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
      "Subs",
      "TextCaseOpenFzfLua",
      "TextCaseOpenFzfLuaQuickChange",
      "TextCaseOpenFzfLuaLSPChange",
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
