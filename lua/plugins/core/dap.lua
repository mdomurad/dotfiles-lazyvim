return {
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      {
        "<leader>de",
        function()
          require("dapui").eval(nil, { context = "repl" })
        end,
        desc = "Eval (REPL context)",
        mode = { "n", "x" },
      },
    },
  },
}
