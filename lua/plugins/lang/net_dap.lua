return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function(_, opts)
      local dap = require("dap")
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe"
      local command = vim.fn.executable(mason_path) == 1 and mason_path or "netcoredbg.exe"

      -- Set adapters directly on the dap module and in opts for compatibility
      local adapter = {
        type = "executable",
        command = command,
        args = { "--interpreter=vscode" },
      }

      dap.adapters.coreclr = adapter
      dap.adapters.netcoredbg = adapter

      opts.adapters = opts.adapters or {}
      opts.adapters.coreclr = adapter
      opts.adapters.netcoredbg = adapter

      opts.configurations = opts.configurations or {}
      opts.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }
      return opts
    end,
  },
}