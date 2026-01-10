-- https://github.com/m0lson84/dotfiles/tree/9e89180fafc3cfb39e4f2a2f32a35205fb691be7/home/private_dot_config/nvim/lua
return {
  require("plugins.core"),
  require("plugins.coding"),
  -- require("plugins.editor"),
  -- require("plugins.format"),
  require("plugins.lang"),
  -- require("plugins.lint"),
  -- require("plugins.test"),
  require("plugins.ui"),
  require("plugins.util"),
  require("plugins.ai"),
  require("plugins.lsp"),
}
