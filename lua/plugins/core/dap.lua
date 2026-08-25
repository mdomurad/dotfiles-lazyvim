local function eval_expression()
  -- Clear dap-ui's registered hover float before evaluating a new expression.
  -- dapui.eval() closes the old window directly, which leaves the window
  -- registry pointing at that stale float on the next evaluation.
  local dapui = require("dapui")
  require("dapui.windows").close_float("hover")
  -- nvim-dap-ui accepts these options as optional at runtime and sizes the
  -- float to its contents when width and height are omitted.
  ---@diagnostic disable-next-line: missing-fields
  dapui.eval(nil, { context = "repl" })
end

return {
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      {
        "<leader>de",
        eval_expression,
        desc = "Eval (REPL context)",
        mode = { "n", "x" },
      },
    },
  },
}
