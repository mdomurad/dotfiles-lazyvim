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
    },
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          -- ["core.completion"] = { config = { engine = "nvim-cmp" } },
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                todo = "c:/.neorg/todo",
                notes = "c:/.neorg/notes",
                dev = "c:/.neorg/dev",
                bim = "c:/.neorg/bim",
                journal = "c:/.neorg/jrnl",
              },
              default_workspace = "todo",
            },
          },
          ["core.export"] = {}, -- Exports Neorg documents into any other supported filetype.
          ["core.export.markdown"] = {}, -- Interface for core.export to allow exporting to markdown.
          ["core.presenter"] = { config = { zen_mode = "zen-mode" } }, -- Neorg module to create gorgeous presentation slides.
          ["core.summary"] = {}, -- Creates links to all files in any workspace.
          ["core.ui.calendar"] = {}, -- Creates links to all files in any workspace.
          ["core.keybinds"] = {},
          ["core.journal"] = { config = { journal_folder = "jrnl", workspace = "journal" } },
        },
      })
    end,
  },
}
