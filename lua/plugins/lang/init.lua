-- setup based on :
-- https://git.ramboe.io/YouTube/neovim-c-the-actually-improved-configuration-2025-roslynnvim-rzslnvim.git

return {
  require("plugins.lang.net.net"),
  require("plugins.lang.net.roslyn"),
  require("plugins.lang.net.dap"),
  require("plugins.lang.net.neotest"),
  require("plugins.lang.net.easy_dotnet"),
  require("plugins.lang.markdown.markdown-plus"),
  require("plugins.lang.treesitter"),
  require("plugins.lang.html"),
}
