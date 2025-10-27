return {
  {
    "JellyApple102/flote.nvim",
    config = function()
      require("flote").setup({
        q_to_quit = true,
        window_style = "minimal",
        window_border = "solid",
        window_title = true,
        notes_dir = (
          os.getenv("USERNAME") == "ianus" and "C:\\clouds\\mega\\tbb\\dev\\notes\\flote" or "~/notes/flote"
        ),
        files = {
          global = "flote-global.md",
          cwd = function()
            local bufPath = vim.api.nvim_buf_get_name(0)
            local cwd = require("lspconfig").util.root_pattern(".git")(bufPath)

            return cwd
          end,
          file_name = function(cwd)
            local base_name = vim.fs.basename(cwd)
            local parent_base_name = vim.fs.basename(vim.fs.dirname(cwd))
            return parent_base_name .. "_" .. base_name .. ".md"
          end,
        },
      })
    end,
    keys = {
      {
        ";n",
        "<cmd>Flote<cr>",
        desc = "Open Note",
      },
      {
        ";N",
        "<cmd>Flote global<cr>",
        desc = "Open Global Note",
      },
    },
  },
}
