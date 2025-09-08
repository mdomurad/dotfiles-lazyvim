return {
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["<BS>"] = "actions.parent",
        ["g\\"] = "actions.toggle_trash",
        ["q"] = "actions.close",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-r>"] = "actions.refresh",
        ["ocd"] = "actions.open_cwd",
        ["cd"] = "actions.cd",
        ["cwd"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["yp"] = "actions.copy_entry_path",
        ["tp"] = "actions.open_cmdline",
        ["td"] = "actions.open_cmdline_dir",
        ["m"] = "actions.add_to_loclist",
      },
      float = {
        padding = 10,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
