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
      opts.adapters["neotest-dotnet"] = {
        discovery_root = "solution",
      }
    end,
  },
}
