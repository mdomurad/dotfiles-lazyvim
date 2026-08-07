local M = {}

local state_dir = vim.fn.stdpath("state")
local state_file = vim.fs.joinpath(state_dir, "nvim-state.json")
local state_cache

local function warn(message)
  vim.notify("State: " .. message, vim.log.levels.WARN)
end

local function read_state()
  if state_cache then
    return state_cache
  end

  state_cache = {}
  if vim.fn.filereadable(state_file) ~= 1 then
    return state_cache
  end

  local lines = vim.fn.readfile(state_file)
  if #lines == 0 then
    return state_cache
  end

  local ok, decoded = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    warn("ignoring malformed state file: " .. state_file)
    return state_cache
  end

  state_cache = decoded
  return state_cache
end

--- Load all persisted state. The returned table is a copy and can be safely inspected.
---@return table
function M.load()
  return vim.deepcopy(read_state())
end

--- Read one value from the persisted state.
---@param key string
---@param default any
---@return any
function M.get(key, default)
  local value = read_state()[key]
  if value == nil then
    return default
  end
  return value
end

--- Persist one value in the shared state store.
---@param key string
---@param value any
---@return boolean, string|nil
function M.set(key, value)
  local state = read_state()
  state[key] = value

  local ok, err = pcall(function()
    vim.fn.mkdir(state_dir, "p")
    local result = vim.fn.writefile({ vim.fn.json_encode(state) }, state_file)
    if result ~= 0 then
      error("writefile returned " .. tostring(result))
    end
  end)

  if not ok then
    local message = tostring(err)
    warn("could not save " .. key .. ": " .. message)
    return false, message
  end

  return true, nil
end

return M
