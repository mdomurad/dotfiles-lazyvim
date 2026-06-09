-- Shared AI model configuration.
-- Keep task-appropriate Copilot model choices in one place so the AI plugins
-- stay aligned when Copilot changes its supported model set.

local user_config = require("config.user")

local M = {
  is_ianus = user_config.is_ianus,

  copilot = {
    -- Lightweight default for quick tasks like commit titles and summaries.
    quick = "gpt-5-mini",
    -- Stronger code-focused model for chat, review, fixes, and edits.
    code = "gpt-5.3-codex",
    -- General-purpose fallback when a quick task still needs a supported model.
    versatile = "gpt-4o",
  },
}

M.codecompanion = {
  chat = M.copilot.code,
  background = M.copilot.code,
  quick_commit = M.copilot.quick,
  quick_commit_fallback = M.copilot.versatile,
  title = M.copilot.quick,
  summary = M.copilot.quick,
}

M.chatgpt = {
  chat = M.copilot.quick,
  edit = M.copilot.code,
}

M.wtf = {
  copilot = M.copilot.versatile,
}

return M
