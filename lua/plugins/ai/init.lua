local user = os.getenv("USERNAME")

local plugins = {
  require("plugins.ai.codeCompanion"),
  require("plugins.ai.wtf"),
}

if user == "ianus" then
  -- User-specific plugins can be added here.
  -- For example, to enable avante for user 'ianus':
  -- table.insert(plugins, require("plugins.ai.avante"))
end

return plugins
