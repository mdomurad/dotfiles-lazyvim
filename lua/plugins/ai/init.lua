local user = os.getenv("USERNAME")

local plugins = {
  -- Disabled plugins, uncomment to enable
  -- require("plugins.ai.minuet"),
  -- require("plugins.ai.chatgpt"),
  -- require("plugins.ai.avante"),

  -- Enabled plugins
  require("plugins.ai.copilot"),
  require("plugins.ai.codeCompanion"),
  require("plugins.ai.wtf"),
  require("plugins.ai.opencode"),
  require("plugins.ai.sidekick"),
}

if user == "ianus" then
  -- User-specific plugins can be added here.
  -- For example, to enable avante for user 'ianus':
  -- table.insert(plugins, require("plugins.ai.avante"))
end

return plugins
