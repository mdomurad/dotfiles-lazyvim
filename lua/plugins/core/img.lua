return {
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        -- Automatically generates a file name so you don't have to type one
        prompt_for_file_name = false,

        -- Saves the image in an "assets" folder next to your markdown file
        relative_to_current_file = true,
        dir_path = "assets",

        -- Enables drag-and-drop support in insert mode
        drag_and_drop = {
          insert_mode = true,
        },
      },
    },
  },
}
