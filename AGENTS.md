# Repository guidance

## Persistent editor state

Use `lua/config/state.lua` for persistent Neovim state instead of writing feature-specific files from plugin configuration modules. The module owns the JSON state file under `vim.fn.stdpath("state")` and exposes the shared load/get/set behavior.

The Revit integration stores its last full MSBuild configuration under the `revit_lsp_config` key. `lua/plugins/lang/net/easy_dotnet.lua` loads that value into `vim.g.revit_lsp_config` and `vim.env.Configuration`, while `<localleader>bd`, `<localleader>br`, `<localleader>cd`, and `<localleader>cr` save the selected full configuration. `<localleader>bl` and `<localleader>cl` execute `:RevitBuildLast` and `:RevitCleanLast`, which resolve the persisted configuration at invocation time.

Feature code remains responsible for validating feature-specific values and supplying defaults; the shared state module should stay generic so additional settings can be added without creating more persistence implementations. Lua patterns do not support `|` alternation: validate `Debug.Rxx` and `Release.Rxx` with separate pattern matches.

When adding state, prefer a namespaced key, avoid secrets, and keep state writes small and infrequent.
