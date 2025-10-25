return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `toggle()`.
      { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
    },
    config = function()
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on `opencode_opts`.
      }

      -- Required for `vim.g.opencode_opts.auto_reload`.
      vim.o.autoread = true

      local which_key = require("which-key")

      -- Register keymaps with which-key
      which_key.add({
        { "<leader>oo", group = "+opencode" },
        {
          "<leader>ooa",
          function()
            require("opencode").ask("@this: ", { submit = true })
          end,
          desc = "Ask about this",
        },
        {
          "<leader>oos",
          function()
            require("opencode").select()
          end,
          desc = "Select prompt",
        },
        {
          "<leader>oo+",
          function()
            require("opencode").prompt("@this")
          end,
          desc = "Add this",
        },
        {
          "<leader>oot",
          function()
            require("opencode").toggle()
          end,
          desc = "Toggle embedded",
        },
        {
          "<leader>ooc",
          function()
            require("opencode").command()
          end,
          desc = "Select command",
        },
        {
          "<leader>oon",
          function()
            require("opencode").command("session_new")
          end,
          desc = "New session",
        },
        {
          "<leader>ooi",
          function()
            require("opencode").command("session_interrupt")
          end,
          desc = "Interrupt session",
        },
        {
          "<leader>ooA",
          function()
            require("opencode").command("agent_cycle")
          end,
          desc = "Cycle selected agent",
        },
      })

      -- Non-leader keymaps (not handled by which-key)
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("messages_half_page_up")
      end, { desc = "Messages half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("messages_half_page_down")
      end, { desc = "Messages half page down" })
    end,
  },
}
