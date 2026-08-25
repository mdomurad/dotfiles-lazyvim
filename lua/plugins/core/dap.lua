local last_expression

local function eval_expression()
  local dapui = require("dapui")
  local expression = require("dapui.util").get_current_expr()

  -- Clear dap-ui's registered hover float only when evaluating a new
  -- expression. Repeating the same expression should enter the existing
  -- float so its expandable details remain available.
  if last_expression ~= expression then
    require("dapui.windows").close_float("hover")
  end
  last_expression = expression

  -- nvim-dap-ui accepts these options as optional at runtime and sizes the
  -- float to its contents when width and height are omitted.
  ---@diagnostic disable-next-line: missing-fields
  dapui.eval(expression, { context = "repl" })
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
