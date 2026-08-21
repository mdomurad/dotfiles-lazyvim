return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local state = require("config.state")
      local default_revit_config = "Debug.R22"

      local function is_valid_revit_config(config)
        if type(config) ~= "string" then
          return false
        end
        return config:match("^Debug%.R2[0-7]$") ~= nil or config:match("^Release%.R2[0-7]$") ~= nil
      end

      -- Set MSBuild Configuration env var for Roslyn LSP (Revit SDK framework resolution)
      -- The persisted value is the source of truth for the last selected Revit
      -- configuration. Fall back to the current global only when no state exists.
      local function sync_revit_lsp_config()
        local saved_revit_config = state.get("revit_lsp_config", vim.g.revit_lsp_config or default_revit_config)
        if not is_valid_revit_config(saved_revit_config) then
          saved_revit_config = vim.g.revit_lsp_config
        end
        if not is_valid_revit_config(saved_revit_config) then
          saved_revit_config = default_revit_config
        end
        vim.g.revit_lsp_config = saved_revit_config
        vim.env.Configuration = saved_revit_config
      end

      sync_revit_lsp_config()

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

      local revit_config_group = vim.api.nvim_create_augroup("RevitDotnetConfiguration", { clear = true })
      vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "LspAttach" }, {
        group = revit_config_group,
        callback = function()
          vim.schedule(sync_revit_lsp_config)
        end,
      })
      sync_revit_lsp_config()
      vim.defer_fn(sync_revit_lsp_config, 1000)

      -- Register dotnet command keymaps for C# and dotnet project buffers
      local function register_dotnet_keymaps(ev)
        local keymap_version = "revit-config-v7"
        if vim.b[ev.buf].easy_dotnet_keymaps_registered == keymap_version then
          return
        end
        vim.b[ev.buf].easy_dotnet_keymaps_registered = keymap_version
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

        local function set_revit_lsp_config(config)
          local changed = vim.g.revit_lsp_config ~= config or vim.env.Configuration ~= config
          vim.g.revit_lsp_config = config
          vim.env.Configuration = config
          state.set("revit_lsp_config", config)

          if not changed then
            return
          end

          vim.notify("Revit LSP -> " .. config .. " -- restarting...", vim.log.levels.INFO)

          -- Restart active LSP clients so Roslyn reevaluates the project
          -- with the new configuration.
          for _, client in pairs(vim.lsp.get_clients()) do
            if client and client.stop then
              client:stop()
            end
          end

          vim.defer_fn(function()
            vim.cmd("edit")
          end, 500)
        end

        local function select_revit_config(build_type, callback)
          vim.ui.select(revit_versions, { prompt = "Revit Version" }, function(year)
            if not year then
              return
            end
            local version = year:gsub("^20", "")
            local configuration = (build_type == "release" and "Release" or "Debug") .. ".R" .. version
            set_revit_lsp_config(configuration)
            callback(configuration)
          end)
        end

        local function revit_build(build_type)
          select_revit_config(build_type, function(config)
            dotnet_async_qf({ "dotnet", "build", "-c", config }, "Revit Build [" .. config .. "]")
          end)
        end

        local function revit_clean(build_type)
          select_revit_config(build_type, function(config)
            dotnet_async_qf({ "dotnet", "clean", "-c", config }, "Revit Clean [" .. config .. "]")
          end)
        end

        local function last_revit_config()
          local config = state.get("revit_lsp_config", vim.g.revit_lsp_config or default_revit_config)
          if not is_valid_revit_config(config) then
            config = vim.g.revit_lsp_config
          end
          if not is_valid_revit_config(config) then
            config = default_revit_config
          end

          -- Keep the current MSBuild/LSP environment aligned with the selected
          -- configuration when a last-build or last-clean mapping is invoked.
          vim.g.revit_lsp_config = config
          vim.env.Configuration = config
          return config
        end

        local function revit_build_last()
          local config = last_revit_config()
          dotnet_async_qf({ "dotnet", "build", "-c", config }, "Revit Build [" .. config .. "]")
        end

        local function revit_clean_last()
          local config = last_revit_config()
          dotnet_async_qf({ "dotnet", "clean", "-c", config }, "Revit Clean [" .. config .. "]")
        end

        -- Commands resolve the state at invocation time. This avoids retaining a
        -- stale Lua callback in an already-open C# buffer after a config reload.
        vim.api.nvim_create_user_command("RevitBuildLast", revit_build_last, {
          desc = "Build using the last selected Revit configuration",
          force = true,
        })
        vim.api.nvim_create_user_command("RevitCleanLast", revit_clean_last, {
          desc = "Clean using the last selected Revit configuration",
          force = true,
        })

        ----------------------------------------------------------------
        -- Mapping table
        ----------------------------------------------------------------
        local mappings = {
          -- Dotnet commands
          { "<localleader>\\", "<cmd>Dotnet<CR>", desc = "Dotnet picker" },
          { "<localleader>n", "<cmd>Dotnet new<CR>", desc = "Dotnet new" },
          { "<localleader>t", "<cmd>Dotnet testrunner<CR>", desc = "Toggle test runner" },
          { "<localleader>x", "<cmd>Dotnet run default<CR>", desc = "Run default project" },
          { "<localleader>D", "<cmd>Dotnet debug default<CR>", desc = "Debug default project" },
          { "<localleader>w", "<cmd>Dotnet watch default<CR>", desc = "Watch mode" },
          { "<localleader>s", "<cmd>Dotnet secrets<CR>", desc = "Edit user secrets" },
          { "<localleader>a", "<cmd>Dotnet add package<CR>", desc = "Add NuGet package" },
          { "<localleader>v", "<cmd>Dotnet solution select<CR>", desc = "Select solution" },
          { "<localleader>i", "<cmd>Dotnet diagnostic<CR>", desc = "Workspace diagnostics" },
          { "<localleader>o", "<cmd>Dotnet restore<CR>", desc = "Restore packages" },

          { "<localleader>cs", "<cmd>Dotnet clean<CR>", desc = "Clean solution" },
          { "<localleader>bs", "<cmd>Dotnet build solution quickfix<CR>", desc = "Build solution -> quickfix" },

          -- Revit build (pick version -> async build -> quickfix)
          {
            "<localleader>bd",
            function()
              revit_build("debug")
            end,
            desc = "Revit build Debug",
          },
          {
            "<localleader>bl",
            "<cmd>RevitBuildLast<CR>",
            desc = "Revit build last selected",
          },
          {
            "<localleader>br",
            function()
              revit_build("release")
            end,
            desc = "Revit build Release",
          },

          -- Revit clean (pick version -> async clean -> quickfix)
          {
            "<localleader>cd",
            function()
              revit_clean("debug")
            end,
            desc = "Revit clean Debug",
          },
          {
            "<localleader>cl",
            "<cmd>RevitCleanLast<CR>",
            desc = "Revit clean last selected",
          },
          {
            "<localleader>cr",
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
        }

        for _, m in ipairs(mappings) do
          vim.keymap.set("n", m[1], m[2], vim.tbl_extend("force", map_opts, { desc = m.desc }))
        end

        if wk_ok then
          wk.add({
            { "<localleader>", group = "Dotnet", buffer = ev.buf },
            { "<localleader>e", group = "Entity Framework", buffer = ev.buf },
            { "<localleader>l", group = "LSP", buffer = ev.buf },
            { "<localleader>b", group = "Build", buffer = ev.buf },
            { "<localleader>c", group = "Clean", buffer = ev.buf },
          })
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = register_dotnet_keymaps,
      })

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.csproj", "*.sln", "*.slnx" },
        callback = register_dotnet_keymaps,
      })

      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buffer) then
          local name = vim.api.nvim_buf_get_name(buffer)
          local filetype = vim.bo[buffer].filetype
          if filetype == "cs" or name:match("%.csproj$") or name:match("%.slnx?$") then
            register_dotnet_keymaps({ buf = buffer })
          end
        end
      end
    end,
  },
}
