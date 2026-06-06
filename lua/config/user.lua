-- Central user configuration utilities
-- Used across the config to check for user-specific behavior

local M = {}

-- Check if current user is "ianus"
M.is_ianus = os.getenv("USERNAME") == "ianus"

-- Get the current username
M.username = os.getenv("USERNAME")

return M
