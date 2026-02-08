return {
  {
    "Nsidorenco/neotest-vstest",
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-dotnet")({
          discovery_root = "solution",
          dap_adapter = "coreclr",
        })
      )
      return opts
    end,
  },
}
