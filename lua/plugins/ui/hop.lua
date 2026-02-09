return {
  {
    "smoka7/hop.nvim",
    version = "*",
    -- This 'keys' table tells lazy.nvim: "Don't load this plugin until I press t, T, f, or F"
    keys = {
      {
        "t",
        function()
          require("hop").hint_char1({
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "v", "o" }, -- equivalent to "" in your config
        remap = true,
        desc = "Hop char after cursor",
      },
      {
        "T",
        function()
          require("hop").hint_char1({
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "v", "o" },
        remap = true,
        desc = "Hop char before cursor",
      },
      {
        "f",
        function()
          require("hop").hint_words({
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "v", "o" },
        remap = true,
        desc = "Hop words after cursor",
      },
      {
        "F",
        function()
          require("hop").hint_words({
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = false,
          })
        end,
        mode = { "n", "v", "o" },
        remap = true,
        desc = "Hop words before cursor",
      },
    },
    config = function()
      -- This runs ONLY after one of the keys above is pressed
      require("hop").setup()
    end,
  },
}
