return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      -- Set MSBuild Configuration env var for Roslyn LSP (Revit SDK framework resolution)
      vim.g.revit_lsp_config = vim.g.revit_lsp_config or "Debug R22"
      vim.env.Configuration = vim.g.revit_lsp_config

      require("easy-dotnet").setup({
        picker = "snacks",
        lsp = { enabled = true },
        auto_bootstrap_namespace = {
          --block_scoped, file_scoped
          type = "file_scoped",
          enabled = true,
          use_clipboard_json = {
            behavior = "prompt", --'auto' | 'prompt' | 'never',
            register = "+", -- which register to check
          },
        },
        test_runner = {
          viewmode = "vsplit",
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
                local lines = vim.split(result.stdout or "", "\n", { trimempty = true })

                -- Parse MSBuild output: path(line,col): error/warning CODE: message [project]
                local qf_entries = {}
                local seen = {}
                for _, line in ipairs(lines) do
                  local filepath, lnum, col, msg = line:match("^(.-)%((%d+),(%d+)%):%s+error%s+(.+)$")
                  local entry_type = "E"
                  if not filepath then
                    filepath, lnum, col, msg = line:match("^(.-)%((%d+),(%d+)%):%s+warning%s+(.+)$")
                    entry_type = "W"
                  end
                  if filepath then
                    local key = filepath .. ":" .. lnum .. ":" .. col .. ":" .. msg
                    if not seen[key] then
                      seen[key] = true
                      table.insert(qf_entries, {
                        filename = filepath,
                        lnum = tonumber(lnum),
                        col = tonumber(col),
                        text = msg,
                        type = entry_type,
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
              if not year then
                return
              end
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
          -- Revit LSP configuration switcher
          --
          -- Switches the MSBuild Configuration that Roslyn LSP uses to
          -- evaluate projects, controlling TargetFramework resolution.
          ----------------------------------------------------------------
          local function revit_lsp_switch()
            local configs = {}
            for _, year in ipairs(revit_versions) do
              local short = year:gsub("^20", "")
              table.insert(configs, "Debug R" .. short)
            end

            vim.ui.select(configs, {
              prompt = "Revit LSP Configuration",
              format_item = function(item)
                local mark = item == vim.g.revit_lsp_config and " * " or "   "
                local short = tonumber(item:match("R(%d+)") or "0")
                local year = short + 2000
                local tfm = "net48"
                if year >= 2027 then
                  tfm = "net10.0-windows7.0"
                elseif year >= 2025 then
                  tfm = "net8.0-windows7.0"
                end
                return mark .. item .. "  ->  " .. tfm
              end,
            }, function(choice)
              if not choice then
                return
              end
              vim.g.revit_lsp_config = choice
              vim.env.Configuration = choice
              vim.notify("Revit LSP -> " .. choice .. " -- restarting...", vim.log.levels.INFO)
              vim.lsp.stop(vim.lsp.get_clients())
              vim.defer_fn(function()
                vim.cmd("edit")
              end, 500)
            end)
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
            {
              "<localleader>rr",
              function()
                revit_build("debug")
              end,
              desc = "Revit build Debug",
            },
            {
              "<localleader>rb",
              function()
                revit_build("release")
              end,
              desc = "Revit build Release",
            },

            -- Revit clean (async -> quickfix)
            {
              "<localleader>rcd",
              function()
                revit_clean("debug")
              end,
              desc = "Revit clean Debug",
            },
            {
              "<localleader>rcr",
              function()
                revit_clean("release")
              end,
              desc = "Revit clean Release",
            },

            -- Entity Framework
            { "<localleader>ea", "<cmd>Dotnet ef migrations add<CR>", desc = "EF migration add" },
            { "<localleader>er", "<cmd>Dotnet ef migrations remove<CR>", desc = "EF migration remove" },
            { "<localleader>el", "<cmd>Dotnet ef migrations list<CR>", desc = "EF migrations list" },
            { "<localleader>eu", "<cmd>Dotnet ef database update<CR>", desc = "EF database update" },
            { "<localleader>ep", "<cmd>Dotnet ef database update pick<CR>", desc = "EF database update (pick)" },
            { "<localleader>ed", "<cmd>Dotnet ef database drop<CR>", desc = "EF database drop" },

            -- LSP
            { "<localleader>ls", "<cmd>Dotnet lsp start<CR>", desc = "LSP start" },
            { "<localleader>lx", "<cmd>Dotnet lsp stop<CR>", desc = "LSP stop" },
            { "<localleader>lr", "<cmd>Dotnet lsp restart<CR>", desc = "LSP restart" },

            -- Revit LSP config switcher
            { "<localleader>rl", revit_lsp_switch, desc = "Revit LSP config" },
          }

          if wk_ok then
            local wk_mappings = {
              { "<localleader>", group = "Dotnet", buffer = ev.buf },
              { "<localleader>e", group = "Entity Framework", buffer = ev.buf },
              { "<localleader>l", group = "LSP", buffer = ev.buf },
              { "<localleader>r", group = "Revit", buffer = ev.buf },
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
