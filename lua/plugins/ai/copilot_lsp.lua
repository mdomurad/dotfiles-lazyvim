return {
  -- copilot-lsp provides the NES (Next Edit Suggestion) Lua API.
  -- We do NOT call vim.lsp.enable("copilot_ls") here — that would start a
  -- second copilot-language-server alongside the one that copilot-native
  -- already runs via nvim-lspconfig (server name: "copilot").
  -- Instead we hook into that existing server.
  {
    "copilotlsp-nvim/copilot-lsp",
    init = function()
      vim.g.copilot_nes_debounce = 500

      -- When the copilot LSP server attaches to any buffer, wire up NES.
      -- lsp_on_init registers the TextChanged autocmds that request NES and
      -- populates vim.b[bufnr].nes_state when a suggestion arrives.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "copilot" then
            local au = vim.api.nvim_create_augroup("copilotlsp.nes", { clear = true })
            require("copilot-lsp.nes").lsp_on_init(client, au)
          end
        end,
      })

      -- <C-p> in normal mode: NES two-step accept (matches README exactly).
      --   1st press → jump cursor to suggestion start
      --   2nd press → apply edit + jump to end
      -- Falls back to built-in cursor-up when no suggestion is pending.
      vim.keymap.set("n", "<C-p>", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.b[bufnr].nes_state then
          local nes = require("copilot-lsp.nes")
          local _ = nes.walk_cursor_start_edit()
            or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-p>", true, true, true),
            "n",
            false
          )
        end
      end, { desc = "NES: navigate / accept (or cursor up)" })
    end,
  },

  -- Push the NES settings and handlers into the existing copilot lspconfig
  -- server so the server actually sends NES suggestions.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.copilot = opts.servers.copilot or {}

      -- Tell the server to enable Next Edit Suggestions
      opts.servers.copilot.settings = vim.tbl_deep_extend(
        "force",
        opts.servers.copilot.settings or {},
        { nextEditSuggestions = { enabled = true } }
      )

      -- Merge sign-in + status handlers from copilot-lsp
      opts.servers.copilot.handlers = vim.tbl_deep_extend(
        "force",
        opts.servers.copilot.handlers or {},
        require("copilot-lsp.handlers")
      )
    end,
  },
}
