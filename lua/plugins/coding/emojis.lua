return {

  {
    "allaman/emoji.nvim",
    ft = "markdown", -- adjust to your needs
    dependencies = {
      -- util for handling paths
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- default is false, also needed for blink.cmp integration!
      enable_cmp_integration = true,
    },
  },
  -- Blink cmp integration
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "allaman/emoji.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        default = { "emoji" },
        providers = {
          emoji = {
            name = "emoji",
            module = "blink.compat.source",
            -- overwrite kind of suggestion
            transform_items = function(ctx, items)
              local kind = require("blink.cmp.types").CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
        },
      },
    },
  },
}
