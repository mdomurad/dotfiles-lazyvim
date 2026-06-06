-- Inline as-you-type AI completions via DeepSeek FIM API.
-- Loaded only for ianus (see ai/init.lua).
-- Requires DEEPSEEK_API_KEY environment variable.
return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("minuet").setup({
      -- Use DeepSeek FIM (Fill-In-the-Middle) — best for code completion latency.
      provider = "openai_fim_compatible",

      -- One completion at a time keeps DeepSeek FIM cost minimal.
      n_completions = 1,

      -- Throttle and debounce reduce API calls while still feeling responsive.
      throttle     = 1000, -- ms between request bursts
      debounce     = 400,  -- ms of idle before triggering
      request_timeout = 3, -- seconds before giving up

      provider_options = {
        openai_fim_compatible = {
          api_key   = "DEEPSEEK_API_KEY",    -- read from env var
          name      = "deepseek",
          end_point = "https://api.deepseek.com/beta/completions",
          model     = "deepseek-v4-flash",
          optional  = {
            max_tokens = 256,
            top_p      = 0.9,
          },
        },
      },

      virtualtext = {
        -- Auto-trigger in common coding filetypes.
        -- Set to {} for manual-only (trigger with next/prev keys).
        auto_trigger_ft = {
          "lua", "python", "javascript", "typescript", "typescriptreact",
          "javascriptreact", "go", "rust", "c", "cpp", "cs",
        },
        -- Show virtual text even when blink.cmp menu is visible
        -- Default is false to avoid visual clutter
        show_on_completion_menu = true,
        keymap = {
          accept      = "<Tab>",
          accept_line = "<S-Tab>",
          accept_word = "<C-Right>",
          next        = "<A-l>",
          prev        = "<A-j>",
          dismiss     = "<Esc>",
        },
      },
    })
  end,
}
