return {
  -- Create annotations with one keybind, and jump your cursor in the inserted annotation
  {
    "danymat/neogen",
    keys = {
      {
        "<leader>cc",
        function()
          require("neogen").generate({})
        end,
        desc = "Neogen Comment",
      },
    },
    opts = { snippet_engine = "luasnip" },
  },

  -- Incremental rename
  -- {
  --   "smjonas/inc-rename.nvim",
  --   cmd = "IncRename",
  --   config = true,
  -- },

  -- Refactoring tool
  {
    "ThePrimeagen/refactoring.nvim",
    keys = {
      {
        "<leader>r",
        function()
          require("refactoring").select_refactor()
        end,
        mode = "v",
        noremap = true,
        silent = true,
        expr = false,
      },
    },
    opts = {},
  },

  -- Go forward/backward with square brackets
  {
    "echasnovski/mini.bracketed",
    event = "BufReadPost",
    config = function()
      local bracketed = require("mini.bracketed")
      bracketed.setup({
        file = { suffix = "" },
        window = { suffix = "" },
        quickfix = { suffix = "" },
        yank = { suffix = "" },
        treesitter = { suffix = "n" },
      })
    end,
  },

  -- Better increase/descrease
  {
    "monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "let", "const" } }),
        },
      })
    end,
  },
  {
    "nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        model = "gpt-3.5-turbo",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    {
      "nvim-neorg/neorg",
      -- ft = "norg", --lazy load on filetype
      -- cmd = "Neorg", -- lazy load on command, allows you to autocomplete :Neorg regardless of whether it's loaded yet
      -- priority = 30, -- treesitter is on default priority of 50, neorg should load after it.
      version = "v7.0.0",
      run = ":Neorg sync-parsers", -- This is the important bit!
      config = function()
        require("neorg").setup({
          load = {
            ["core.defaults"] = {}, -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.completion"] = { config = { engine = "nvim-cmp" } },
            ["core.journal"] = {},
            ["core.qol.toc"] = {},
            ["core.dirman"] = { -- Manages Neorg workspaces
              config = {
                workspaces = {
                  todo = "c:/notes/todo",
                  notes = "c:/notes/notes",
                  development = "c:/notes/dev",
                  bim = "c:/notes/bim",
                },
                default_workspace = "todo",
              },
            },
          },
        })
      end,
    },
    {
      -- Roslyn.nvim
      {
        "jmederosalvarado/roslyn.nvim",
        config = function()
          local nvim_lsp = require("lspconfig")
          require("roslyn").setup({
            dotnet_cmd = "dotnet",
            roslyn_version = "4.8.0-3.23475.7",
            on_attach = function(client, bufnr)
              require("lazyvim.util").lsp.on_attach(client, bufnr)
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          })
        end,
      },
    },
  },
}
