return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      require("easy-dotnet").setup({
        picker = "snacks",
        lsp = { enabled = true },
        test_runner = {
          viewmode = "float",
          mappings = {
            -- Buffer mappings (.cs files) — use <localleader> to avoid LazyVim conflicts
            run_test_from_buffer = { lhs = "<localleader>r", desc = "run test from buffer" },
            run_all_tests_from_buffer = { lhs = "<localleader>R", desc = "run all tests in file" },
            get_build_errors = { lhs = "<localleader>e", desc = "get build errors" },
            peek_stack_trace_from_buffer = { lhs = "<localleader>p", desc = "peek stack trace from buffer" },
            debug_test_from_buffer = { lhs = "<localleader>d", desc = "debug test from buffer" },

            -- Test runner window mappings — simple keys for dedicated UI buffer
            debug_test = { lhs = "d", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "go to file" },
            run_all = { lhs = "R", desc = "run all tests" },
            run = { lhs = "r", desc = "run test" },
            peek_stacktrace = { lhs = "p", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
            cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
          },
        },
      })

      -- Register dotnet command keymaps only for .cs buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function(ev)
          local wk_ok, wk = pcall(require, "which-key")
          local map_opts = { buffer = ev.buf, noremap = true, silent = true }

          local mappings = {
            { "<localleader>n", "<cmd>Dotnet<CR>", desc = "Dotnet picker" },
            { "<localleader>t", "<cmd>Dotnet testrunner<CR>", desc = "Toggle test runner" },
            { "<localleader>b", "<cmd>Dotnet build solution quickfix<CR>", desc = "Build solution → quickfix" },
            { "<localleader>x", "<cmd>Dotnet run default<CR>", desc = "Run default project" },
            { "<localleader>D", "<cmd>Dotnet debug default<CR>", desc = "Debug default project" },
            { "<localleader>w", "<cmd>Dotnet watch default<CR>", desc = "Watch mode" },
            { "<localleader>c", "<cmd>Dotnet clean<CR>", desc = "Clean solution" },
            { "<localleader>s", "<cmd>Dotnet secrets<CR>", desc = "Edit user secrets" },
            { "<localleader>a", "<cmd>Dotnet add package<CR>", desc = "Add NuGet package" },
            { "<localleader>v", "<cmd>Dotnet project view<CR>", desc = "Project view" },
            { "<localleader>i", "<cmd>Dotnet diagnostic<CR>", desc = "Workspace diagnostics" },
            { "<localleader>o", "<cmd>Dotnet restore<CR>", desc = "Restore packages" },
          }

          if wk_ok then
            -- Register group label + all mappings via which-key
            local wk_mappings = {
              { "<localleader>", group = "Dotnet", buffer = ev.buf },
            }
            for _, m in ipairs(mappings) do
              table.insert(wk_mappings, { m[1], m[2], desc = m.desc, buffer = ev.buf })
            end
            wk.add(wk_mappings)
          else
            -- Fallback: register via vim.keymap.set
            for _, m in ipairs(mappings) do
              vim.keymap.set("n", m[1], m[2], vim.tbl_extend("force", map_opts, { desc = m.desc }))
            end
          end
        end,
      })
    end,
  },
}
