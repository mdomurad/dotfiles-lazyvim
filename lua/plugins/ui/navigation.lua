return {
  {
    "smoka7/hop.nvim",
    version = "*",
    config = function()
      require("hop").setup()
      -- vim.api.nvim_set_keymap("n", "F", ":HopWord<CR>", { noremap = true, silent = true })

      local hop = require("hop")
      local directions = require("hop.hint").HintDirection
      vim.keymap.set("", "f", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
      end, { remap = true })
      vim.keymap.set("", "F", function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
      end, { remap = true })
      vim.keymap.set("", "t", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false, hint_offset = -1 })
      end, { remap = true })
      vim.keymap.set("", "T", function()
        hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false, hint_offset = 1 })
      end, { remap = true })
      vim.keymap.set("", "T", function()
        hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = false })
      end, { remap = true })
    end,
  },
}
