# Repository guidance

## Persistent editor state

Use `lua/config/state.lua` for persistent Neovim state instead of writing feature-specific files from plugin configuration modules. The module owns the JSON state file under `vim.fn.stdpath("state")` and exposes the shared load/get/set behavior.

The Revit integration currently stores its last full MSBuild configuration under the `revit_lsp_config` key. Feature code remains responsible for validating feature-specific values and supplying defaults; the shared state module should stay generic so additional settings can be added without creating more persistence implementations.

When adding state, prefer a namespaced key, avoid secrets, and keep state writes small and infrequent.
