return {
  {
    "folke/sidekick.nvim",
    keys = {
      -- Keep Herdr's default <leader>a prefix, including <leader>as.
      { "<leader>aa", false },
      { "<leader>as", false },
      { "<leader>ad", false },
      { "<leader>at", false },
      { "<leader>af", false },
      { "<leader>av", false },
      { "<leader>ap", false },

      -- Sidekick gets its own named Which-Key subgroup.
      { "<leader>ai", "", desc = "+sidekick" },
      {
        "<leader>aia",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>ais",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Select CLI",
      },
      {
        "<leader>aid",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>ait",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "n", "x" },
        desc = "Send This",
      },
      {
        "<leader>aif",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>aiv",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>aip",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
