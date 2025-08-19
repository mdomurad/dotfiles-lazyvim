return {
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim", -- Optional: For WtfGrepHistory
    },
    opts = {},
    keys = {
      {
        ";wd",
        mode = { "n", "x" },
        function()
          require("wtf").diagnose()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        ";wf",
        mode = { "n", "x" },
        function()
          require("wtf").fix()
        end,
        desc = "Fix diagnostic with AI",
      },
      {
        mode = { "n" },
        ";ws",
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
      },
      {
        mode = { "n" },
        ";wp",
        function()
          require("wtf").pick_provider()
        end,
        desc = "Pick provider",
      },
      {
        mode = { "n" },
        ";wh",
        function()
          require("wtf").history()
        end,
        desc = "Populate the quickfix list with previous chat history",
      },
      {
        mode = { "n" },
        ";wg",
        function()
          require("wtf").grep_history()
        end,
        desc = "Grep previous chat history with Telescope",
      },
    },
  },
}
