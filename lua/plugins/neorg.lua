reuturn({
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.completion"] = { config = { engine = "nvim-cmp" } },
          ["core.journal"] = {},
          ["core.qol.toc"] = {},
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                todo = "c:/notes/todo",
                notes = "c:/notes/notes",
                development = "c:/notes/dev",
                bim = "c:/notes/bim",
              },
              default_workspace = "todo",
            },
          },
        },
      })
    end,
  },
})
