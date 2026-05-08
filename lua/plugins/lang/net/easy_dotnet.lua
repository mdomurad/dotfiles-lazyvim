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
            -- Buffer mappings (.cs files) — use <localleader> to avoid LazyVim conflicts
            run_test_from_buffer = { lhs = "<localleader>r", desc = "run test from buffer" },
            run_all_tests_from_buffer = { lhs = "<localleader>R", desc = "run all tests in file" },
            get_build_errors = { lhs = "<localleader>e", desc = "get build errors" },
            peek_stack_trace_from_buffer = { lhs = "<localleader>p", desc = "peek stack trace from buffer" },
            debug_test_from_buffer = { lhs = "<localleader>d", desc = "debug test from buffer" },

            -- Test runner window mappings — simple keys for dedicated UI buffer
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

          ----------------------------------------------------------------
          -- Revit build/clean helpers (async, quickfix)
          ----------------------------------------------------------------
          local revit_versions = { "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027" }

          --- Parse MSBuild output and populate quickfix with errors/warnings only
          ---@param cmd string[]
          ---@param title string
          local function dotnet_async_qf(cmd, title)
            vim.notify(title .. "...", vim.log.levels.INFO)
            vim.system(cmd, { text = true }, function(result)
              vim.schedule(function()
                local output = (result.stdout or "") .. "\n" .. (result.stderr or "")
                local lines = vim.split(output, "\n", { trimempty = true })

                -- Parse MSBuild output: path(line,col): error/warning CODE: message [project]
                local qf_entries = {}
                for _, line in ipairs(lines) do
                  local filepath, lnum, col, msg =
                    line:match("^(.-)%((%d+),(%d+)%):%s+error%s+(.+)$")
                  if filepath then
                    table.insert(qf_entries, {
                      filename = filepath,
                      lnum = tonumber(lnum),
                      col = tonumber(col),
                      text = msg,
                      type = "E",
                    })
                  else
                    filepath, lnum, col, msg =
                      line:match("^(.-)%((%d+),(%d+)%):%s+warning%s+(.+)$")
                    if filepath then
                      table.insert(qf_entries, {
                        filename = filepath,
                        lnum = tonumber(lnum),
                        col = tonumber(col),
                        text = msg,
                        type = "W",
                      })
                    end
                  end
                end

                vim.fn.setqflist({}, "r", { title = title, items = qf_entries })

                if result.code == 0 then
                  vim.notify(title .. " succeeded", vim.log.levels.INFO)
                else
                  vim.notify(title .. " FAILED (" .. #qf_entries .. " issues)", vim.log.levels.ERROR)
                  vim.cmd("copen")
                end
              end)
            end)
          end

          local function revit_build(build_type)
            vim.ui.select(revit_versions, { prompt = "Revit Version" }, function(year)
              if not year then return end
              local version = year:gsub("^20", "")
              local config = (build_type == "release" and "Release" or "Debug") .. " R" .. version
              dotnet_async_qf({ "dotnet", "build", "-c", config }, "Revit Build [" .. config .. "]")
            end)
          end

          local function revit_clean(build_type)
            local config = (build_type == "release" and "Release" or "Debug")
            dotnet_async_qf({ "dotnet", "clean", "-c", config }, "Revit Clean [" .. config .. "]")
          end

          ----------------------------------------------------------------
          -- Mapping table
          ----------------------------------------------------------------
          local mappings = {
            -- Dotnet commands
            { "<localleader>n", "<cmd>Dotnet<CR>", desc = "Dotnet picker" },
            { "<localleader>t", "<cmd>Dotnet testrunner<CR>", desc = "Toggle test runner" },
            { "<localleader>b", "<cmd>Dotnet build solution quickfix<CR>", desc = "Build solution -> quickfix" },
            { "<localleader>x", "<cmd>Dotnet run default<CR>", desc = "Run default project" },
            { "<localleader>D", "<cmd>Dotnet debug default<CR>", desc = "Debug default project" },
            { "<localleader>w", "<cmd>Dotnet watch default<CR>", desc = "Watch mode" },
            { "<localleader>c", "<cmd>Dotnet clean<CR>", desc = "Clean solution" },
            { "<localleader>s", "<cmd>Dotnet secrets<CR>", desc = "Edit user secrets" },
            { "<localleader>a", "<cmd>Dotnet add package<CR>", desc = "Add NuGet package" },
            { "<localleader>v", "<cmd>Dotnet project view<CR>", desc = "Project view" },
            { "<localleader>i", "<cmd>Dotnet diagnostic<CR>", desc = "Workspace diagnostics" },
            { "<localleader>o", "<cmd>Dotnet restore<CR>", desc = "Restore packages" },

            -- Revit build (pick version -> async build -> quickfix)
            { "<localleader>rd", function() revit_build("debug") end, desc = "Revit build Debug" },
            { "<localleader>rr", function() revit_build("release") end, desc = "Revit build Release" },

            -- Revit clean (async -> quickfix)
            { "<localleader>rcd", function() revit_clean("debug") end, desc = "Revit clean Debug" },
            { "<localleader>rcr", function() revit_clean("release") end, desc = "Revit clean Release" },
          }

          if wk_ok then
            local wk_mappings = {
              { "<localleader>", group = "Dotnet", buffer = ev.buf },
              { "<localleader>r", group = "Revit Build", buffer = ev.buf },
              { "<localleader>rc", group = "Revit Clean", buffer = ev.buf },
            }
            for _, m in ipairs(mappings) do
              table.insert(wk_mappings, { m[1], m[2], desc = m.desc, buffer = ev.buf })
            end
            wk.add(wk_mappings)
          else
            for _, m in ipairs(mappings) do
              vim.keymap.set("n", m[1], m[2], vim.tbl_extend("force", map_opts, { desc = m.desc }))
            end
          end
        end,
      })
    end,
  },
}
