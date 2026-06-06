local user_config = require("config.user")
local is_ianus = user_config.is_ianus

return {
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local wtf_opts

      if is_ianus then
        -- DeepSeek V4 Flash with thinking disabled for fast, predictable JSON output.
        -- wtf.nvim's fix command expects strict JSON back; reasoning tokens hurt reliability.
        wtf_opts = {
          provider = "deepseek",
          providers = {
            deepseek = {
              model_id = "deepseek-v4-flash",
              format_request = function(data)
                return {
                  model       = data.model,
                  messages    = {
                    { role = "system", content = data.system },
                    { role = "user",   content = data.message },
                  },
                  max_tokens  = data.max_tokens,
                  stream      = false,
                  temperature = data.temperature,
                  thinking    = { type = "disabled" },
                }
              end,
            },
          },
        }
      else
        -- Other users: keep Copilot as before
        wtf_opts = {
          provider  = "copilot",
          providers = { copilot = { model_id = "gpt-5.4-mini" } },
        }
      end

      require("wtf").setup(wtf_opts)
    end,
    opts = {},
    keys = {
      { "<leader>owd", mode = { "n", "x" }, function() require("wtf").diagnose()      end, desc = "Debug diagnostic with AI" },
      { "<leader>owf", mode = { "n", "x" }, function() require("wtf").fix()           end, desc = "Fix diagnostic with AI" },
      { "<leader>ows", mode = { "n" },       function() require("wtf").search()        end, desc = "Search diagnostic with Google" },
      { "<leader>owp", mode = { "n" },       function() require("wtf").pick_provider() end, desc = "Pick provider" },
      { "<leader>owh", mode = { "n" },       function() require("wtf").history()       end, desc = "Populate quickfix with chat history" },
      { "<leader>owg", mode = { "n" },       function() require("wtf").grep_history()  end, desc = "Grep chat history with Telescope" },
    },
  },
}
