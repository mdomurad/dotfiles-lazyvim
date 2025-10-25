-- https://www.reddit.com/r/csharp/comments/15ktebq/debugging_with_netcoredbg_in_neovim/
-- args for debugging with development
-- /p:EnvironmentName=Development --urls=http://localhost:8080 --environment=Development

local function ls_dir(path)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('dir "' .. path .. '" /b')
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

local function get_root_dir()
  return vim.fn.getcwd()
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
    opts = function()
      local dap = require("dap")
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          env = "ASPNETCORE_ENVIRONMENT=Development",
          args = {
            "/p:EnvironmentName=Development",
            "--urls=http://localhost:8080",
            "--environment=Development",
          },
          program = function()
            local files = ls_dir(get_root_dir() .. "/bin/Debug/")
            if #files == 1 then
              local dotnet_dir = get_root_dir() .. "/bin/Debug/" .. files[1]
              files = ls_dir(dotnet_dir)
              for _, file in ipairs(files) do
                if file:match(".*%.dll") then
                  return dotnet_dir .. "/" .. file
                end
              end
            end
            return vim.fn.input({
              prompt = "Path to dll",
              default = get_root_dir() .. "/bin/Debug/",
            })
          end,
        },
      }
    end,
  },
}
