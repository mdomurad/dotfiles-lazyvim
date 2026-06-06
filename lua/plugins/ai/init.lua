local user_config = require("config.user")

local plugins = {
  require("plugins.ai.codeCompanion"),
  require("plugins.ai.wtf"),
}

if user_config.is_ianus then
  -- Inline autocomplete and copilot/sidekick overrides — ianus only
  table.insert(plugins, require("plugins.ai.minuet"))
  table.insert(plugins, require("plugins.ai.ianus"))
end

return plugins
