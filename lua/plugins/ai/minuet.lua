-- DeepSeek-backed inline completions and next-edit predictions for ianus only.
-- This module is imported conditionally by plugins/ai/init.lua.
local code_filetypes = {
  "lua",
  "python",
  "javascript",
  "typescript",
  "typescriptreact",
  "javascriptreact",
  "go",
  "rust",
  "c",
  "cpp",
  "cs",
}

return {
  "milanglacier/minuet-ai.nvim",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>am", "", desc = "+minuet", mode = "n" },
    { "<leader>amp", "<cmd>Minuet duet predict<cr>", desc = "Predict next edit", mode = "n" },
    { "<leader>ama", "<cmd>Minuet duet apply<cr>", desc = "Apply next edit", mode = "n" },
    { "<leader>amd", "<cmd>Minuet duet dismiss<cr>", desc = "Dismiss next edit", mode = "n" },
    { "<leader>amt", "<cmd>Minuet duet toggle<cr>", desc = "Toggle next-edit predictions", mode = "n" },
  },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1,
      throttle = 1000,
      debounce = 400,
      request_timeout = 3,
      provider_options = {
        openai_fim_compatible = {
          api_key = "DEEPSEEK_API_KEY",
          name = "DeepSeek",
          end_point = "https://api.deepseek.com/beta/completions",
          model = "deepseek-v4-flash",
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = code_filetypes,
        show_on_completion_menu = true,
        keymap = {
          accept_line = "<M-a>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
      duet = {
        provider = "openai_compatible",
        request_timeout = 15,
        auto_trigger = {
          auto_trigger_ft = code_filetypes,
          enable_predicates = {
            function()
              return vim.fn.mode(1):sub(1, 1) == "n"
            end,
          },
        },
        provider_options = {
          openai_compatible = {
            api_key = "DEEPSEEK_API_KEY",
            name = "DeepSeek",
            end_point = "https://api.deepseek.com/chat/completions",
            model = "deepseek-v4-flash",
            optional = {
              thinking = { type = "disabled" },
            },
          },
        },
      },
    })

    LazyVim.cmp.actions.ai_accept = function()
      local virtualtext = require("minuet.virtualtext").action
      if not virtualtext.is_visible() then
        return
      end

      LazyVim.create_undo()
      virtualtext.accept()
      return true
    end
  end,
}
