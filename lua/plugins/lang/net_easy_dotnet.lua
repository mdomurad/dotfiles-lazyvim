return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      require("easy-dotnet").setup({
        picker = "snacks",
        lsp = { enabled = false },
        test_runner = {
          viewmode = "float",
          mappings = {
            run_test_from_buffer = { lhs = "<leader>rtb", desc = "run test from buffer" },
            peek_stack_trace_from_buffer = { lhs = "<leader>rtp", desc = "peek stack trace from buffer" },
            filter_failed_tests = { lhs = "<leader>rtf", desc = "filter failed tests" },
            debug_test = { lhs = "<leader>rtd", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "go to file" },
            run_all = { lhs = "<leader>rtR", desc = "run all tests" },
            run = { lhs = "<leader>rtr", desc = "run test" },
            peek_stacktrace = { lhs = "<leader>rtp", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            expand_all = { lhs = "-", desc = "expand all" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
          },
        },
      })
    end,
  },
}
