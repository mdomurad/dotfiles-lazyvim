return {
  {
    "DestopLine/boilersharp.nvim",
    opts = {},
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      filewatching = "roslyn",
      config = {
        settings = {
          -- ["csharp|inlay_hints"] = {
          --   csharp_enable_inlay_hints_for_implicit_object_creation = true,
          --   csharp_enable_inlay_hints_for_implicit_variable_types = true,
          --   csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          --   csharp_enable_inlay_hints_for_types = true,
          --   dotnet_enable_inlay_hints_for_indexer_parameters = true,
          --   dotnet_enable_inlay_hints_for_literal_parameters = true,
          --   dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          --   dotnet_enable_inlay_hints_for_other_parameters = true,
          --   dotnet_enable_inlay_hints_for_parameters = true,
          --   dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          --   dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          --   dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          -- },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = true,
          },
          ["csharp|symbol_search"] = {
            dotnet_organize_imports_on_format = true,
            dotnet_search_reference_assemblies = true,
          },
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
        },
      },
    },
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
    config = function()
      require("easy-dotnet").setup({
        picker = "fzf",
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
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-dotnet"] = {
        discovery_root = "solution",
      }
    end,
  },
}
