return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "luarocks.nvim",
      "pysan3/pathlib.nvim",
      "nvim-neorg/lua-utils.nvim",
      { "pysan3/neorg-templates", dependencies = { "L3MON4D3/LuaSnip" } },
    },
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.completion"] = { config = { engine = "nvim-cmp" } },
          ["core.journal"] = { config = { jornal_folder = "jrnl" } },
          ["core.qol.toc"] = {},
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                todo = "c:/.neorg/todo",
                notes = "c:/.neorg/notes",
                development = "c:/.neorg/dev",
                bim = "c:/.neorg/bim",
                priv = "c:/.neorg/jrnl",
              },
              default_workspace = "todo",
            },
          },
        },
      })
    end,
  },
}
