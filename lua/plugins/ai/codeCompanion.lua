return {

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            name = "copilot",
            model = "gpt-4.1",
          },
          inline = {
            adapter = "copilot",
          },
          extensions = {
            mcphub = {
              callback = "mcphub.extensions.codecompanion",
              opts = {
                make_vars = true,
                make_slash_commands = true,
                show_result_in_chat = true,
              },
            },
          },
        },
      })
      require("mcphub").setup({ port = 37373 })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
  },
}
