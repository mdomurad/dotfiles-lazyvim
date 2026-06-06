-- Ianus-specific AI overrides.
-- Loaded only when USERNAME == "ianus" (see ai/init.lua).
-- Disables the Copilot language server and Sidekick NES so they do not run
-- for this user; other users continue using copilot-native + sidekick as before.
return {
  -- Disable copilot LSP server for ianus.
  -- The copilot-native and sidekick extras in lazyvim.json still load their
  -- plugin code for all users, but the server itself is prevented from starting.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = { enabled = false },
      },
    },
  },

  -- Keep sidekick loaded so the CLI terminal integration remains usable
  -- (e.g. for Codex CLI via <leader>aa), but disable NES which requires
  -- Copilot LSP.
  {
    "folke/sidekick.nvim",
    optional = true,
    opts = {
      nes = { enabled = false },
    },
  },
}
